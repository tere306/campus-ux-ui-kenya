# Auditoría de seguridad · 2026-09-07

## Alcance

Revisión del frontend de producción y desarrollo, permisos/RLS de Supabase, funciones RPC expuestas, almacenamiento local, invitaciones, certificados y despliegue Netlify.

## Hallazgos corregidos

### Frontend público legacy

El bundle actualmente publicado en Netlify conserva un acceso provisional/local embebido. El valor de la credencial no se versiona ni se documenta. Se ha preparado un hotfix exacto de producción sin ese acceso, pero no se ha publicado porque el deploy actual de Netlify es manual (`drop`) y no existe todavía una ruta segura de sustitución del archivo desde el conector.

Hotfix preparado:

- `production-security-hotfix-no-legacy-auth-index.html`
- versión 16
- SHA-256 `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`

### Exposición de snapshots de frontend

`academy_frontend_assets` y `academy_frontend_chunks` tenían lectura anónima. Se eliminó la política pública y los grants anónimos. Actualmente solo un usuario autenticado con rol Admin del programa puede leer estas copias mediante RLS.

### Superficie RPC anónima

Se revisaron todas las funciones `public`. Solo `verify_master_certificate_v2(text)` continúa siendo ejecutable por `anon`, de forma intencionada. El verificador legacy `verify_program_certificate(text)` no es ejecutable por `anon` ni por `authenticated`.

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

La sesión Auth usa `sessionStorage`. Desde frontend v54, la caché académica local se vincula a la cuenta autenticada y se elimina al cerrar sesión. Si existe una caché con propietario diferente, se descarta antes de hidratar la nueva cuenta. Esto reduce el riesgo de contaminación entre cuentas en un navegador compartido.

### Enlaces de invitación en preview

Desde v55 los enlaces compartibles se construyen siempre contra el dominio de producción y no a partir de `location.href`, evitando copiar accidentalmente la clave del preview. Desde v56 el Admin ve además un aviso cuando trabaja desde preview para no enviar el enlace antes de publicar la release.

## Controles comprobados

- RLS habilitado en las tablas académicas y de identidad relevantes.
- Una identidad autenticada sin matrícula/rol no puede leer perfiles, matrículas, accesos, progreso, entregas, intentos, evaluaciones, expedientes ni certificados.
- Certificados emitidos son inmutables.
- La revocación se registra por separado.
- El certificado exige nombre confirmado.
- Email y teléfono no forman parte del certificado ni del verificador público.
- Los códigos de invitación nuevos usan 96 bits de entropía y tienen caducidad.
- Tras 5 intentos fallidos de activación se aplica bloqueo temporal.
- Los RPC de invitaciones comprueban rol Admin del programa.

## Avisos todavía abiertos

### Leaked Password Protection

Supabase Auth indica que la protección contra contraseñas filtradas está desactivada. Debe activarse desde la configuración de Auth cuando se disponga de una acción compatible.

Referencia: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

### `admin_create_student_invite_v2`

Es el único RPC `public` con `SECURITY DEFINER` ejecutable por `authenticated`. Se mantiene así porque necesita consultar `auth.users`. Antes de consultar Auth o modificar una invitación valida que la sesión tenga rol Admin del programa. Los otros RPC de invitaciones se pasaron a `SECURITY INVOKER`.

Referencia: https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable

## Rendimiento

El advisor detectó la FK `student_learning_journal_program_id_fkey` sin índice dedicado. Se añadió `student_learning_journal_program_id_idx`.

Los avisos de índices todavía no utilizados no se consideran por sí solos motivo para eliminarlos: la base tiene muy poco tráfico real y las estadísticas todavía no son representativas.

Las políticas RLS permisivas superpuestas se revisarán más adelante con pruebas de equivalencia antes de fusionarlas.

## Bloqueadores antes de producción

- retirar el acceso legacy del deploy público;
- QA visual y responsive;
- flujo real de dos cuentas: invitación → activación → login → progreso → entrega → evaluación;
- prueba de logout/cambio de cuenta para verificar la purga de caché;
- recuperación de contraseña sobre la release nueva;
- completar responsable legal y email de privacidad;
- activar/revisar Leaked Password Protection.
