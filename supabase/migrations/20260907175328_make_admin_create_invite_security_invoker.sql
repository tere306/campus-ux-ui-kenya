create or replace function public.admin_create_student_invite_v2(p_email text, p_real_name text, p_valid_hours integer default 168)
returns jsonb
language plpgsql
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

  select * into v_invite
  from public.student_invites
  where program_id=v_program_id
    and lower(email)=v_email
  order by created_at desc
  limit 1;

  if v_invite.id is null then
    insert into public.student_invites(program_id,email,real_name,status)
    values(v_program_id,v_email,v_name,'pending')
    returning * into v_invite;
  elsif v_invite.status='accepted' then
    raise exception 'invite already accepted';
  else
    update public.student_invites
       set real_name=v_name,
           status='pending',
           accepted_at=null,
           activation_code_hash=null,
           activation_generated_at=null,
           activation_expires_at=null,
           activation_used_at=null,
           activation_attempts=0,
           activation_locked_until=null
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

grant execute on function public.admin_create_student_invite_v2(text,text,integer) to authenticated;
revoke execute on function public.admin_create_student_invite_v2(text,text,integer) from anon;
