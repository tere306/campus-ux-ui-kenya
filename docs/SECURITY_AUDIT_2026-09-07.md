# Auditoría de seguridad · 2026-09-07

## Alcance

Frontend de producción/desarrollo, RLS y grants de Supabase, RPC, perfiles, invitaciones, Auth, certificados, caché local, Edge Functions, Storage y preparación de release Netlify.

## Producción pública actual

El deploy público de Netlify continúa siendo el anterior y conserva autenticación legacy/local embebida. La credencial encontrada no se documenta ni se versiona. Se conserva un hotfix exacto sin ese acceso (`production-security-hotfix-no-legacy-auth-index.html`, v16), pero no se ha desplegado mientras la nueva release no pase QA real.

Producción no ha sido modificada durante esta auditoría.

## Superficie anónima de base de datos

Se redujo `anon` a mínimos explícitos:

- 0 privilegios a nivel de tabla en `public`;
- 0 INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER;
- 0 `MAINTAIN`;
- 0 permisos sobre secuencias;
- únicamente SELECT de 5 columnas de `academy_backend_meta`: `product_id`, `schema_version`, `curriculum_version`, `status`, `updated_at`.

La pantalla de acceso sigue comprobando esos metadatos y el verificador público continúa operativo.

Los default ACL de objetos nuevos creados por `postgres` se endurecieron para no conceder permisos a `anon` automáticamente. Los defaults internos de plataforma administrados por `supabase_admin` se revisan por separado.

## RLS y funciones

- Todas las tablas base del esquema `public` tienen RLS habilitado.
- Una identidad autenticada sin matrícula/rol no obtiene datos académicos ni de identidad de otras cuentas.
- Assets, chunks y manifests de frontend ya no son legibles anónimamente.
- Funciones privadas usadas exclusivamente como triggers no son ejecutables directamente por `anon`/`authenticated`.
- Todas las funciones `SECURITY DEFINER` revisadas tienen `search_path` explícito.
- `public.is_admin()` no es ejecutable por `anon`.
- La única RPC pública ejecutable por `anon` es `verify_master_certificate_v2(text)`.

## Onboarding por invitación

El alta ya no se concede por simple coincidencia de email.

1. Admin genera código de 24 hex (96 bits).
2. `activate-student-invite` valida email, código, caducidad, bloqueo y contraseña.
3. El endpoint crea el usuario Auth incluyendo en `app_metadata` el hash del código validado.
4. El trigger de onboarding solo matricula si el hash coincide con una invitación activa y válida.
5. La invitación se invalida al aceptar la matrícula.
6. Si la cuenta se crea pero la matrícula no termina aceptada, la cuenta recién creada se elimina.

Se retiró el bootstrap/allowlist histórico de emails. `admin_create_student_invite_v2` es `SECURITY INVOKER` y depende de rol Admin + RLS.

QA transaccional: creación de invitación Admin devolvió `ok=true`, estado `sent` y código de longitud 24; el rollback dejó 0 filas QA persistentes.

## `activate-student-invite` v5

- público antes de sesión por diseño (`verify_jwt=false`);
- POST/OPTIONS;
- payload máximo 4 KiB;
- email validado;
- código exclusivamente 24 hex;
- contraseña 12–256 caracteres y al menos 3 clases;
- comparación segura del hash;
- bloqueo 15 min tras 5 fallos;
- CORS restringido;
- `no-store`, `nosniff`, `no-referrer` y CORP;
- no devuelve `user_id` ni secretos.

## Certificados

### Ruta v2 soportada

- exige expediente final válido;
- exige nombre estructurado y confirmado;
- cambiar nombre/apellidos invalida la confirmación;
- email y teléfono no entran en el certificado;
- certificado emitido inmutable;
- revocación registrada por separado;
- verificador público limitado a nombre, programa, fecha de finalización, estado y código.

### Rutas legacy retiradas

El verificador legacy ya estaba sin ejecución pública. Durante esta auditoría se detectó además que la antigua emisión/revocación de `program_certificates` seguía siendo ejecutable por `authenticated`, aunque el frontend actual no la utilizaba.

