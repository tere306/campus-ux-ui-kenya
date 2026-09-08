# QA invite atomic lockout — 2026-09-08

## Objetivo

Eliminar la condición de carrera del contador `activation_attempts` del flujo `activate-student-invite` sin ampliar la superficie pública.

## Cambio aplicado

Se añadió `public.record_student_invite_failure_v2(uuid)` mediante la migración real `20260908062550_atomic_student_invite_failure_counter.sql`.

Propiedades verificadas:
- `SECURITY INVOKER`;
- `search_path=''`;
- `anon`: sin EXECUTE;
- `authenticated`: sin EXECUTE;
- `service_role`: EXECUTE permitido;
- el incremento usa un único `UPDATE ... SET activation_attempts = activation_attempts + 1 ... RETURNING`;
- el quinto fallo fija `activation_locked_until` a al menos 15 minutos.

## Pruebas transaccionales

Se utilizó una invitación existente únicamente dentro de `BEGIN ... ROLLBACK`, forzando temporalmente una ventana válida para no crear cuentas ni invitaciones ficticias persistentes.

Resultados:
- 0 -> 1: PASS;
- 1 -> 2: PASS;
- 4 -> 5: PASS;
- quinto intento crea ventana de bloqueo >14 minutos en el momento de la comprobación: PASS;
- `ROLLBACK` ejecutado: sin cambios persistentes en la invitación usada para QA.

## Edge Function

`activate-student-invite` se actualizó para llamar al RPC atómico con el cliente `service_role` y quedó desplegada como versión **8**.

Se conserva el hardening de v6:
- estados de invitación caducada/bloqueada no se revelan a quien no demuestra conocer el código correcto;
- código de 24 hex / 96 bits;
- máximo 4096 bytes de body;
- contraseña 12–256 y mínimo 3 clases;
- CORS allowlist;
- rollback lógico de usuario Auth si la matrícula no queda aceptada.

## Historial de migraciones

Durante la verificación se registraron además cuatro migraciones no-op en Supabase. No contienen DDL/DML y se reflejaron en GitHub con sus versiones exactas para evitar divergencia entre historial remoto y repositorio:
- `20260908062641_noop_verify_atomic_invite_failure_counter.sql`
- `20260908062657_drop_noop_atomic_invite_marker.sql`
- `20260908062707_cleanup_atomic_invite_migration_notes.sql`
- `20260908062714_finalize_atomic_invite_counter_audit.sql`

## Security Advisor

Tras el cambio, el único aviso de seguridad automático sigue siendo `auth_leaked_password_protection` desactivado.

Referencia: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

## Veredicto

PASS para contador atómico y aislamiento del RPC. No se modificó Netlify production, no se fusionó `develop` a `main` y no se publicó release final.
