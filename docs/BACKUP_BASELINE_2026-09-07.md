# Baseline de producción — 2026-09-07

## Frontend
- Host: Netlify
- Sitio: `fancy-cranachan-c98e89`
- Site ID: `a2633c74-fe54-4394-8f16-f1083ac6e8d6`
- Deploy identificado: `6a9e8ed5b2c90359c1b8081d`
- Tipo de deploy: manual
- SHA-256 del HTML servido en la captura: `1ec4fd29b3055b188d4d0a59f4187bbf2d015a53311aa141f3a859c44afd2738`
- Longitud observada del HTML: 666637 caracteres

### Copia de seguridad exacta
La producción actual fue capturada antes de continuar los cambios y guardada también en Supabase:

- tabla: `public.academy_frontend_assets`
- slug: `production-snapshot-2026-09-07-index.html`
- version: `15`
- sha256: `1ec4fd29b3055b188d4d0a59f4187bbf2d015a53311aa141f3a859c44afd2738`

No modificar ni borrar ese asset durante las fases 14S/14T.

## Backend
- Supabase project: `pioc-campus`
- Project ref: `azacjdyxgknfqarcemhi`
- Product ID: `master-uxui-web`
- Schema version: `12`
- Curriculum version: `4.14D-12x48-full`
- Estado: `active`

## Release frontend almacenada en Supabase
`academy_frontend_releases` marca como actual:
- versión 14
- 12 chunks
- gzip sha256: `d330b2bcf4605340756ba48e6b6ba17537cae139a80c6e57f5984eaf9725dabf`
- source sha256: `7e97173d39f5cf70d6994c4ad7b83f20046cb319d1993ce9e3b58a0e1e3ab6e8`
- notas: `Campus v14 · hotfix login Auth sin deadlock`

## Regla de rollback
Ante una regresión de frontend, recuperar primero el snapshot exacto indicado arriba y verificar SHA antes de redesplegar.

Ante una regresión de base de datos, no improvisar SQL destructivo: revisar historial de migraciones y preparar una migración correctiva explícita.