Se revocó `EXECUTE` para `PUBLIC`, `anon` y `authenticated` sobre:

- `public.admin_issue_program_certificate(uuid, uuid)`;
- `public.admin_revoke_program_certificate(uuid, text)`;
- `private.issue_program_certificate(uuid, uuid)`;
- `private.revoke_program_certificate_admin(uuid, text)`.

En el momento del cierre había 0 certificados legacy en `program_certificates`. La única ruta soportada queda en v2.

## Storage

- `pioc-web`: antiguo bucket web conservado como evidencia/backup pero convertido a privado.
- `pioc-audio`: privado; políticas limitadas a carpeta propia del usuario autenticado y lectura adicional Admin.
- El frontend actual no depende de `pioc-web` ni de `pioc-audio` para su ejecución principal.

## Edge Functions

### Retiradas / neutralizadas

Responden 410 o lógica deshabilitada:

- `pioc-campus`;
- `pioc-publish-web`;
- `publish-frontend-release` desde v2;
- `pioc-bootstrap-admin`;
- `pioc-issue-tere-link`;
- `pioc-set-tere-password`;
- `pioc-tere-access`;
- `patch-v9-admin-nav`.

`publish-frontend-release` utilizaba antes `service_role` para escribir chunks/manifests; el frontend actual no lo referencia y ahora responde 410 sin usar privilegios de servidor. La publicación objetivo es Netlify.

`status=ACTIVE` en Supabase significa “hay una versión desplegada”; no implica que la capacidad histórica siga operativa.

### Preview

`campus-development-preview` usa acceso específico de preview. La clave se rotó, no se versiona y el frontend no la propaga a enlaces de invitación. Mantiene headers y CSP restrictivos.

## Caché del navegador

- sesión Auth en `sessionStorage`;
- caché académica local ligada al `user_id` activo;
- si cambia el propietario, se descarta la caché anterior antes de hidratar la nueva cuenta;
- logout elimina estado/backups locales sensibles y el identificador de propietario;
- Supabase sigue siendo la autoridad académica.

## Recuperación de contraseña

Revisión estática:

- solicitud a `/auth/v1/recover`;
- redirect fijo al origen oficial;
- soporte de `token_hash` / `type=recovery` y sesión recovery;
- nueva contraseña con 12 caracteres mínimo y 3 clases;
- cierre de sesión tras el cambio y nuevo login obligatorio.

Falta QA real del email y redirect.

## Hardening de renderizado v60–v64

Se revisaron rutas que construyen HTML dinámico:

- v60: identidad de sesión Admin escapada;
- v61: recursos externos con título/descripción escapados y URL validada por `safeHttpHref`;
- v62: nombres/identidad de alumnas escapados en cola, tarjetas, evaluaciones y drawers;
- v63: `head()` escapa eyebrow, título y subtítulo;
- v64: copy y estado curricular operativos alineados con Supabase (`published`).

QA v64: 143/143 botones, 5/5 formularios, 0 controles sin nombre accesible, referencias ARIA válidas, sin `history.back()`, sin `service_role` en frontend.

## Advisors

Security Advisor: únicamente queda **Leaked Password Protection Disabled**.

Remediación: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

Performance Advisor: informa índices aún no utilizados y varias políticas permisivas superpuestas. No se eliminan índices ni se fusionan políticas sin tráfico representativo y QA de equivalencia; no son bloqueadores de seguridad actuales.

## Bloqueadores antes de producción

- QA visual/responsive real;
- login/F5/logout y cambio Alumna/Admin;
- segunda cuenta real: invitación → activación → login → Admin;
- progreso → entrega → evaluación → feedback → desbloqueo con dos cuentas;
- cambio de cuenta en el mismo navegador para validar aislamiento de caché;
- recuperación de contraseña real;
- responsable legal y email de privacidad;
- activar/revisar Leaked Password Protection;
- sustituir el deploy público y ejecutar smoke test antes de fusionar a `main`.
