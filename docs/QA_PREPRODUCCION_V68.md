# QA preproducción v68

Fecha: 2026-09-08

## Baseline verificado

Alias Supabase: `development-current-index.html`.

- versión: **68**
- SHA-256: `2892a974c167b281bdfcf651c1c46f7ceab9ef7157db16f0adf09edf3e5f32b1`
- tamaño aproximado del HTML almacenado: 711467 caracteres.

Delta desde v64:
- v65: escape de `admin next action`.
- v66: escape de CTA de alumna en Admin.
- v67: escape de etiquetas de currículo.
- v68: escape de `student drawer next action`.

Estas revisiones son hardening de salida dinámica; no cambian el modelo de autorización.

## Comprobaciones estáticas ejecutadas sobre el alias v68

- `<button>`: 143 aperturas / 143 cierres — PASS.
- `<form>`: 5 aperturas / 5 cierres — PASS.
- `type="submit"`: 5 — consistente con la matriz anterior.
- `history.back`: 0 ocurrencias — PASS.
- `service_role` en frontend: 0 ocurrencias — PASS.
- `target="_blank"`: 6 ocurrencias textuales.
  - 5 son enlaces generados y llevan `rel="noopener"`.
  - la sexta es el selector JS `a[target="_blank"]` usado para reforzar todos esos enlaces en runtime añadiendo `noopener`, `noreferrer` y `aria-label`; no es un enlace adicional sin protección.

En los enlaces externos revisados se mantiene `safeHttpHref(...)` antes de inyectar la URL.

## Supabase Security Advisor

Sigue existiendo un único aviso automático de seguridad:
- `auth_leaked_password_protection`: Leaked Password Protection Disabled.

Referencia:
https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

## Preview

`campus-development-preview` sigue protegido y separado de producción, pero la clave está actualmente incrustada en el source desplegado de la Edge Function. Su valor no debe documentarse ni versionarse.

Pendiente antes de producción:
1. externalizar la clave a secret/runtime env;
2. rotarla;
3. comprobar acceso autorizado/no autorizado;
4. confirmar ausencia de la clave en Git y artefactos públicos.

## Browser QA

No se marca como ejecutado. El runtime disponible en esta pasada no incluye `agent-browser` y el contenedor no tiene resolución DNS externa, por lo que no existe evidencia válida para afirmar QA visual.

Sigue pendiente validar de forma real:
- 320/360/390/412 px;
- tablet y escritorio;
- login/F5/logout;
- Alumna/Admin y cuenta dual-role;
- cambio de cuenta y purga de caché;
- invitación/activación con segunda identidad;
- entrega/evaluación/feedback/desbloqueo;
- recuperación de contraseña y redirects de email.

## Veredicto

**v68: PASS en la ampliación estática ejecutada; sigue READY FOR BROWSER QA — NOT READY FOR PRODUCTION.**

Producción Netlify no se ha modificado, no se ha fusionado a `main` y no se ha publicado release final.
