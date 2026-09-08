create or replace function public.admin_generate_student_activation_code(p_invite uuid, p_valid_hours integer default 168)
returns text
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_code text;
  v_program_id uuid;
  v_status text;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_valid_hours < 1 or p_valid_hours > 720 then raise exception 'invalid validity period'; end if;

  select program_id,status into v_program_id,v_status
  from public.student_invites
  where id=p_invite;

  if v_program_id is null or v_status not in ('pending','sent') then
    raise exception 'invite not found or not activatable';
  end if;
  if not private.has_program_role(v_program_id,'admin') then
    raise exception 'admin role required';
  end if;

  v_code := upper(substr(replace(gen_random_uuid()::text,'-',''),1,24));
  update public.student_invites
     set activation_code_hash=encode(extensions.digest(v_code,'sha256'),'hex'),
         activation_generated_at=clock_timestamp(),
         activation_expires_at=clock_timestamp()+make_interval(hours=>p_valid_hours),
         activation_used_at=null,
         activation_attempts=0,
         activation_locked_until=null,
         status='sent',
         invited_at=coalesce(invited_at,clock_timestamp())
   where id=p_invite;

  return v_code;
end;
$function$;

create or replace function public.get_admin_student_invites_v2()
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_program_id uuid;
  v_result jsonb;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;

  select cv.program_id into v_program_id
  from public.program_curriculum_versions cv
  where cv.version_label=(select curriculum_version from public.academy_backend_meta where product_id='master-uxui-web' limit 1)
  order by cv.created_at desc limit 1;

  if v_program_id is null then raise exception 'current program not found'; end if;
  if not private.has_program_role(v_program_id,'admin') then raise exception 'admin role required'; end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'inviteId',si.id,
    'realName',si.real_name,
    'email',si.email,
    'status',si.status,
    'createdAt',si.created_at,
    'invitedAt',si.invited_at,
    'acceptedAt',si.accepted_at,
    'activationGeneratedAt',si.activation_generated_at,
    'activationExpiresAt',si.activation_expires_at,
    'activationUsedAt',si.activation_used_at,
    'activationLockedUntil',si.activation_locked_until,
    'hasActiveCode',si.activation_code_hash is not null
      and si.activation_used_at is null
      and si.activation_expires_at is not null
      and si.activation_expires_at > now()
  ) order by si.created_at desc),'[]'::jsonb)
  into v_result
  from public.student_invites si
  where si.program_id=v_program_id;

  return v_result;
end;
$function$;

create or replace function public.admin_create_student_invite_v2(
  p_email text,
  p_real_name text,
  p_valid_hours integer default 168
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_program_id uuid;
  v_email text := lower(btrim(coalesce(p_email,'')));
  v_name text := regexp_replace(btrim(coalesce(p_real_name,'')), '[[:space:]]+', ' ', 'g');
  v_invite public.student_invites%rowtype;
  v_code text;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_valid_hours < 1 or p_valid_hours > 720 then raise exception 'invalid validity period'; end if;
  if v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then raise exception 'invalid email'; end if;
  if char_length(v_name) < 2 or char_length(v_name) > 160 then raise exception 'invalid real name'; end if;

  select cv.program_id into v_program_id
  from public.program_curriculum_versions cv
  where cv.version_label=(select curriculum_version from public.academy_backend_meta where product_id='master-uxui-web' limit 1)
  order by cv.created_at desc limit 1;

  if v_program_id is null then raise exception 'current program not found'; end if;
  if not private.has_program_role(v_program_id,'admin') then raise exception 'admin role required'; end if;

  if exists(select 1 from auth.users u where lower(u.email)=v_email) then
    raise exception 'an account already exists for this email';
  end if;

  select * into v_invite
  from public.student_invites
  where program_id=v_program_id
    and lower(email)=v_email
    and status in ('pending','sent')
  order by created_at desc
  limit 1;

  if v_invite.id is null then
    insert into public.student_invites(program_id,email,real_name,status)
    values(v_program_id,v_email,v_name,'pending')
    returning * into v_invite;
  else
    update public.student_invites
       set real_name=v_name,
           status='pending'
     where id=v_invite.id
     returning * into v_invite;
  end if;

  v_code := public.admin_generate_student_activation_code(v_invite.id,p_valid_hours);

  select * into v_invite from public.student_invites where id=v_invite.id;
  return jsonb_build_object(
    'ok',true,
    'inviteId',v_invite.id,
    'realName',v_invite.real_name,
    'email',v_invite.email,
    'status',v_invite.status,
    'code',v_code,
    'expiresAt',v_invite.activation_expires_at
  );
end;
$function$;

create or replace function public.admin_cancel_student_invite_v2(p_invite uuid)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_program_id uuid;
  v_status text;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;

  select program_id,status into v_program_id,v_status
  from public.student_invites where id=p_invite;

  if v_program_id is null then raise exception 'invite not found'; end if;
  if not private.has_program_role(v_program_id,'admin') then raise exception 'admin role required'; end if;
  if v_status='accepted' then raise exception 'accepted invite cannot be cancelled'; end if;

  update public.student_invites
     set status='cancelled',
         activation_code_hash=null,
         activation_expires_at=null,
         activation_locked_until=null
   where id=p_invite;

  return jsonb_build_object('ok',true,'inviteId',p_invite,'status','cancelled');
end;
$function$;

revoke all on function public.admin_generate_student_activation_code(uuid,integer) from public, anon;
revoke all on function public.get_admin_student_invites_v2() from public, anon;
revoke all on function public.admin_create_student_invite_v2(text,text,integer) from public, anon;
revoke all on function public.admin_cancel_student_invite_v2(uuid) from public, anon;

grant execute on function public.admin_generate_student_activation_code(uuid,integer) to authenticated;
grant execute on function public.get_admin_student_invites_v2() to authenticated;
grant execute on function public.admin_create_student_invite_v2(text,text,integer) to authenticated;
grant execute on function public.admin_cancel_student_invite_v2(uuid) to authenticated;
