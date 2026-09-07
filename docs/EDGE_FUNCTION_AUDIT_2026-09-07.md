# Auditoría de Edge Functions · 2026-09-07

Se revisó la lista activa y el código de los endpoints históricos/relevantes de Supabase.

## Resultado

### `pioc-campus`

**Retirado durante esta auditoría.**

La versión anterior aceptaba GET sin JWT, obtenía un artefacto antiguo con privilegios de servidor, lo publicaba en Storage y redirigía al fichero público. La arquitectura actual usa Netlify y el frontend v56 no contiene referencias a este endpoint, por lo que mantener ese publicador histórico ampliaba innecesariamente la superficie de ataque.

Desde la versión 7 responde HTTP `410 Gone`, `no-store`, y no ejecuta operaciones de Storage ni usa credenciales privilegiadas.

El código retirado se versiona en `supabase/functions/pioc-campus/index.ts` como endpoint 410 para que el estado deseado sea explícito.

### Endpoints históricos ya retirados

Se comprobó que los siguientes helpers responden con lógica deshabilitada/410 en sus versiones actuales:

- `pioc-bootstrap-admin`
- `pioc-issue-tere-link`
- `pioc-set-tere-password`
- `pioc-publish-web`
- `patch-v9-admin-nav`
- acceso especial legacy del campus previamente retirado

Que Supabase muestre `status=ACTIVE` significa que existe una versión desplegada, no que la antigua capacidad privilegiada siga activa.

### `activate-student-invite`

Debe ser público antes de autenticación (`verify_jwt=false`) y por tanto aplica controles propios:

- solo POST/OPTIONS;
- CORS limitado a producción y al origen Supabase del preview;
- código aceptado en formato legacy 12 hex o actual 24 hex;
- contraseña mínima de 12 caracteres y al menos 3 clases;
- hash SHA-256 del código almacenado en DB;
- caducidad del código;
- bloqueo 15 minutos tras 5 fallos;
- código invalidado tras activación;
- respuestas `no-store` y `nosniff`;
- no devuelve `user_id` ni credenciales de servidor.

El código actual se ha copiado a `supabase/functions/activate-student-invite/index.ts` sin secretos.

Riesgo residual aceptado para beta: un tercero que conozca el correo de una invitación puede provocar temporalmente el bloqueo de activación mediante intentos fallidos. No permite tomar la cuenta ni adivinar un código de 96 bits, pero debe observarse si se abre el producto a un volumen mayor.

### `publish-frontend-release`

`verify_jwt=true`. Además valida sesión y rol administrativo antes de utilizar el `service_role` del entorno para escribir releases/chunks. No despliega Netlify y no debe confundirse con el flujo de publicación del sitio público.

### `campus-development-preview`

Público a nivel JWT porque usa un mecanismo de acceso específico de preview. La clave de preview no se versiona en GitHub. El frontend v55+ ya no reutiliza `location.href` al generar enlaces de invitación, evitando propagar la clave del preview a alumnas.

## Regla para producción

Antes de publicar, volver a listar Edge Functions y comprobar que cualquier función con `verify_jwt=false` corresponde a uno de estos casos:

1. endpoint deliberadamente público con autenticación/validación propia;
2. preview protegido por mecanismo específico;
3. endpoint legacy retirado que solo responde 410.

No deben quedar publicadores administrativos anónimos operativos.
