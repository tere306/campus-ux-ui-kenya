-- 14S · Ficha del alumno y datos de certificación
-- Cambio aditivo. No crea campos de DNI/NIE/pasaporte ni otros documentos de identidad.

alter table public.profiles
  add column if not exists first_name text,
  add column if not exists last_name_1 text,
  add column if not exists last_name_2 text,
  add column if not exists phone text,
  add column if not exists certificate_name_confirmed boolean not null default false,
  add column if not exists certificate_name_confirmed_at timestamptz,
  add column if not exists privacy_notice_acknowledged boolean not null default false,
  add column if not exists privacy_notice_acknowledged_at timestamptz,
  add column if not exists privacy_notice_version text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname='profiles_first_name_length_14s') then
    alter table public.profiles add constraint profiles_first_name_length_14s
      check (first_name is null or char_length(btrim(first_name)) between 1 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conname='profiles_last_name_1_length_14s') then
    alter table public.profiles add constraint profiles_last_name_1_length_14s
      check (last_name_1 is null or char_length(btrim(last_name_1)) between 1 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conname='profiles_last_name_2_length_14s') then
    alter table public.profiles add constraint profiles_last_name_2_length_14s
      check (last_name_2 is null or char_length(btrim(last_name_2)) between 1 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conname='profiles_phone_length_14s') then
    alter table public.profiles add constraint profiles_phone_length_14s
      check (phone is null or char_length(btrim(phone)) between 3 and 40);
  end if;
  if not exists (select 1 from pg_constraint where conname='profiles_certificate_confirmation_14s') then
    alter table public.profiles add constraint profiles_certificate_confirmation_14s
      check (
        (not certificate_name_confirmed and certificate_name_confirmed_at is null)
        or
        (certificate_name_confirmed
          and certificate_name_confirmed_at is not null
          and nullif(btrim(first_name),'') is not null
          and nullif(btrim(last_name_1),'') is not null)
      );
  end if;
  if not exists (select 1 from pg_constraint where conname='profiles_privacy_ack_14s') then
    alter table public.profiles add constraint profiles_privacy_ack_14s
      check (
        (not privacy_notice_acknowledged and privacy_notice_acknowledged_at is null)
        or
        (privacy_notice_acknowledged
          and privacy_notice_acknowledged_at is not null
          and nullif(btrim(privacy_notice_version),'') is not null)
      );
  end if;
end $$;

create or replace function private.guard_profile_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    if new.user_id is distinct from old.user_id
       or new.real_name is distinct from old.real_name
       or new.role is distinct from old.role
       or new.student_code is distinct from old.student_code
       or new.active is distinct from old.active
       or new.created_at is distinct from old.created_at then
      raise exception 'Protected profile fields cannot be changed by students';
    end if;
  end if;

  new.first_name := nullif(regexp_replace(btrim(coalesce(new.first_name,'')), '[[:space:]]+', ' ', 'g'),'');
  new.last_name_1 := nullif(regexp_replace(btrim(coalesce(new.last_name_1,'')), '[[:space:]]+', ' ', 'g'),'');
  new.last_name_2 := nullif(regexp_replace(btrim(coalesce(new.last_name_2,'')), '[[:space:]]+', ' ', 'g'),'');
  new.phone := nullif(btrim(coalesce(new.phone,'')),'');
  new.privacy_notice_version := nullif(btrim(coalesce(new.privacy_notice_version,'')),'');

  -- Cualquier cambio del nombre que alimentará el certificado invalida una
  -- confirmación anterior. La reconfirmación debe ser una acción posterior.
  if new.first_name is distinct from old.first_name
     or new.last_name_1 is distinct from old.last_name_1
     or new.last_name_2 is distinct from old.last_name_2 then
    new.certificate_name_confirmed := false;
    new.certificate_name_confirmed_at := null;
  end if;

  if new.certificate_name_confirmed and not old.certificate_name_confirmed then
    if new.first_name is null or new.last_name_1 is null then
      raise exception 'First name and first surname are required before certificate-name confirmation';
    end if;
    new.certificate_name_confirmed_at := clock_timestamp();
  elsif not new.certificate_name_confirmed then
    new.certificate_name_confirmed_at := null;
  end if;

  -- Es constancia de lectura, no consentimiento comercial. Una vez registrada
  -- no se borra mediante una edición ordinaria del perfil.
  if old.privacy_notice_acknowledged and not new.privacy_notice_acknowledged then
    new.privacy_notice_acknowledged := true;
    new.privacy_notice_acknowledged_at := old.privacy_notice_acknowledged_at;
    new.privacy_notice_version := old.privacy_notice_version;
  elsif new.privacy_notice_acknowledged and not old.privacy_notice_acknowledged then
    if new.privacy_notice_version is null then
      raise exception 'Privacy notice version is required';
    end if;
    new.privacy_notice_acknowledged_at := clock_timestamp();
  elsif not new.privacy_notice_acknowledged then
    new.privacy_notice_acknowledged_at := null;
  end if;

  new.updated_at := now();
  return new;
end;
$$;

comment on column public.profiles.first_name is 'Nombre para expediente y certificado. No documento de identidad.';
comment on column public.profiles.last_name_1 is 'Primer apellido para expediente y certificado.';
comment on column public.profiles.last_name_2 is 'Segundo apellido opcional para expediente y certificado.';
comment on column public.profiles.phone is 'Teléfono opcional y privado. Nunca forma parte del verificador público.';
comment on column public.profiles.certificate_name_confirmed is 'Confirmación expresa de que el nombre mostrado es correcto para el certificado; no es consentimiento de marketing.';
comment on column public.profiles.privacy_notice_acknowledged is 'Constancia de lectura de la información básica de privacidad; no es consentimiento para usos opcionales.';
