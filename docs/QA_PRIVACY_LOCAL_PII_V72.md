# QA privacidad y PII local · v72

Fecha: 2026-09-08

## Objetivo

Revisar exposición accidental de datos personales y credenciales en navegador, URLs, logs y caché local del campus de desarrollo.

## Baseline

- Asset estable: `development-current-index.html`
- Versión revisada tras hardening: **72**
- SHA-256: `2e42cb4a5330ce150c86327a3888ddaeaba4317311e4e787ab229924fe82b851`

## Hallazgos

### Tokens Auth

- Access/refresh tokens permanecen en `sessionStorage`, no en `localStorage`.
- Un refresh fallido elimina la sesión local.
- Logout elimina la sesión local y purga caché académica sensible.
- Recovery inválido/caducado elimina la sesión temporal y limpia credenciales de la URL.

### Consola

Las únicas apariciones de `console.log` son contenido didáctico del curso. No hay logging runtime de tokens, email, teléfono, entregas o payloads Auth.

### URLs

- Recovery usa un redirect fijo al origen final, no un origen controlado por entrada.
- `token_hash`, `type` y fragmentos Auth se limpian mediante `history.replaceState` una vez procesados o cuando el recovery falla cerrado.
- Las invitaciones transportan email/código en fragmento y el fragmento se elimina inmediatamente al abrir el flujo de activación. El fragmento no se envía al servidor como parte de la petición HTTP, pero sigue siendo sensible mientras está visible/compartido y debe tratarse como credencial temporal.

### Caché académica local

El campus conserva en `localStorage` una copia de recuperación del estado académico (progreso, borradores, feedback y backups de conflictos). Esta persistencia es intencionada para recuperación local y se purga en cambio de cuenta/logout.

No se elimina este diseño en v72 porque hacerlo rompería recuperación offline y resolución de conflictos. El riesgo residual se limita al dispositivo/navegador mientras la cuenta permanece activa.

## Cambio v72: minimización de email Auth persistido

Se detectó duplicación innecesaria del email Auth en `state.students`, que se serializa en `localStorage`.

El email no es necesario para autorización, progreso, certificados ni el directorio local. La fuente real ya es `runtimeAuth.profile` mientras la sesión está activa.

v72 cambia el directorio local para:

- dejar de copiar `identity.user.email` a `state.students`;
- guardar `email: ''` para la identidad remota local;
- limpiar `existing.email=''` al reconciliar una identidad ya existente, eliminando PII heredada de versiones anteriores.

El nombre de presentación y UUID siguen disponibles para continuidad local.

## Datos que permanecen solo en memoria de sesión remota

- email Auth de la cuenta;
- teléfono privado del perfil;
- perfil remoto completo;
- perfiles remotos cargados para Admin.

Estos objetos runtime se vacían en logout y no forman parte del estado serializado por este cambio.

## Retest estático v72

- 143 `<button>` / 143 `</button>`: PASS
- 5 `<form>` / 5 `</form>`: PASS
- copia de `identity.user.email` al directorio local: ausente
- email de identidad self en directorio local: vacío
- saneado de email legacy en reconciliación: presente
- `sessionStorage` Auth: preservado
- recovery: preservado
- logout/revocación v70: preservado

## Riesgo residual / pendiente real

1. Validar en navegador real que cambio de cuenta y logout purgan el almacenamiento como está previsto.
2. Considerar política UX para equipos compartidos (recomendar logout al terminar).
3. Mantener enlaces de invitación como credenciales de un solo uso y no registrarlos en analytics/logs externos.
4. Completar aviso de privacidad con responsable legal y email reales antes de alumnado real.
5. Revisar configuración de Auth Audit Logs/retención desde Dashboard cuando exista acceso administrativo compatible.

## Veredicto

**PASS con hardening aplicado.** v72 reduce PII persistida sin romper recuperación académica local ni flujos Auth.

No se ha modificado Netlify production, `main` ni se ha publicado release final.
