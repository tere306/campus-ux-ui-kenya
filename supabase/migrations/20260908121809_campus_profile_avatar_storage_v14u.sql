alter table public.profiles
  add column if not exists avatar_path text;

comment on column public.profiles.avatar_path is
  'Ruta privada de la foto de perfil en Storage. Nunca forma parte del certificado ni del verificador público.';

alter table public.profiles
  drop constraint if exists profiles_avatar_path_owner_check;

alter table public.profiles
  add constraint profiles_avatar_path_owner_check
  check (
    avatar_path is null
    or avatar_path ~ ('^' || user_id::text || '/avatar-[0-9]{13}\.(webp|png|jpe?g)$')
  );

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'campus-avatars',
  'campus-avatars',
  false,
  2097152,
  array['image/jpeg','image/png','image/webp']::text[]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists campus_avatars_select_own_or_admin on storage.objects;
create policy campus_avatars_select_own_or_admin
on storage.objects
for select
to authenticated
using (
  bucket_id = 'campus-avatars'
  and (
    (storage.foldername(name))[1] = (select auth.uid())::text
    or private.is_admin()
  )
);

drop policy if exists campus_avatars_insert_own on storage.objects;
create policy campus_avatars_insert_own
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'campus-avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists campus_avatars_update_own on storage.objects;
create policy campus_avatars_update_own
on storage.objects
for update
to authenticated
using (
  bucket_id = 'campus-avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'campus-avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists campus_avatars_delete_own on storage.objects;
create policy campus_avatars_delete_own
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'campus-avatars'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);
