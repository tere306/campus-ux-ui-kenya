# QA recovery fail-closed · v71

Fecha: 2026-09-08

## Alcance

Revisión estática del flujo de recuperación de contraseña sobre el alias `development-current-index.html` en Supabase.

Baseline revisado: v70.

Resultado aplicado: **v71**

- slug versionado: `development-14z-scrub-invalid-recovery-session-index.html`
- alias: `development-current-index.html`
- SHA-256: `f3b4aadee130d94222f0faa351e6d488f99d86bfee57bc876ce0e05b9c8fb004`
- longitud: 712283 caracteres

## Hallazgo

El flujo válido ya limpiaba el fragmento y los parámetros de Auth de la URL después de obtener una sesión de recovery.

Sin embargo, el camino de error —enlace caducado, consumido, recargado o token inválido— mostraba correctamente que la recuperación ya no era válida, pero podía dejar:

- `token_hash` / `type` en la URL cuando el intercambio fallaba;
- una sesión temporal de recovery previamente guardada en `sessionStorage` si la página se recargaba antes de establecer la nueva contraseña.

No se verificó una escalada de privilegios a partir de este comportamiento, pero mantener credenciales temporales en URL o almacenamiento tras declarar el recovery inválido contradice un diseño fail-closed.

## Corrección v71

Cuando el flujo entra en estado de recovery inválido:

1. elimina `AUTH_SESSION_KEY` de `sessionStorage`;
2. elimina el fragmento de la URL;
3. elimina `token_hash`;
4. elimina `type`;
5. conserva únicamente `?recovery=1` para que la UI pueda explicar el estado sin credenciales;
6. mantiene el mensaje que obliga a solicitar un enlace nuevo.

No se amplía la superficie de Auth ni se permite iniciar recovery desde preproducción. La protección de v69 sigue intacta: la solicitud de email solo puede iniciarse desde `PRODUCTION_ORIGIN`.

## Retest estático

Sobre v71:

- botones: 143 aperturas / 143 cierres — PASS;
- formularios: 5 aperturas / 5 cierres — PASS;
- `sessionStorage` sigue siendo el almacén de sesión Auth — PASS;
- `remoteSignOut` sigue presente — PASS;
- limpieza de `token_hash` — PASS;
- limpieza de `type` — PASS;
- `history.replaceState` para saneado de URL — PASS;
- borrado local de `AUTH_SESSION_KEY` en recovery inválido — PASS.

## Contraste con documentación oficial

La documentación actual de Supabase exige que las URLs de redirect estén permitidas en Auth y recomienda limpiar de la URL los parámetros usados para intercambio de tokens. También documenta que el flujo de recuperación obtiene una sesión temporal antes de actualizar la contraseña.

El frontend sigue usando un flujo client-side y la prueba real del email/redirect queda pendiente hasta validar la configuración final del origen de producción.

## Configuración externa pendiente

Las herramientas disponibles en esta ejecución permiten consultar base de datos y documentación, pero no exponen una acción de gestión de configuración Auth del proyecto ni una acción de gestión de secretos de Edge Functions.

Por tanto, no se han cambiado de forma no verificable:

- Site URL / Additional Redirect URLs;
- Leaked Password Protection;
- configuración SMTP;
- secreto runtime del preview.

Estos puntos siguen siendo configuración externa previa a producción.

## Veredicto

**PASS estático v71 para hardening de recovery inválido.**

No equivale a un test real de email: siguen pendientes envío real, click del enlace, callback autorizado, cambio efectivo de contraseña y nuevo login.

Producción Netlify, `main` y release final: sin cambios.
