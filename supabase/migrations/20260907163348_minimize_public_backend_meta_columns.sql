revoke select on table public.academy_backend_meta from anon, authenticated;

grant select(product_id,schema_version,curriculum_version,status,updated_at)
on table public.academy_backend_meta
to anon, authenticated;
