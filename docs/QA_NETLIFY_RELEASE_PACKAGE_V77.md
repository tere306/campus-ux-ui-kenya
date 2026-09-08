# QA · paquete Netlify v77

Fecha: 2026-09-08

## Objetivo

Preparar una publicación completa del Campus sin repetir el deploy de un único `index.html`, que dejó fuera las reglas de headers y redirects.

## Fuente académica

Alias Supabase: `development-current-index.html`.

- versión: **77**
- caracteres: **730086**
- SHA-256 calculado en PostgreSQL sobre UTF-8: `e2c40b6e8ac34a7a2c29ddefc2775b1cb90a0c2973e4244bd77984e4f9400719`
- se eliminaron del `<head>` el comentario promocional de hosting y los metadatos `hosting-provider` / `netlify-deploy`.
- se conserva la URL de producción en el runtime porque la recuperación de contraseña necesita un origen autorizado estable; no se expone como copy de Alumna.

## Paquete de despliegue preparado

ZIP local: `campus-v77-netlify-deploy.zip`.

Contiene exactamente cuatro archivos en raíz:

1. `index.html` — 739355 bytes — SHA-256 `94d0d7ac5ba03fc92294c383ee917e434a31cc4aac3143d596803f8b29cad60a`
2. `campus-logo.webp` — 26734 bytes — SHA-256 `8feefe3bc225221ee2b15f725cbf597cc51e358b0ada19c95ab2cd0df87c74fd`
3. `_headers` — 908 bytes — SHA-256 `03813f216fb1d09651e995788eca1f9f04f1167df15dc1567d1195a94d2ccee8`
4. `_redirects` — 21 bytes — SHA-256 `49dbab673306115d5745c7a868b43085e54fa63cccd39a2b5b58f9491ce6f941`

ZIP: 231343 bytes — SHA-256 `e7282be3a30404a21a1134e4b0540f62ac0f617e2ef600763f985ce32d94ce5f`.

## Headers

No se inventó el contenido histórico del `_headers` antiguo. Se preparó una nueva regla explícita para las dependencias actuales del Campus:

- `no-store` / no cache de la aplicación;
- `nosniff`;
- anti-frame;
- `no-referrer`;
- Permissions Policy restrictiva;
- COOP/CORP;
- `X-Robots-Tag` noindex;
- CSP con `default-src 'self'`, sin objetos ni frames, formulario limitado a self, y conexión/imagen autorizada únicamente al proyecto Supabase además de recursos locales/data/blob necesarios por el avatar.

El frontend actual usa CSS y JavaScript inline, por lo que `script-src` y `style-src` mantienen `'unsafe-inline'`. Endurecer esto con hashes/nonces requeriría separar el bundle y se trata como mejora posterior, no como cambio seguro de última hora.

## Redirect

`_redirects` contiene una única rewrite SPA a `/index.html` con HTTP 200. Los archivos existentes (por ejemplo `campus-logo.webp`) siguen servidos como archivos estáticos; la regla no se marca como force.

## Verificación estática

- JavaScript de v77: `node --check` PASS.
- `service_role` en frontend: 0.
- `<iframe>`: 0.
- metadatos promocionales de hosting eliminados: PASS.
- referencia a `campus-logo.webp` y archivo real presente: PASS.
- ZIP contiene únicamente los cuatro archivos de release: PASS.

## GitHub

Se versionan en `develop`:

- `deploy/netlify/_headers`
- `deploy/netlify/_redirects`
- este QA.

`main` no se modifica.

## Estado de publicación

Se solicitó a la integración de Netlify el flujo oficial de deploy para el site existente `a2633c74-fe54-4394-8f16-f1083ac6e8d6`. El runtime local no pudo completar el comando de subida dentro del tiempo disponible; se comprobó después que el deploy actual seguía siendo `6a9fe602a0f119440cda97c1`.

Por tanto, **producción permanece sin cambios**. El siguiente deploy debe hacerse con el ZIP completo y, después, verificar en Netlify que se procesan al menos 1 regla de headers y 1 regla de redirects antes de continuar con QA real.
