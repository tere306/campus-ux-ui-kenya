# Frontend releases y snapshots

Este archivo registra los artefactos de frontend conservados fuera del deploy público para evitar confundir producción, hotfixes y desarrollo.

## Producción actual

- Hosting: Netlify
- sitio: `fancy-cranachan-c98e89`
- deploy actual: `6a9e8ed5b2c90359c1b8081d`
- tipo de deploy: manual / `drop`
- release registrada en `academy_frontend_releases`: v14
- `source_sha256`: `7e97173d39f5cf70d6994c4ad7b83f20046cb319d1993ce9e3ab6e8`
- snapshot HTML exacto conservado en `academy_frontend_assets`: `production-snapshot-2026-09-07-index.html` v15
- SHA-256 del snapshot HTML: `1ec4fd29b3055b188d4d0a59f4187bbf2d015a53311aa141f3a859c44afd2738`

La producción actual conserva código legacy de autenticación provisional y no debe considerarse baseline de seguridad para nuevas releases.

## Hotfix de producción preparado

- asset: `production-security-hotfix-no-legacy-auth-index.html`
- versión: 16
- SHA-256: `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`
- objetivo: retirar exclusivamente autenticación legacy/local del bundle publicado, manteniendo el resto de la producción actual.
- estado: preparado, no desplegado.

## Desarrollo

El alias `development-current-index.html` siempre debe apuntar al artefacto de desarrollo más reciente validado estructuralmente.

### v53

- asset: `development-14v-dynamic-lesson-sync-index.html`
- SHA-256: `e46631cb09cb81a628a0fef1985bf2795ee7b3e065cf7a2aa64ac45c0b909686`
- progreso e identidad por UUID, sin gates por nombres concretos.

### v54

- asset: `development-14w-user-scoped-local-cache-index.html`
- SHA-256: `425ab152fae89209a9efabd1d9f34c9f912ebab49a2819ac58f0785fe4bdbf21`
- caché local asociada a la cuenta y purga al cerrar sesión.

### v55

- asset: `development-14w-safe-invite-links-index.html`
- SHA-256: `74b308ae98cccffcdb1b2c05a1af5876cfeca767f1103f723d9f50f00147eff2`
- los enlaces de invitación desde preview apuntan al dominio de producción y no propagan la clave del preview.

### v56

- asset: `development-14w-preview-invite-warning-index.html`
- SHA-256: `8a068f7ecf9804dcca1190ba62eeeb55f2df03f2210cb01e542bf272997aebbb`
- advertencia visual para no compartir invitaciones antes de publicar la release.

### v57

- asset: `development-14w-invite-24hex-only-index.html`
- SHA-256: `dcc85e599801d1f5f8e2eedee1c770bc0363f8c4fe9704457154e02332b80016`
- frontend y endpoint de activación alineados en códigos exclusivamente de 24 hex.

### v58

- asset: `development-14x-explicit-button-types-index.html`
- SHA-256: `5f8092002da6d6c114ba9c1a5c361664294c7af9d7551b791b3d3f88ffe99d59`
- 66 botones pasan a declarar `type="button"`; se conservan los 5 submits reales.

### v59

- asset: `development-14x-search-accessibility-index.html`
- SHA-256: `5e7863558a430923e5db1a4b3dabbb089410f2c65b2e7d6b6ca4152e56722f83`
- nombres accesibles explícitos para `librarySearch` y `reviewSearch`.

### v60

- asset: `development-14x-escape-admin-session-identity-index.html`
- SHA-256: `60112dcbbd96c3d1c1a9774ce2949191ad632561897843419529e0de500f07fb`
- escape de identidad y versión curricular al renderizar el detalle de sesión en Ajustes Admin.

### v61

- asset: `development-14x-safe-resource-rendering-index.html`
- SHA-256: `8447d0121611ece5b1bca830ed6efd00d7dbdf242cc459a15a22cee1122af04f`
- títulos/descripciones de recursos escapados y enlaces normalizados mediante `safeHttpHref`.

### v62

- asset: `development-14x-escape-student-admin-views-index.html`
- SHA-256: `75f9b9c35ceb1aa31882184e027cdefa4429f372ebebf51f3f5728ee7701935d`
- identidad de alumnas escapada en cola, tarjetas, evaluaciones y drawers administrativos.

### v63

- asset: `development-14x-safe-page-headings-index.html`
- SHA-256: `a843fb45070c45704cb7288cdcfb2508ba4ad0ce9e2493013cb13262c4cef50f`
- `head()` escapa eyebrow, título y subtítulo; el slot de acción sigue admitiendo markup controlado.

### v64

- asset: `development-14x-operational-state-alignment-index.html`
- alias: `development-current-index.html`
- SHA-256: `6acbca1ff4cdc0b9e5c513a497e77555c9c0117890598a1d551eac9981d66063`
- tamaño: 711.367 caracteres.
- el estado embebido del currículo queda alineado con Supabase (`published`).
- se retira copy operativo obsoleto sobre login/admin provisional y se aclara la dependencia real de la copia local.
- QA estructural: 143/143 botones, 5/5 formularios, cierre HTML correcto; solo queda `status:'draft'` en el estado real de un borrador de entrega.
- estado: desarrollo actual.

## Regla de publicación

No promover a producción únicamente por hash o QA estructural. Antes de publicar debe pasar QA real en navegador, móvil y escritorio, incluyendo autenticación, cambio de rol, logout, perfil, invitación/activación, progreso, entregas, evaluaciones, aislamiento entre cuentas y recuperación de contraseña.
