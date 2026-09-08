# 14V · Sincronización dinámica por UUID

Fecha: 2026-09-07

## Objetivo

Eliminar los últimos restos funcionales ligados a nombres concretos de alumnas en el frontend de desarrollo y dejar el progreso de clases preparado para cualquier matrícula real.

## Snapshot previo

Antes del cambio se conservó:

`development-14v-before-dynamic-lesson-sync-index.html`

- versión: 52
- SHA-256: `77db0d842b3a5506ffb5c6060383f9876dacf4a3f22f5de721a8c947cc289009`

## Resultado

Asset actual:

`development-14v-dynamic-lesson-sync-index.html`

- versión: 53
- SHA-256: `e46631cb09cb81a628a0fef1985bf2795ee7b3e065cf7a2aa64ac45c0b909686`

## Cambios

- `lessonSyncEligible()` ya no depende de `profile.real_name === 'tere'`.
- La alumna activa se identifica mediante `localStudentIdFromAuth()`.
- Las lecturas/escrituras locales de progreso usan el UUID autenticado.
- El backup de sincronización guarda el UUID de la cuenta activa.
- La validación de versión curricular es genérica para cualquier cuenta con rol `student`.
- `validateImportedState()` recorre dinámicamente las claves existentes en `studentData`.
- Eliminados mensajes de UI específicos de Tere/Kenya.

## QA estático

- `sdata('tere')`: 0 ocurrencias.
- literal `'tere'`: 0 ocurrencias.
- `kenya` en el asset de desarrollo: 0 ocurrencias.
- botones: 143 aperturas / 143 cierres.
- formularios: 5 aperturas / 5 cierres.
- backticks: pares.
- documento termina en `</html>`.
- `service_role` en frontend: 0 ocurrencias.

## Producción

No se modificó Netlify producción durante este bloque.
