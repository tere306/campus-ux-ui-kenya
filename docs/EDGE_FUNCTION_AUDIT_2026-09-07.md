# Auditoría de Edge Functions · 2026-09-07

Se revisó la lista desplegada y el código de los endpoints históricos/relevantes de Supabase.

## Resultado

### `activate-student-invite`

Endpoint deliberadamente público antes de autenticación (`verify_jwt=false`) y con controles propios:

- solo POST/OPTIONS;
- CORS limitado a los orígenes previstos;
- código exclusivamente de 24 hexadecimales (96 bits);
- payload máximo de 4 KiB;
- validación de email;
- contraseña de 12–256 caracteres y al menos 3 clases;
- hash SHA-256 del código y comparación segura;
- caducidad y bloqueo temporal tras 5 fallos;
- matrícula ligada al hash validado mediante `app_metadata`;
- eliminación de la cuenta recién creada si la matrícula no termina aceptada;
- respuestas `no-store`, `nosniff`, `no-referrer` y CORP;
- sin devolución de `user_id` ni credenciales de servidor.

Versión auditada: v5. El código actual está versionado en `supabase/functions/activate-student-invite/index.ts` sin secretos.

Riesgo residual para beta: quien conozca el email de una invitación puede provocar temporalmente el bloqueo de activación mediante intentos fallidos. No permite tomar la cuenta ni hace viable adivinar un código de 96 bits; debe vigilarse si aumenta el volumen.

### `campus-development-preview`

Público a nivel JWT porque usa un mecanismo de acceso específico de preview. La clave se rotó, no se versiona y el frontend no la propaga al crear enlaces de invitación. Mantiene `noindex`, `no-store`, CSP, anti-frame, `nosniff`, `no-referrer`, Permissions-Policy y CORP.

### Publicadores retirados

`pioc-campus`, `pioc-publish-web` y ahora también `publish-frontend-release` están retirados.

- `pioc-campus`: HTTP 410; ya no publica/reconstruye el campus desde Storage ni usa privilegios de servidor.
- `pioc-publish-web`: HTTP 410.
- `publish-frontend-release`: desde v2 responde HTTP 410, conserva `verify_jwt=true` y ya no usa `service_role`, chunks ni manifests. La publicación objetivo del sitio es Netlify.

El frontend actual no referencia ninguno de esos publicadores.

### Helpers históricos neutralizados

Se comprobó que responden con lógica deshabilitada/410:

- `pioc-bootstrap-admin`
- `pioc-issue-tere-link`
- `pioc-set-tere-password`
- `pioc-tere-access`
- `patch-v9-admin-nav`

Que Supabase muestre `status=ACTIVE` significa que existe una versión desplegada, no que la capacidad histórica continúe operativa.

## Superficie `verify_jwt=false`

Antes de publicar, la lista debe volver a comprobarse. Una función sin JWT solo es aceptable si encaja en uno de estos casos:

1. endpoint deliberadamente público con validación/autenticación propia, como `activate-student-invite`;
2. preview protegido por mecanismo específico;
3. endpoint legacy neutralizado que responde 410.

No deben quedar publicadores administrativos anónimos ni funciones con `service_role` operativo que no formen parte de un flujo necesario y auditado.
