# Historial de migraciones

La fuente de verdad actual del historial es Supabase (`pioc-campus`).

El proyecto contiene migraciones desde `initial_pioc_schema` (2026-08-31) hasta los bloques de QA y endurecimiento del 2026-09-07.

Último tramo confirmado:
- `master_backend_identity_bridge_v14b`
- `harden_master_program_role_helper`
- `master_curriculum_v2_parallel_12x48`
- `master_lesson_progress_v2_remote_sync_14f`
- `master_remote_submissions_v2_14g`
- `master_remote_reviews_v14h`
- `master_module_access_v2_server_authority`
- `academic_summary_remote_14j`
- `block_14k_portfolio_closure_remote`
- `master_uxui_web_14l_formal_completion_record`
- `master_certificate_verification_v14m`
- `master_production_hardening_v14n`
- `qa_current_attempt_review_order_and_resource_refs_14o`
- `qa_admin_unique_module_access_count_14o`
- `qa_submission_evidence_url_scheme_guard_14o`
- `student_profile_certificate_data_14s`
- `master_student_profile_certificate_gate_14s`
- `allow_invite_onboarding_without_legacy_allowlist`
- `student_invite_admin_workflow_v2`
- `scope_student_invites_rls_and_reduce_definers`
- `disable_legacy_public_certificate_verifier`
- `revoke_anon_public_is_admin_execute`
- `lock_down_public_is_admin_execute`
- `lock_down_frontend_asset_storage`
- `index_student_learning_journal_program_id`
- `minimize_public_backend_meta_columns`

Las migraciones nuevas aplicadas durante esta sesión se están copiando a este directorio con el mismo timestamp/nombre que consta en `supabase_migrations.schema_migrations` para que GitHub pueda reconstruir y auditar el backend sin depender únicamente del historial alojado en Supabase.
