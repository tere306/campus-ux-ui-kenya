# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14.
- Producción todavía no se ha sustituido durante los cambios de preproducción.
- La auditoría detectó que el bundle publicado conserva un acceso legacy/local embebido. La credencial no se documenta ni se versiona.
- Hotfix preparado sobre la producción actual, sin incorporar el resto de cambios de desarrollo:
  - asset: `production-security-hotfix-no-legacy-auth-index.html`
  - versión: 16
  - SHA-256: `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`
- No se ha desplegado el hotfix: el sitio Netlify actual es un deploy manual (`drop`) y no existe todavía una operación segura de sustitución del archivo desde el conector disponible.

## Desarrollo actual

Alias estable en Supabase:

`development-current-index.html`

Estado actual:

- versión de desarrollo: **59**
- SHA-256: `5e7863558a430923e5db1a4b3dabbb089410f2c65b2e7d6b6ca4152e56722f83`
- v53: identidad dinámica y progreso por UUID.
- v54: caché local asociada a la cuenta y purga al cerrar sesión.
- v55: enlaces de invitación seguros desde preview.
- v56: advertencia de no compartir invitaciones desde preview antes de publicar.
- v57: formato de invitación exclusivamente 24 hex en frontend y backend.
- v58: todos los botones declaran tipo explícito; se eliminan submits implícitos accidentales.
- v59: los dos buscadores que dependían de placeholder reciben nombre accesible explícito.

Existe una Edge Function de preview separada de producción. El preview está protegido por clave, `noindex`, `no-store`, `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`, `Permissions-Policy` restrictiva, `Cross-Origin-Resource-Policy: same-origin` y CSP específica. La clave de preview se rotó durante la auditoría y no se versiona.

## Cambios acumulados principales

### Navegación y UX

- `← Volver al programa` contextual y determinista.
- Restauración de posición al volver desde un módulo al Programa.
- Un módulo en curso continúa por la primera clase pendiente.
- CTAs contextuales: empezar, continuar, revisar, preparar entrega, ver entrega o revisar feedback.
- Mi perfil integrado en la tarjeta inferior izquierda de escritorio y avatar compacto en móvil.
- Microtransiciones breves y funcionales; `prefers-reduced-motion` respetado.
- No se utiliza `history.back()` para la navegación contextual.

### Ficha del alumno y certificación

- Ficha dentro de Mi perfil.
- Nombre + apellidos para certificado; segundo apellido opcional.
- Sin DNI/NIE/pasaporte.
- Teléfono opcional y privado.
- Confirmación explícita del nombre y anulación automática si cambia.
- Emisión bloqueada en backend si la ficha no está confirmada.
- Snapshot del certificado sin email/teléfono.
- Verificador público `verify_master_certificate_v2` limitado a nombre, programa, finalización, estado y código.
- Verificador legacy deshabilitado.

### Invitaciones de alumnas

- Alta gestionada desde Admin.
- Códigos de activación de 24 caracteres hexadecimales (96 bits).
- Caducidad por defecto 7 días.
- Bloqueo 15 minutos tras 5 intentos fallidos.
- Contraseña de activación: mínimo 12 caracteres y 3 tipos de caracteres; máximo 256.
- Admin puede crear, regenerar, cancelar y copiar enlace de activación.
- Una invitación aceptada crea matrícula real y el alumnado aparece por UUID.
- RLS acotada al rol Admin del programa.
- El endpoint público no devuelve `user_id` ni detalles innecesarios.
- La matrícula exige un hash de invitación validado por la Edge Function, no mera coincidencia de email.
- Si la cuenta Auth se crea pero la matrícula no queda aceptada, se elimina para evitar cuentas huérfanas.

### Identidad dinámica y progreso

- Sin gates funcionales por nombres concretos.
- Sincronización de clases mediante `user_id` real de Supabase.
- Backups de progreso registran el UUID activo.
- Reconciliación local/remota sobre la alumna autenticada.
- Gate curricular genérico para cualquier cuenta Alumna.

### Privacidad de caché local

- Sesión Auth en `sessionStorage`.
- Caché académica asociada al usuario autenticado.
- Cambio de propietario descarta la caché anterior antes de hidratar la nueva cuenta.
- Logout elimina estado y backups locales sensibles.
- Backend remoto como autoridad académica.

