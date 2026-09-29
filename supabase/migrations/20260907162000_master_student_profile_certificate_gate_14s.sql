-- 14S · Student profile → certificate gate + minimal public verifier
-- 2026-09-07
--
-- Goals:
-- 1. New certificates use the student-confirmed certificate name, never email/phone.
-- 2. Issuance is blocked until first name + first surname exist and the name is confirmed.
-- 3. Existing issued certificates remain immutable.
-- 4. Public verification returns only the minimum fields agreed for verification.

create or replace function private.prepare_certificate_v2()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_now timestamptz := clock_timestamp();
  v_verification uuid := gen_random_uuid();
  v_record public.student_completion_records_v2%rowtype;
  v_program public.programs%rowtype;
  v_profile public.profiles%rowtype;
  v_version_label text;
  v_current_version text;
  v_certificate_name text;
  v_snapshot jsonb;
begin
  if new.completion_record_id is null then
    raise exception 'completion record is required';
  end if;

  select * into v_record
  from public.student_completion_records_v2
  where id = new.completion_record_id
    and status = 'finalized';

  if v_record.id is null then
    raise exception 'finalized completion record not found';
  end if;

  select * into v_program
  from public.programs
  where id = v_record.program_id;

  select * into v_profile
  from public.profiles
  where user_id = v_record.student_id;

  if v_profile.user_id is null then
    raise exception 'student profile not found';
  end if;

  if nullif(btrim(v_profile.first_name), '') is null
     or nullif(btrim(v_profile.last_name_1), '') is null then
    raise exception 'student certificate profile is incomplete';
  end if;

  if not coalesce(v_profile.certificate_name_confirmed, false)
     or v_profile.certificate_name_confirmed_at is null then
    raise exception 'certificate name confirmation required';
  end if;

  v_certificate_name := concat_ws(
    ' ',
    nullif(btrim(v_profile.first_name), ''),
    nullif(btrim(v_profile.last_name_1), ''),
    nullif(btrim(v_profile.last_name_2), '')
  );

  select version_label into v_version_label
  from public.program_curriculum_versions
  where id = v_record.curriculum_version_id;

  select curriculum_version into v_current_version
  from public.academy_backend_meta
  where product_id = 'master-uxui-web'
  limit 1;

  if v_program.slug <> 'ux-ui-maquetacion-web'
     or v_version_label is distinct from v_current_version then
    raise exception 'completion record does not belong to the current master curriculum';
  end if;

  new.program_id := v_record.program_id;
  new.curriculum_version_id := v_record.curriculum_version_id;
  new.student_id := v_record.student_id;
  new.certificate_version := 1;
  new.certificate_title := 'Certificado de finalización · ' || v_program.title;
  new.verification_id := v_verification;
  new.certificate_code := 'MUXUI-' || upper(replace(v_verification::text, '-', ''));
  new.issued_at := v_now;
  new.issued_by := auth.uid();
  new.transcript_hash := v_record.transcript_hash;

  v_snapshot := jsonb_build_object(
    'certificateVersion', 1,
    'credentialType', 'private_non_regulated_completion_certificate',
    'credentialScope', 'Formación privada no reglada. No equivale a un título universitario oficial ni otorga créditos ECTS.',
    'student', jsonb_build_object(
      'realName', v_certificate_name,
      'certificateNameConfirmedAt', v_profile.certificate_name_confirmed_at
    ),
    'program', jsonb_build_object(
      'title', v_program.title,
      'slug', v_program.slug,
      'totalHours', v_program.total_hours
    ),
    'curriculum', jsonb_build_object('versionLabel', v_version_label),
    'completion', jsonb_build_object(
      'completedAt', v_record.completed_at,
      'finalAverage', v_record.final_average,
      'tfmGrade', v_record.tfm_grade,
      'lessonCompleted', v_record.lesson_completed,
      'projectApproved', v_record.project_approved,
      'portfolioApproved', v_record.portfolio_approved
    ),
    'record', jsonb_build_object(
      'recordId', v_record.id,
      'verificationId', v_record.verification_id,
      'transcriptHash', v_record.transcript_hash
    ),
    'certificate', jsonb_build_object(
      'verificationId', v_verification,
      'code', new.certificate_code,
      'issuedAt', v_now,
      'issuedBy', auth.uid()
    )
  );

  new.certificate_snapshot := v_snapshot;
  new.certificate_hash := encode(extensions.digest(v_snapshot::text, 'sha256'), 'hex');
  new.created_at := v_now;
  return new;
end;
$function$;

create or replace function private.verify_master_certificate_private_v2(p_code text)
returns jsonb
language plpgsql
security definer
set search_path to ''
set statement_timeout to '3000ms'
as $function$
declare
  v_cert public.student_certificates_v2%rowtype;
  v_rev public.student_certificate_revocations_v2%rowtype;
  v_code text := upper(btrim(coalesce(p_code, '')));
begin
  if v_code !~ '^MUXUI-[A-F0-9]{32}$' then
    return jsonb_build_object('valid', false, 'status', 'not_found');
  end if;

  select * into v_cert
  from public.student_certificates_v2
  where certificate_code = v_code
  limit 1;

  if v_cert.id is null then
    return jsonb_build_object('valid', false, 'status', 'not_found');
  end if;

  select * into v_rev
  from public.student_certificate_revocations_v2
  where certificate_id = v_cert.id;

  return jsonb_build_object(
    'valid', v_rev.certificate_id is null,
    'status', case when v_rev.certificate_id is null then 'valid' else 'revoked' end,
    'certificateCode', v_cert.certificate_code,
    'studentName', v_cert.certificate_snapshot #>> '{student,realName}',
    'programTitle', v_cert.certificate_snapshot #>> '{program,title}',
    'completionDate', v_cert.certificate_snapshot #>> '{completion,completedAt}'
  );
end;
$function$;

-- Public wrapper remains stable for the frontend.
create or replace function public.verify_master_certificate_v2(p_code text)
returns jsonb
language sql
set search_path to ''
set statement_timeout to '4000ms'
as $function$
  select private.verify_master_certificate_private_v2(p_code);
$function$;
