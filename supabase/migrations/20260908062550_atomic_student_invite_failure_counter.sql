create or replace function public.record_student_invite_failure_v2(p_invite uuid)
returns table(attempts integer, locked_until timestamptz)
language sql
security invoker
set search_path = ''
as $$
  update public.student_invites
  set activation_attempts = coalesce(activation_attempts, 0) + 1,
      activation_locked_until = case
        when coalesce(activation_attempts, 0) + 1 >= 5
          then greatest(coalesce(activation_locked_until, '-infinity'::timestamptz), now() + interval '15 minutes')
        else activation_locked_until
      end
  where id = p_invite
    and status in ('pending','sent')
    and activation_used_at is null
    and activation_expires_at is not null
    and activation_expires_at > now()
    and (activation_locked_until is null or activation_locked_until <= now())
  returning activation_attempts, activation_locked_until;
$$;

revoke all on function public.record_student_invite_failure_v2(uuid) from public, anon, authenticated;
grant execute on function public.record_student_invite_failure_v2(uuid) to service_role;
