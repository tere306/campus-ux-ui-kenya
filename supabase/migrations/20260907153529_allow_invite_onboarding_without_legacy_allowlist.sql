create or replace function private.bootstrap_allowed_user()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_allowed private.allowed_emails%rowtype;
  v_activity uuid;
begin
  select * into v_allowed
  from private.allowed_emails
  where lower(email)=lower(new.email) and active=true;

  -- Legacy/bootstrap allowlist is no longer the gate for normal student onboarding.
  -- Invited students are handled by academy_enroll_pending_invite. An auth user
  -- without either path receives no app profile/enrollment and therefore no campus access.
  if not found then
    return new;
  end if;

  insert into public.profiles(user_id, real_name, role, student_code, active)
  values(new.id, v_allowed.real_name, v_allowed.role, v_allowed.student_code, true)
  on conflict (user_id) do nothing;

  if v_allowed.role = 'admin'::public.pioc_role then
    insert into private.admin_users(user_id) values(new.id)
    on conflict (user_id) do nothing;
  end if;

  if v_allowed.initial_activity_code is not null then
    select id into v_activity from public.activities where code=v_allowed.initial_activity_code;
    if v_activity is not null then
      insert into public.student_progress(student_id, activity_id, status, started_at)
      values(new.id, v_activity, 'available', now())
      on conflict (student_id, activity_id) do nothing;
    end if;
  end if;

  return new;
end;
$function$;
