# QA — Límites de rol Admin y operaciones sensibles — v72

Fecha: 2026-09-08

## Alcance

Auditoría de autorización y consistencia de rol para:
- finalización de expediente;
- emisión y revocación de certificados;
- accesos manuales a módulos;
- lectura de expedientes y certificados;
- cuentas dual-role (`student` + `admin`);
- procedencia de los roles usados por el frontend.

## Hallazgos

### 1. Los roles no proceden de `user_metadata`

`resolveRemoteIdentity()` carga los roles desde `public.program_roles` usando la identidad Auth real. `runtimeAuth.roles` se deriva de esas filas y no de claims editables por la usuaria.

PASS.

### 2. `program_roles` no permite autoasignación

Aunque el rol `authenticated` conserva grants amplios de tabla por defaults históricos, RLS es obligatorio y limita la escritura:
- INSERT: `private.has_program_role(program_id,'admin')`;
- UPDATE: Admin del programa en `USING` y `WITH CHECK`;
- DELETE: Admin del programa;
- SELECT: rol propio o Admin del programa.

Una alumna no puede autoasignarse `admin` ni editar/borrar roles sin ser ya Admin.

PASS.

### 3. Finalización de expediente

`finalize_student_completion_v2` es `SECURITY INVOKER`. La inserción dispara `private.prepare_completion_record_v2()`, que vuelve a exigir rol Admin real del programa mediante `program_roles`.

El trigger además vuelve a validar:
- currículo actual;
- matrícula activa/completada;
- 48/48 clases;
- 12/12 proyectos aprobados;
- 12 reviews finales aprobadas;
- TFM aprobado;
- 5 evidencias de portfolio;
- integridad del snapshot y hash.

El registro final es inmutable mediante `prevent_completion_record_mutation_v2`.

PASS.

### 4. Lectura de expedientes

`get_completion_record_v2` es `SECURITY INVOKER`. Su SELECT queda sometido a RLS de `student_completion_records_v2`, que solo permite:
- `student_id = auth.uid()`; o
- Admin del programa.

Pasar manualmente el UUID de otra alumna no permite saltar RLS.

PASS.

### 5. Emisión de certificados

`public.issue_student_certificate_v2` delega en `private.issue_student_certificate_v2`, que es `SECURITY DEFINER` con `search_path=''` y exige `private.has_program_role(program_id,'admin')`.

Exige expediente finalizado y una sola credencial por expediente; la operación es idempotente si ya existe.

PASS.

### 6. Revocación de certificados

`private.revoke_student_certificate_v2` exige:
- sesión Auth;
- certificado existente;
- rol Admin real del programa;
- motivo de al menos 12 caracteres.

La revocación se registra aparte y no reescribe el expediente. Si ya estaba revocado, devuelve estado idempotente.

PASS.

### 7. Lectura de certificados y revocaciones

RLS limita lectura a:
- la propia alumna; o
- Admin del programa.

PASS.

### 8. Accesos manuales de módulos

El frontend exige `runtimeAuth.roles.includes('admin')`, pero el control relevante está en backend: `admin_set_module_access_v2` vuelve a verificar que `auth.uid()` sea Admin del programa de la matrícula objetivo.

RLS de `student_module_access_v2` también limita INSERT/UPDATE a Admin y SELECT a la propia alumna o Admin.

PASS.

### 9. Cuenta dual-role

`state.role` solo controla qué vista se muestra. Cambiar entre Alumna/Admin no modifica `runtimeAuth.roles`, ni los datos de `program_roles`, ni la autorización backend.

Las acciones sensibles vuelven a comprobar Admin en frontend y en Supabase. Una cuenta dual-role puede usar ambas vistas porque realmente posee ambos roles; estar visualmente en modo Alumna no elimina el rol Admin, pero tampoco lo crea ni amplía.

PASS.

## Deuda preventiva

Los grants históricos amplios a `authenticated` siguen siendo deuda de endurecimiento. RLS bloquea actualmente las operaciones no autorizadas, por lo que no se considera vulnerabilidad activa. Una futura limpieza de default privileges debería hacerse con matriz de equivalencia completa y no de forma automática.

## Veredicto

**PASS — no se detecta escalada de privilegios por cambio de vista, autoasignación de rol, UUID manipulado ni uso directo de las RPC sensibles.**

No se requiere nueva versión de frontend: v72 se mantiene como baseline.
