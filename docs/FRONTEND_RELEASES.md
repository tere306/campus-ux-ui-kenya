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

- asset histórico: `development-14v-dynamic-lesson-sync-index.html`
- SHA-256: `e46631cb09cb81a628a0fef1985bf2795ee7b3e065cf7a2aa64ac45c0b909686`
- cambio principal: progreso e identidad por UUID, sin gates por nombres concretos.

### v54

- asset histórico: `development-14w-user-scoped-local-cache-index.html`
- SHA-256: `425ab152fae89209a9efabd1d9f34c9f912ebab49a2819ac58f0785fe4bdbf21`
- cambio principal: caché local asociada a la cuenta y purga al cerrar sesión.

### v55

- asset histórico: `development-14w-safe-invite-links-index.html`
- SHA-256: `74b308ae98cccffcdb1b2c05a1af5876cfeca767f1103f723d9f50f00147eff2`
- cambio principal: enlaces compartibles de invitación apuntan al dominio de producción y no incluyen la URL/clave del preview.

### v56

- asset histórico: `development-14w-preview-invite-warning-index.html`
- SHA-256: `8a068f7ecf9804dcca1190ba62eeeb55f2df03f2210cb01e542bf272997aebbb`
- cambio principal: advertencia visual en preview para no compartir enlaces de activación antes de publicar la release.

### v57

- asset histórico: `development-14w-invite-24hex-only-index.html`
- alias: `development-current-index.html`
- SHA-256: `dcc85e599801d1f5f8e2eedee1c770bc0363f8c4fe9704457154e02332b80016`
- tamaño: 710.095 caracteres.
- cambio principal: el frontend deja de aceptar el formato legacy de invitación de 12 caracteres y queda alineado con el endpoint v5, que solo acepta códigos hexadecimales de 24 caracteres.
- QA estructural: 143/143 botones, 5/5 formularios, cierre HTML correcto y flujo de recuperación de contraseña presente.
- estado: desarrollo actual.

## Regla de publicación

No promover a producción únicamente por hash o QA estructural. Antes de publicar debe pasar QA real en navegador, móvil y escritorio, incluyendo autenticación, cambio de rol, logout, perfil, invitación/activación, progreso, entregas, evaluaciones, aislamiento entre cuentas y recuperación de contraseña.
