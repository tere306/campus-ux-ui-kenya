# QA · paquete Netlify v79

Fecha: 2026-09-08

## Paquete final preparado

Archivo local: `campus-v79-netlify-deploy.zip`.

Contiene exactamente cuatro archivos en la raíz:

1. `index.html` — 739299 bytes — SHA-256 `0f04b92389e0201c59d3a03ba7ea0ad1e548759f725aece82290d2784828739b`
2. `campus-logo.webp` — 26734 bytes — SHA-256 `8feefe3bc225221ee2b15f725cbf597cc51e358b0ada19c95ab2cd0df87c74fd`
3. `_headers` — 908 bytes — SHA-256 `03813f216fb1d09651e995788eca1f9f04f1167df15dc1567d1195a94d2ccee8`
4. `_redirects` — 21 bytes — SHA-256 `49dbab673306115d5745c7a868b43085e54fa63cccd39a2b5b58f9491ce6f941`

ZIP — 231241 bytes — SHA-256 `7cc6163af407766bde48d381d84bef6335de10bd7565f14ca51daf0ad23ee69a`.

## Seguridad del paquete

`_headers` aplica una regla global con:

- no-store;
- nosniff;
- DENY para frame;
- no-referrer;
- Permissions Policy restrictiva;
- COOP/CORP;
- noindex;
- CSP limitada a recursos propios y al origen técnico necesario del servicio académico.

El frontend actual contiene CSS y JavaScript inline, por lo que la CSP conserva `'unsafe-inline'` en `script-src` y `style-src`. El resto de orígenes se mantiene restringido.

`_redirects` define una única rewrite SPA no forzada a `/index.html` con HTTP 200, de modo que archivos reales como `campus-logo.webp` siguen resolviendo normalmente.

## White-label incluido

- logo del Máster incluido como asset real;
- metadatos promocionales de hosting retirados;
- cadenas visibles de marca `Supabase`: 0 en el candidato local;
- cadenas visibles de marca `Netlify`: 0 en el candidato local;
- estados y ayudas operativas usan lenguaje Campus/expediente/servicio académico.

## Intento de publicación automática

La integración de Netlify devolvió el comando oficial de publicación para el site existente. Se intentó desde un directorio limpio que contenía exclusivamente los cuatro archivos de release, primero esperando el deploy y después con `--no-wait`.

Ambos intentos agotaron el tiempo del runtime local y no generaron un nuevo deploy. Se volvió a consultar el proyecto y se confirmó que producción continúa en `6a9fe602a0f119440cda97c1`.

No se considera publicado hasta que Netlify registre un nuevo deploy y su resumen confirme al menos:

- 1 regla de redirects procesada;
- 1 regla de headers procesada;
- `index.html` y `campus-logo.webp` presentes.

## GitHub

Las reglas `_headers` y `_redirects` están versionadas en `develop` bajo `deploy/netlify/`. `main` permanece sin cambios.
