drop policy if exists academy_frontend_releases_public_read on public.academy_frontend_releases;

revoke all on table public.academy_frontend_releases from anon, authenticated;
grant select on table public.academy_frontend_releases to authenticated;

create policy academy_frontend_releases_admin_read
on public.academy_frontend_releases
for select
to authenticated
using (
  exists (
    select 1 from public.program_roles pr
    where pr.user_id=(select auth.uid())
      and pr.role='admin'
  )
);
