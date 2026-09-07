# Historial de migraciones

La fuente de verdad actual del historial es Supabase (`pioc-campus`).

El proyecto contiene migraciones desde `initial_pioc_schema` (2026-08-31) hasta los bloques de QA 14O del 2026-09-07.

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

Las nuevas migraciones SQL se versionarán aquí de forma coordinada con su aplicación en Supabase.