### Autenticación y seguridad

- Desarrollo: solo Supabase Auth real.
- Sin login Admin local/legacy.
- Sin `service_role` en frontend.
- Directorio Admin desde matrículas reales.
- Publicadores y accesos especiales legacy deshabilitados.
- Bucket histórico `pioc-web` privado.
- Trigger legacy de allowlist eliminado.
- Funciones privadas usadas únicamente como triggers sin ejecución directa para `anon`/`authenticated`.
- Única función pública ejecutable por `anon`: `verify_master_certificate_v2(text)`.
- Una cuenta sin invitación/matrícula/rol no obtiene acceso académico.
- Assets, chunks y manifests de frontend sin lectura anónima.
- `anon`: 0 privilegios a nivel de tabla, 0 escritura, 0 secuencias, 0 `MAINTAIN`; únicamente 5 SELECT de columna mínimos en `academy_backend_meta`.
- Defaults de objetos nuevos creados por migraciones `postgres` endurecidos para no conceder permisos anónimos automáticamente.

### Recuperación de contraseña

- Solicitud contra `/auth/v1/recover`.
- Redirect fijado al origen de producción.
- Soporte de `token_hash` / `type=recovery` y sesión recovery.
- Nueva contraseña con mínimo 12 caracteres y 3 clases.
- Logout tras cambio y nuevo login obligatorio.
- Prueba real del correo/redirect pendiente de QA en navegador.

## QA técnico ejecutado

### Asset v59

- cierre HTML: PASS
- 0 botones sin tipo explícito: PASS
- 5 botones de submit reales conservados: PASS
- 0 campos sin `id` o nombre accesible: PASS
- los dos buscadores sin etiqueta visible tienen `aria-label`: PASS
- enlaces `target="_blank"` con `noopener`: PASS
- sin `history.back()`: PASS
- invitaciones solo 24 hex: PASS
- flujo de recuperación presente: PASS
- sin `service_role`: PASS
- sincronización por UUID: PASS
- caché local aislada por propietario: PASS

### Seguridad / aislamiento

- todas las tablas base del esquema `public`: RLS habilitado.
- identidad sin permisos: 0 perfiles, matrículas, accesos, progreso, entregas, intentos, evaluaciones, expedientes y certificados visibles.
- verificador inválido: únicamente `valid:false / status:not_found`.
- constructor de certificado: sin email/teléfono y exige nombre confirmado.
- frontend assets/chunks/manifests públicos: cerrado.
- `anon`: 0 privilegios a nivel de tabla; 5 privilegios de columna mínimos en `academy_backend_meta`.
- triggers privados directamente ejecutables por `anon`/`authenticated`: 0.
- onboarding ligado a hash validado de servicio.

## Supabase Advisors

Seguridad pendiente:

- `Leaked Password Protection`: desactivado; requiere configuración de Auth fuera de las acciones disponibles en este conector.

El Security Advisor no devuelve actualmente ningún otro aviso de función/DDL, aparte de Leaked Password Protection.

Rendimiento:

- FK de `student_learning_journal.program_id` ya cubierta por índice.
- No se eliminan índices marcados como no usados mientras el tráfico no sea representativo.
- No se fusionan políticas RLS permisivas sin QA específico de equivalencia.

## Estimación de preproducción

- backend/seguridad automática: ~95%
- frontend funcional/QA estático: ~90%
- avance global estimado: ~80–85%

El tramo restante es pequeño en volumen, pero crítico: concentra QA real de navegador, segunda cuenta y publicación.

## Pendiente antes de producción

1. QA visual y responsive en navegador.
2. Login, F5, logout, Alumna, Admin y Alumna+Admin.
3. Invitación real de segunda cuenta y primer login.
4. Entrega → evaluación → feedback → desbloqueo con dos cuentas.
5. Cambio de cuenta en un mismo navegador para validar purga de caché.
6. Recuperación de contraseña real y redirect de email.
7. Responsable legal y email de privacidad reales.
8. Activar/revisar Leaked Password Protection.
9. Sustituir el deploy público únicamente después de lo anterior y ejecutar smoke test.
10. Fusionar a `main` solo tras validar la release.
