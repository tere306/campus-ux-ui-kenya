drop trigger if exists pioc_bootstrap_allowed_user on auth.users;
revoke all on function private.bootstrap_allowed_user() from public, anon, authenticated;
