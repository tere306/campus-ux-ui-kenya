# QA RLS y privilegios — 2026-09-08

## Alcance
Auditoría live del proyecto Supabase `pioc-campus` (`azacjdyxgknfqarcemhi`) contra el baseline de preproducción v68.

Producción Netlify no se modifica. `main` no se modifica. No se publica release final.

## 1. RLS en tablas base
Se inspeccionaron todas las relaciones base/partitioned de `public` mediante `pg_class`.

**Resultado: PASS**

Todas las tablas base encontradas tienen `relrowsecurity = true`.

Esto incluye, entre otras, perfiles, matrículas, progreso, entregas, revisiones, certificados, invitaciones, assets de frontend y tablas curriculares.

## 2. Superficie anónima
La auditoría de privilegios de columna confirma que `anon` conserva únicamente cinco `SELECT` de columna sobre `academy_backend_meta`:

- `product_id`
- `schema_version`
- `curriculum_version`
- `status`
- `updated_at`

No se observaron grants anónimos de secuencia.

**Resultado: PASS**

La superficie anónima coincide con el diseño documentado.

## 3. Funciones / RPC
Se inspeccionaron las funciones de `public` ejecutables por `anon` o `authenticated`.

- La única RPC ejecutable por `anon` es `verify_master_certificate_v2(text)`.
- Las RPC de aplicación expuestas son `SECURITY INVOKER`.
- En la auditoría live no existe actualmente ninguna función `SECURITY DEFINER` dentro de `public`.

**Resultado: PASS**

Esto evita que una RPC pública pueda saltarse RLS mediante privilegios del owner.

## 4. Vistas
Se inspeccionaron las vistas de `public`.

- 24 vistas encontradas.
- Todas tienen `security_invoker=true`.
- Ninguna tiene `SELECT` para `anon`.
- Las vistas destinadas a usuarios autenticados se ejecutan con los permisos del caller y respetan RLS de las tablas subyacentes.

**Resultado: PASS**

## 5. Prueba negativa de identidad autenticada sin acceso académico
Se simuló una identidad `authenticated` sintética, sin matrícula ni rol, y se consultó la visibilidad de conjuntos sensibles.

Resultados:

- `profiles`: 0
- `program_enrollments`: 0
- `student_progress`: 0
- `submissions`: 0
- `submission_reviews`: 0
- `program_completions`: 0
- `student_certificates_v2`: 0
- `student_invites`: 0
- `academy_admin_action_queue`: 0

**Resultado: PASS**

Una identidad autenticada sin matrícula/rol no obtiene visibilidad académica o administrativa por el mero hecho de estar autenticada.

## 6. Claims inseguros / APIs obsoletas en políticas
Se buscaron políticas RLS que dependieran de:

- `user_metadata`
- `raw_user_meta_data`
- `auth.role()`

No se encontraron coincidencias.

**Resultado: PASS**

La autorización no depende de metadata editable por el usuario ni del helper `auth.role()` deprecado.

## 7. Deuda preventiva: default privileges
Los default privileges actuales del owner `postgres` en `public` ya retiran los grants automáticos de `anon`, según la migración `20260907182817_secure_postgres_anonymous_defaults.sql`.

Sin embargo, los objetos futuros todavía reciben grants automáticos para `authenticated` (y `service_role`) por defecto.

Esto **no supone una fuga actual** porque:

1. las tablas existentes tienen RLS;
2. las vistas existentes son `security_invoker`;
3. las funciones actualmente expuestas son `SECURITY INVOKER`;
4. la prueba negativa de identidad sin matrícula/rol devuelve cero filas sensibles.

Recomendación futura: migrar hacia grants explícitos también para `authenticated` al crear nuevos objetos, siguiendo el modelo opt-in recomendado por Supabase. No se cambia automáticamente en esta pasada para no alterar el contrato de creación de futuras RPCs sin una migración y QA de compatibilidad dedicados.

## Veredicto
**PASS — aislamiento automático / SQL consistente con el baseline de seguridad de preproducción.**

Pendientes que siguen requiriendo validación real:

1. browser QA responsive y visual;
2. login / refresh / logout con cuentas reales;
3. flujo alumno ↔ admin con dos identidades reales;
4. cambio de cuenta en el mismo navegador y purga de caché;
5. recuperación de contraseña y redirect de email;
6. Leaked Password Protection en Auth;
7. externalización/rotación de la clave del preview;
8. datos legales reales antes de alumnado real.
