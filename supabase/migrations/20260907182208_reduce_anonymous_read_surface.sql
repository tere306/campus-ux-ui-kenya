revoke select on all tables in schema public from anon;

grant select (product_id, schema_version, curriculum_version, status, updated_at)
  on table public.academy_backend_meta to anon;

alter default privileges for role postgres in schema public
  revoke select on tables from anon;
