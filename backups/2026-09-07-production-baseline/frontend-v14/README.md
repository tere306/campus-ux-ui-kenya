# Frontend production baseline — 2026-09-07

Copia exacta del frontend v14 almacenado en Supabase como release actual en el momento de crear el baseline.

## Integridad

- Release: `14`
- Partes Base64: `12`
- Caracteres Base64 totales: `44556`
- SHA-256 del HTML fuente: `7e97173d39f5cf70d6994c4ad7b83f20046cb319d1993ce9e3b58a0e1e3ab6e8`
- SHA-256 del GZIP: `d330b2bcf4605340756ba48e6b6ba17537cae139a80c6e57f5984eaf9725dabf`

## Restaurar

Desde la raíz del repositorio:

```bash
python scripts/restore_frontend_backup.py \
  backups/2026-09-07-production-baseline/frontend-v14 \
  restored-index.html
```

El script concatena `part-01.b64` a `part-12.b64`, decodifica Base64, descomprime GZIP y valida ambos hashes.

Esta carpeta es una **copia congelada**. No editar sus partes para desarrollar nuevas funcionalidades.
