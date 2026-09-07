# Auditoría de seguridad · 2026-09-07

## Alcance

Revisión del frontend de producción y desarrollo, permisos/RLS de Supabase, funciones RPC expuestas, almacenamiento local, invitaciones, certificados, triggers de Auth, Edge Functions, Storage y despliegue Netlify.

## Hallazgos corregidos

### Frontend público legacy

El bundle actualmente publicado en Netlify conserva un acceso provisional/local embebido. El valor de la credencial no se versiona ni se documenta. Se ha preparado un hotfix exacto de producción sin ese acceso, pero no se ha publicado porque el deploy actual de Netlify es manual (`drop`) y todavía no se ha validado una sustitución segura del artefacto público.

Hotfix preparado:

- `production-security-hotfix-no-legacy-auth-index.html`
- versión 16
- SHA-256 `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`

### Exposición de snapshots y manifests de frontend

`academy_frontend_assets`, `academy_frontend_chunks` y posteriormente `academy_frontend_releases` tenían superficie de lectura anónima. Se eliminaron las políticas/grants públicos de los tres almacenes. Las copias completas, chunks y manifests quedan restringidos a acceso administrativo autenticado según RLS.

### Privilegios anónimos de base de datos

Además de RLS, se redujo la capa de privilegios SQL del rol `anon`:

- 0 privilegios a nivel de tabla en el esquema `public`;
- 0 permisos INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER;
- 0 privilegios `MAINTAIN` sobre relaciones públicas;
- 0 permisos sobre secuencias públicas;
- únicamente 5 permisos de columna SELECT en `academy_backend_meta`: `product_id`, `schema_version`, `curriculum_version`, `status`, `updated_at`.

La pantalla de acceso sigue pudiendo leer esos cinco campos y el verificador público de certificados sigue funcionando tras el cierre.

Los privilegios por defecto de los objetos nuevos creados por el rol de migraciones `postgres` se endurecieron: `anon` ya no recibe automáticamente permisos sobre tablas, secuencias ni funciones nuevas. Si algo debe ser público, tendrá que concederse explícitamente.

Los default ACL administrados internamente por la plataforma bajo `supabase_admin` no son modificables desde estas migraciones y se revisan por separado cuando intervienen en la superficie del campus.

### Superficie RPC anónima

Se revisaron todas las funciones `public`. Solo `verify_master_certificate_v2(text)` continúa siendo ejecutable por `anon`, de forma intencionada. El verificador legacy `verify_program_certificate(text)` no es ejecutable por `anon` ni por `authenticated`, y su helper privado legacy tampoco mantiene ejecución pública.

El helper privado v2 sigue siendo ejecutable por `anon` porque el wrapper público es `SECURITY INVOKER`; el esquema `private` no forma parte de la API pública del campus y el helper devuelve únicamente la misma respuesta minimizada del verificador público.

### Funciones privadas usadas como triggers

Se detectaron varias funciones `SECURITY DEFINER` del esquema `private` que eran exclusivamente funciones de trigger pero conservaban `EXECUTE` heredado para `anon`/`authenticated`. Se revocó la ejecución directa sobre todas las funciones privadas actualmente enlazadas a triggers. Los triggers siguen siendo el único mecanismo de entrada para esas funciones.

### Onboarding: cierre del bypass por alta directa

El flujo anterior podía aprovisionar una matrícula si se creaba un usuario Auth cuyo email coincidía con una invitación pendiente. Aunque el frontend no expusiera registro libre, una llamada directa a Auth no debía poder convertirse en un alta académica.

El flujo nuevo enlaza la matrícula a una prueba emitida exclusivamente por la Edge Function después de validar el código de invitación:

