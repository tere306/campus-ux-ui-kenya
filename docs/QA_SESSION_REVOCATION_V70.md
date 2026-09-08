# QA sesiones y revocación v70

Fecha: 2026-09-08

## Baseline

Alias: `development-current-index.html`

- versión: **70**
- SHA-256: `9cb2d3ca1bb853ec7387a8a1da58390dce1bf6a0c855a5fa6136eba0ff993cb4`
- tamaño aproximado: 712051 caracteres

## Hallazgos previos

- La sesión Auth se persiste en `sessionStorage`, no en `localStorage`.
- El refresh se serializa para evitar carreras; si falla, la sesión local se elimina y se marca como expirada.
- Antes de operaciones remotas se refresca una sesión próxima a caducar.
- La caché académica se asocia al UUID activo y se purga cuando cambia la cuenta o al cerrar sesión.
- El logout remoto ya llamaba a `/auth/v1/logout`, pero cualquier fallo de red/API se silenciaba antes de borrar la sesión local.

Ese último comportamiento no mantenía al navegador autenticado, pero impedía saber si Supabase había confirmado la revocación remota.

## Cambio v70

`remoteSignOut()` ahora devuelve estado explícito:

- `hadSession`: existía una sesión local que cerrar;
- `remoteRevoked`: se pudo confirmar el logout remoto.

La limpieza local sigue siendo fail-safe: se eliminan los tokens de `sessionStorage`, el estado Auth y la caché académica aunque el endpoint remoto no responda.

Si había una sesión y la revocación remota no pudo confirmarse, el logout de la interfaz muestra un aviso claro. No se conservan tokens para reintentos posteriores.

No se ha modificado el flujo de recovery; sus llamadas a `remoteSignOut()` pueden ignorar el resultado y mantienen la limpieza local actual.

## Retest estático

- 143 `<button>` / 143 `</button>` — PASS.
- 5 `<form>` / 5 `</form>` — PASS.
- `sessionStorage` sigue presente para Auth — PASS.
- `refreshRemoteSessionSerialized` sigue presente — PASS.
- `requestPasswordRecovery(email)` sigue presente — PASS.
- nuevo estado `remoteRevoked/hadSession` — PASS.
- aviso de revocación remota no confirmada — PASS.

## Riesgo residual

Un access token JWT ya emitido puede seguir siendo aceptable hasta su expiración si un backend valida únicamente la firma/expiración del JWT. El cierre de sesión invalida la capacidad de renovar la sesión cuando la revocación remota se completa, pero no se implementa en esta revisión una comprobación de `session_id` contra `auth.sessions` para cada operación.

Para el estado actual del campus, el hardening aplicado mejora el comportamiento sin introducir dependencia de red para el logout local. Una política de revocación inmediata por sesión puede evaluarse más adelante para operaciones administrativas especialmente sensibles.

## Veredicto

**v70 PASS en QA estático de sesión/logout; pendiente prueba real con login, refresh, corte de red y logout en navegador.**

Producción Netlify no se ha modificado, `main` no se ha fusionado y no se ha publicado release final.
