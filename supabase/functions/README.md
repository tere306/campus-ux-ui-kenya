# Edge Functions

Las funciones relevantes del campus se versionan aquí sin incluir valores de secretos ni ficheros `.env`.

## Activas y necesarias

### `activate-student-invite`

Endpoint público por diseño (`verify_jwt=false`) porque se usa antes de que la alumna tenga cuenta. Implementa autenticación propia mediante email + código de activación de un solo uso, validación de contraseña, caducidad y bloqueo temporal tras intentos fallidos. Usa `SUPABASE_SERVICE_ROLE_KEY` exclusivamente desde el entorno de Supabase; el valor nunca se versiona.

### `publish-frontend-release`

Función administrativa existente en Supabase con `verify_jwt=true`. No se usa para desplegar Netlify; gestiona el almacenamiento de releases/chunks en Supabase.

### `campus-development-preview`

Preview privado de desarrollo. Su mecanismo de acceso no se versiona aquí para no copiar claves de preview al repositorio.

## Legacy retirado

`pioc-campus` fue retirado el 2026-09-07 y responde HTTP 410. La versión anterior era un publicador/redirect antiguo y no forma parte de la arquitectura Netlify actual.

También permanecen como endpoints deshabilitados HTTP 410 otros helpers históricos (`pioc-bootstrap-admin`, `pioc-issue-tere-link`, `pioc-set-tere-password`, `pioc-publish-web`, `patch-v9-admin-nav`, y el acceso especial legacy previamente retirado). Que la función figure como `ACTIVE` en Supabase solo significa que hay una versión desplegada; el código puede estar deliberadamente retirado y responder 410.

## Regla de seguridad

- no versionar secretos, claves de preview ni `service_role`;
- `verify_jwt=false` solo para endpoints que deban existir antes de iniciar sesión y que implementen controles propios;
- cualquier helper administrativo nuevo debe exigir sesión real y rol del programa;
- los endpoints legacy se mantienen en 410 para que antiguos enlaces fallen de forma explícita en vez de conservar rutas privilegiadas.
