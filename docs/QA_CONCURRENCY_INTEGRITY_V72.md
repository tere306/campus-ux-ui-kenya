# QA de concurrencia e integridad · v72

Fecha: 2026-09-08

## Alcance

Revisión estática y SQL de condiciones de carrera en progreso de clases, borradores/entregas y evaluaciones remotas. No se ha ejecutado navegador real ni una prueba simultánea con dos cuentas/sesiones reales.

## Resultado

**PASS técnico en controles de concurrencia revisados.** No se ha creado una nueva versión de frontend porque no se ha encontrado una corrección necesaria.

## Progreso de clases

`set_my_lesson_progress_v2` implementa optimistic locking mediante `p_expected_revision`:

- comprueba la revisión actual antes de cambiar estado;
- el `UPDATE` incluye `revision = p_expected_revision` en el `WHERE`;
- si otra sesión ganó la carrera, devuelve `conflict=true` con la revisión/estado remoto actual;
- la creación inicial también detecta una inserción concurrente y devuelve conflicto en lugar de sobrescribir.

El frontend conserva copia local previa y reconcilia contra Supabase cuando detecta divergencia.

## Hilos de entrega

`student_submissions_v2` tiene unicidad por:

`(student_id, curriculum_version_id, deliverable_id)`

Por tanto, dos pestañas no pueden crear dos hilos paralelos para el mismo entregable de la misma alumna y versión curricular.

Al guardar un borrador existente, el frontend realiza PATCH condicionado por:

`id = <thread id> AND revision = <expected revision>`

Si PostgREST devuelve cero filas:

1. guarda una copia local de recuperación;
2. recarga la versión remota;
3. marca conflicto;
4. informa de que el borrador cambió en otra sesión;
5. no sobrescribe silenciosamente la versión remota.

## Envío de intentos

`private.prepare_submission_attempt_v2` carga el hilo con `FOR UPDATE` antes de:

- validar estado;
- calcular `attempt_no = current_attempt_no + 1`;
- insertar el intento;
- incrementar la revisión del hilo.

Además existe índice único por:

`(submission_id, attempt_no)`

Esto protege contra intentos duplicados aun bajo concurrencia.

## Evaluaciones

`private.prepare_submission_review_v2` bloquea el hilo con `FOR UPDATE` y exige simultáneamente:

- `expected_submission_revision = thread.revision`;
- `expected_review_version = current review version`.

Si cualquiera cambió en otra sesión, la publicación falla con conflicto.

El frontend envía ambos valores esperados. Si recibe conflicto:

1. recarga reviews remotas;
2. marca el conflicto en runtime;
3. informa a Admin de que la entrega/evaluación cambió en otra sesión;
4. no publica encima de la versión nueva.

También existe índice único por:

`(attempt_id, review_version)`

por lo que dos evaluaciones no pueden ocupar la misma versión.

## Cierre académico

`finalize_student_completion_v2` es idempotente ante concurrencia: si ya existe el expediente devuelve `alreadyFinalized=true`; si dos sesiones intentan crearlo, la `unique_violation` se captura y se devuelve el registro ya creado.

## Limitaciones pendientes

- Falta prueba real con dos pestañas/sesiones concurrentes en navegador.
- Falta probar visualmente la UX de recuperación tras conflicto.
- No se ha simulado carga alta; esta revisión valida el diseño transaccional y las restricciones, no throughput.

## Veredicto

La cadena principal de progreso → entrega → intento → evaluación tiene controles de concurrencia en backend y frontend suficientes para evitar overwrites silenciosos en los casos revisados. No se requiere cambio de código en v72.