1. Admin genera un código de 24 caracteres hexadecimales (96 bits).
2. `activate-student-invite` valida email, código, caducidad, bloqueo y contraseña.
3. La Edge Function calcula el hash del código y crea el usuario mediante Admin Auth incluyendo ese hash en `app_metadata`.
4. El trigger `academy_enroll_pending_invite` solo matricula si el hash de `app_metadata` coincide con el hash activo de la invitación, el código no está caducado/usado y no existe bloqueo.
5. Al aceptar la matrícula, el trigger invalida el hash del código, registra `activation_used_at` y marca la invitación como `accepted`.
6. Si tras crear el usuario la invitación no queda aceptada, la Edge Function elimina la cuenta recién creada para evitar cuentas huérfanas.

La función privada antigua de matrícula por `email` sin prueba de activación fue eliminada.

### Allowlist legacy de Auth retirada

Existía además un trigger histórico `pioc_bootstrap_allowed_user` sobre `auth.users`, ligado a `private.allowed_emails`. Había entradas activas de legado y al menos una no correspondía todavía a un usuario Auth existente. Los usuarios actuales ya están provisionados con perfiles/roles reales, por lo que el trigger se retiró. La tabla histórica puede permanecer para auditoría, pero ya no concede acceso a nuevas cuentas.

El único trigger de onboarding que queda sobre `auth.users` es `academy_enroll_pending_invite`, sujeto al claim validado del código de invitación.

### Invitaciones administrativas sin SECURITY DEFINER público

`admin_create_student_invite_v2` ya no necesita leer `auth.users` y se convirtió a `SECURITY INVOKER`. La autorización depende del rol Admin del programa y de RLS. También se corrigió la recreación de invitaciones canceladas reutilizando la fila existente en lugar de chocar con la restricción única `(program_id,email)`.

Se ejecutó un QA transaccional como Admin con una invitación `example.com`: devolvió `ok=true`, estado `sent` y código de longitud 24. La transacción se revirtió y se comprobó después que quedaron 0 filas de prueba.

Tras el cambio, Supabase Security Advisor ya no reporta ninguna función `SECURITY DEFINER` pública ejecutable por usuarios autenticados.

### Endpoint de activación endurecido

`activate-student-invite` está en v5 y mantiene `verify_jwt=false` por diseño, ya que se usa antes de que exista sesión. Implementa controles propios:

- código obligatorio de 24 hex; se retiró compatibilidad con códigos antiguos de 12 caracteres;
- límite de payload de 4 KiB;
- longitud y formato de email;
- contraseña entre 12 y 256 caracteres y al menos 3 clases de caracteres;
- comparación del hash en tiempo constante a nivel de aplicación;
- caducidad y bloqueo de 15 minutos tras 5 intentos fallidos;
- CORS restringido a los orígenes previstos;
- `no-store`, `nosniff`, `no-referrer` y `Cross-Origin-Resource-Policy`.

No había ninguna invitación activa con código antiguo que necesitara mantener el formato de 12 caracteres. El frontend v57 quedó alineado con este contrato y ya no acepta el formato 12/24.

### Preview privado

La clave del preview de desarrollo fue rotada. El valor no se versiona ni se documenta. La versión actual mantiene `noindex`, `no-store`, CSP restrictiva, `frame-ancestors 'none'`, `X-Frame-Options: DENY`, `Permissions-Policy` restrictiva y `Cross-Origin-Resource-Policy: same-origin`.

### Edge Functions legacy

`pioc-campus`, antiguo publicador/redirect con privilegios de servidor, fue retirado y responde HTTP 410. Los helpers históricos de bootstrap, accesos especiales, cambio de contraseña, publicación antigua y parche de navegación permanecen también neutralizados con 410.

### Storage web legacy

Se detectó que el bucket histórico `pioc-web` seguía marcado como público y contenía un `index.html` antiguo. El frontend actual no referencia `pioc-web` y los publicadores legacy están deshabilitados, por lo que se conservó el objeto como evidencia/backup pero el bucket se cambió a **privado**.

El bucket `pioc-audio` ya era privado y sus políticas de `storage.objects` están limitadas a usuarios autenticados: acceso propio por carpeta y lectura adicional para Admin.

