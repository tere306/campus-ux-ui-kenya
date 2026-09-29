# QA Auth recovery v69

Fecha: 2026-09-08

## Hallazgo

La release de desarrollo v68 sí incluye recuperación de contraseña, implementada directamente contra Supabase Auth/GoTrue:

- `POST /auth/v1/recover?redirect_to=...`
- verificación alternativa de `token_hash` con `type: recovery`
- actualización de contraseña mediante `PUT /auth/v1/user`
- limpieza del fragmento/query sensible mediante `history.replaceState(...)`
- cierre de sesión después de actualizar la contraseña
- política de contraseña de 12–256 caracteres y mínimo 3 grupos de caracteres en el frontend

El problema detectado es ambiental: `recoveryRedirectUrl()` estaba fijado a `PRODUCTION_ORIGIN`. Desde el preview de desarrollo, pulsar “He olvidado mi contraseña” podía iniciar un flujo cuyo email regresara a Netlify production, mezclando preproducción con producción.

## Corrección v69

Se ha creado el asset:

- `development-14y-isolate-recovery-redirect-index.html`
- versión: **69**
- SHA-256: `648d732354559f3aae43c43fe13d030bb255349ecb7f9587714b8b830f4e2502`
- alias actualizado: `development-current-index.html`

Cambio funcional:

- `requestPasswordRecovery(email)` rechaza el inicio de recuperación cuando `location.origin !== PRODUCTION_ORIGIN`.
- En el origen final de producción, el flujo conserva el comportamiento previo y sigue usando el callback de producción.
- No se ha modificado Netlify production.

Esto evita que una prueba desde el preview genere enlaces que salten accidentalmente al frontend público.

## Verificaciones automáticas posteriores

Sobre `development-current-index.html` v69:

- 143 `<button>` / 143 `</button>` — PASS.
- 5 `<form>` / 5 `</form>` — PASS.
- guard de aislamiento de recuperación presente — PASS.
- endpoint `/auth/v1/recover?redirect_to=` presente — PASS.
- callback final a `PRODUCTION_ORIGIN/?recovery=1` conservado — PASS.
- el handler de recuperación limpia `hash`, `token_hash` y `type` mediante `history.replaceState` antes de mostrar el formulario — PASS estático.
- después de cambiar la contraseña se ejecuta logout, se limpia el estado de recuperación de la URL y se vuelve al login — PASS estático.

## Lo que todavía NO puede marcarse como validado

No se ha enviado un email real de recuperación ni se ha usado un enlace real. Sigue pendiente comprobar con una cuenta real:

1. que la URL de producción esté incluida correctamente en la configuración de Redirect URLs de Supabase Auth;
2. entrega real del email y plantilla;
3. apertura del enlace en navegador;
4. intercambio/lectura del token de recuperación;
5. cambio de contraseña;
6. invalidación/cierre correcto de la sesión de recuperación;
7. login posterior con la nueva contraseña.

La conexión disponible no expone actualmente una acción de Management API para leer o modificar la configuración de Redirect URLs de Auth, por lo que ese punto no se ha inferido ni alterado.

## Nota de plataforma

En 2026 Supabase mantiene la recomendación de usar Redirect URLs autorizadas para los flujos de recuperación y de proteger contraseñas filtradas mediante Leaked Password Protection. El Security Advisor del proyecto sigue mostrando únicamente `auth_leaked_password_protection` como aviso de seguridad pendiente.

## Veredicto

**v69 elimina el cruce preview → production en el inicio de recuperación y mantiene intacto el flujo de producción. Sigue READY FOR BROWSER QA — NOT READY FOR PRODUCTION.**

No se ha fusionado a `main`, no se ha desplegado Netlify y no se ha publicado release final.
