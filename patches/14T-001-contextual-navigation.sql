-- 14T-001 · Navegación contextual del aula
-- Aplica el primer pulido de navegación sobre una COPIA del snapshot de producción.
-- No sobrescribe producción.

with src as (
  select content
  from academy_frontend_assets
  where slug='production-snapshot-2026-09-07-index.html'
), p1 as (
  select replace(
    content,
    '.lesson-context .btn{padding:8px 11px}',
    '.lesson-context .btn{padding:8px 11px}.context-back{appearance:none;border:0;background:transparent;color:var(--muted);display:inline-flex;align-items:center;gap:8px;padding:7px 2px;margin:0 0 10px;font-weight:800;min-height:44px;cursor:pointer;transition:color .16s ease}.context-back span:first-child{transition:transform .16s ease}.context-back:hover{color:var(--ink)}.context-back:hover span:first-child{transform:translateX(-2px)}'
  ) content
  from src
), p2 as (
  select replace(
    content,
    'return `${head(`Módulo ${m.id}`',
    'return `<button type="button" class="context-back" data-page="program" aria-label="Volver al programa"><span aria-hidden="true">←</span><span>Volver al programa</span></button>${head(`Módulo ${m.id}`'
  ) content
  from p1
), p3 as (
  select replace(
    content,
    '<button class="btn ghost" data-page="program">Programa</button>',
    ''
  ) content
  from p2
), final as (
  select content from p3
)
insert into academy_frontend_assets(
  slug, content, content_type, sha256, version, updated_at
)
select
  'development-14t-navigation-index.html',
  content,
  'text/html; charset=utf-8',
  encode(digest(convert_to(content,'UTF8'),'sha256'),'hex'),
  16,
  now()
from final
on conflict (slug) do update set
  content=excluded.content,
  content_type=excluded.content_type,
  sha256=excluded.sha256,
  version=excluded.version,
  updated_at=excluded.updated_at;

-- Resultado observado el 2026-09-07:
-- slug: development-14t-navigation-index.html
-- chars: 667139
-- bytes: 676108
-- sha256: 087576fba15ab4994f2e151ff16e27927f20e3c9594918cd6229c1861a38ce3a
--
-- UX resultante:
-- - botón "← Volver al programa" encima de la cabecera del módulo;
-- - destino determinista: data-page="program";
-- - se elimina el botón redundante "Programa" de la derecha;
-- - se conserva el badge de progreso;
-- - hover de 160 ms y desplazamiento de flecha de 2 px;
-- - el reduced-motion global existente neutraliza la transición.