### Helper `is_admin`

`public.is_admin()` dejó de ser ejecutable por `anon` y por `PUBLIC`. Solo `authenticated` conserva `EXECUTE`.

### Metadatos públicos

`academy_backend_meta` continúa accesible para que la pantalla de login compruebe salud y versión, pero el rol anónimo solo tiene permiso de lectura sobre:

- `product_id`
- `schema_version`
- `curriculum_version`
- `status`
- `updated_at`

La columna interna `notes` no es legible por `anon` ni por el rol genérico `authenticated`.

### Caché del navegador

La sesión Auth usa `sessionStorage`. Desde frontend v54, la caché académica local se vincula a la cuenta autenticada y se elimina al cerrar sesión. Si existe una caché con propietario diferente, se descartan las copias locales antes de hidratar la nueva cuenta.

### Recuperación de contraseña

Se revisó estáticamente el flujo v57:

- solicitud contra `/auth/v1/recover`;
- redirect fijo al origen de producción;
- soporte de `token_hash` / `type=recovery` y sesión de recuperación en hash;
- actualización de contraseña mediante sesión Auth de recuperación;
- regla de 12 caracteres y 3 clases;
- cierre de sesión después del cambio y obligación de iniciar sesión de nuevo.

La prueba real del correo/redirect sigue siendo un QA de navegador previo a producción.

### Enlaces de invitación en preview

Desde v55 los enlaces compartibles se construyen siempre contra el dominio de producción y no a partir de `location.href`, evitando copiar accidentalmente la clave del preview. Desde v56 el Admin ve además un aviso cuando trabaja desde preview para no enviar el enlace antes de publicar la release.

## Controles comprobados

- RLS habilitado en las tablas académicas y de identidad relevantes.
- Una identidad autenticada sin matrícula/rol no puede leer perfiles, matrículas, accesos, progreso, entregas, intentos, evaluaciones, expedientes ni certificados.
- Los dos usuarios Auth actuales tienen perfiles reales; los roles observados son 2 usuarios Admin y 1 de ellos además Alumna.
- Certificados emitidos son inmutables.
- La revocación se registra por separado.
- El certificado exige nombre confirmado.
- Email y teléfono no forman parte del certificado ni del verificador público.
- Los códigos de invitación nuevos usan 96 bits de entropía y tienen caducidad.
- Tras 5 intentos fallidos de activación se aplica bloqueo temporal.
- Los RPC de invitaciones comprueban rol Admin del programa.
- No quedan funciones privadas enlazadas a triggers con ejecución directa para `anon` o `authenticated`.
- `anon` no conserva ACL de relación pública; solo los cinco grants de columna mínimos de `academy_backend_meta`.
- `anon` no tiene `MAINTAIN` sobre tablas públicas.
- Security Advisor: únicamente queda el aviso de Leaked Password Protection.

## Aviso todavía abierto

### Leaked Password Protection

Supabase Auth indica que la protección contra contraseñas filtradas está desactivada. Debe activarse desde la configuración de Auth cuando se disponga de una acción compatible.

Referencia: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

## Rendimiento

El advisor detectó la FK `student_learning_journal_program_id_fkey` sin índice dedicado. Se añadió `student_learning_journal_program_id_idx`.

Los avisos de índices todavía no utilizados no se consideran por sí solos motivo para eliminarlos: la base tiene muy poco tráfico real y las estadísticas todavía no son representativas.

Las políticas RLS permisivas superpuestas se revisarán más adelante con pruebas de equivalencia antes de fusionarlas.

## Bloqueadores antes de producción

- retirar el acceso legacy del deploy público;
- QA visual y responsive;
- flujo real de dos cuentas: invitación → activación → login → progreso → entrega → evaluación;
- prueba de logout/cambio de cuenta para verificar la purga de caché;
- recuperación de contraseña real y redirect de email;
- completar responsable legal y email de privacidad;
- activar/revisar Leaked Password Protection.
