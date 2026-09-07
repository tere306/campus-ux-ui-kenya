drop policy if exists academy_frontend_assets_public_read on public.academy_frontend_assets;
drop policy if exists academy_frontend_chunks_public_read on public.academy_frontend_chunks;

revoke all on table public.academy_frontend_assets from anon, authenticated;
revoke all on table public.academy_frontend_chunks from anon, authenticated;

grant select on table public.academy_frontend_assets to authenticated;
grant select on table public.academy_frontend_chunks to authenticated;

create policy academy_frontend_assets_admin_read
on public.academy_frontend_assets
for select
to authenticated
using (
  exists (
    select 1 from public.program_roles pr
    where pr.user_id = (select auth.uid())
      and pr.role = 'admin'
  )
);

create policy academy_frontend_chunks_admin_read
on public.academy_frontend_chunks
for select
to authenticated
using (
  exists (
    select 1 from public.program_roles pr
    where pr.user_id = (select auth.uid())
      and pr.role = 'admin'
  )
);
