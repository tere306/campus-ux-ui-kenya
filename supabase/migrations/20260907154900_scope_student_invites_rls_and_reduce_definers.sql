drop policy if exists student_invites_admin_all on public.student_invites;

create policy student_invites_admin_program_all
on public.student_invites
for all
to authenticated
using (private.has_program_role(program_id,'admin'))
with check (private.has_program_role(program_id,'admin'));

alter function public.get_admin_student_invites_v2() security invoker;
alter function public.admin_generate_student_activation_code(uuid,integer) security invoker;
alter function public.admin_cancel_student_invite_v2(uuid) security invoker;
