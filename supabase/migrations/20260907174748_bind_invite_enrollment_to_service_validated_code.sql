create or replace function private.enroll_pending_invite(p_user uuid, p_email text, p_invite_hash text)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  r record;
  v_version uuid;
begin
  if p_user is null or p_email is null or nullif(trim(p_invite_hash),'') is null then return; end if;

  for r in
    select *
    from public.student_invites
    where lower(email)=lower(p_email)
      and status in ('pending','sent')
      and activation_code_hash=p_invite_hash
      and activation_used_at is null
      and activation_expires_at is not null
      and activation_expires_at > now()
      and (activation_locked_until is null or activation_locked_until <= now())
  loop
    select v.id into v_version
    from public.academy_current_curriculum_version v
    where v.program_id=r.program_id;

    if v_version is null then
      raise exception 'current curriculum not found for invited program';
    end if;

    insert into public.profiles(user_id,real_name,role,active)
    values(p_user,r.real_name,'student',true)
    on conflict(user_id) do update
      set real_name=excluded.real_name,
          active=true;

    insert into public.program_enrollments(
      program_id,student_id,status,started_at,email_notifications,progress_digest,curriculum_version_id
    )
    values(r.program_id,p_user,'active',now(),true,'weekly',v_version)
    on conflict(program_id,student_id) do update
      set status='active',
          started_at=coalesce(public.program_enrollments.started_at,excluded.started_at),
          email_notifications=true,
          curriculum_version_id=coalesce(public.program_enrollments.curriculum_version_id,excluded.curriculum_version_id);

    update public.student_invites
    set status='accepted',
        accepted_at=now(),
        activation_used_at=now(),
        activation_code_hash=null,
        activation_attempts=0,
        activation_locked_until=null
    where id=r.id
      and status in ('pending','sent')
      and activation_code_hash=p_invite_hash;

    perform private.initialize_program_progress(p_user,r.program_id,now());
  end loop;
end;
$function$;

create or replace function private.on_auth_user_created_enroll_invite()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
begin
  perform private.enroll_pending_invite(
    new.id,
    new.email,
    new.raw_app_meta_data ->> 'student_invite_hash'
  );
  return new;
end;
$function$;

revoke all on function private.enroll_pending_invite(uuid,text,text) from public, anon, authenticated;
drop function if exists private.enroll_pending_invite(uuid,text);
