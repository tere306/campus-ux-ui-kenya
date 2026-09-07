# Edge Functions

Las funciones relevantes del campus se versionan aquí sin incluir valores de secretos ni ficheros `.env`.

## Activas y necesarias

### `activate-student-invite`

Endpoint público por diseño (`verify_jwt=false`) porque se usa antes de que la alumna tenga cuenta. Implementa validación propia mediante email + código de activación de un solo uso, contraseña, caducidad y bloqueo temporal. Usa privilegios de servidor únicamente desde el entorno Supabase para crear la cuenta y verificar que la matrícula quedó aceptada; los secretos nunca se versionan.

### `campus-development-preview`

Preview privado de desarrollo. Su mecanismo de acceso no se versiona para no copiar claves al repositorio.

## Retiradas / legacy

### `publish-frontend-release`

Retirada el 2026-09-07. Su versión anterior almacenaba releases/chunks en Supabase mediante privilegios de servidor, pero el frontend actual no la utiliza y la publicación objetivo es Netlify. Desde v2 responde HTTP 410 y no usa `service_role`.

### Otras funciones retiradas

`pioc-campus`, `pioc-publish-web`, `pioc-bootstrap-admin`, `pioc-issue-tere-link`, `pioc-set-tere-password`, `pioc-tere-access` y `patch-v9-admin-nav` están desplegadas como endpoints neutralizados/410.

Que una función figure como `ACTIVE` en Supabase solo significa que existe una versión desplegada; el código puede estar deliberadamente retirado y responder 410.

## Regla de seguridad

- no versionar secretos, claves de preview ni valores `service_role`;
- `verify_jwt=false` solo para endpoints que deban existir antes de iniciar sesión y que implementen controles propios, previews protegidos o endpoints legacy 410;
- cualquier helper administrativo nuevo debe exigir sesión real y rol del programa;
- no mantener publicadores privilegiados fuera del flujo real de release;
- los endpoints legacy permanecen neutralizados para que enlaces antiguos fallen explícitamente.
