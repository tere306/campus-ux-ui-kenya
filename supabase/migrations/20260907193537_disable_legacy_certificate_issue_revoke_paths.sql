-- The v2 certificate pipeline is the only supported issuance/revocation path.
-- Preserve legacy functions for audit/history, but remove API execution rights.
revoke execute on function public.admin_issue_program_certificate(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.admin_revoke_program_certificate(uuid, text) from public, anon, authenticated;
revoke execute on function private.issue_program_certificate(uuid, uuid) from public, anon, authenticated;
revoke execute on function private.revoke_program_certificate_admin(uuid, text) from public, anon, authenticated;
