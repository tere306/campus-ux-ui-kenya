# 14S/14T · Perfil, certificado y limpieza de fuente v27–v33

Fecha: 2026-09-07

## Perfil consciente del rol

Una cuenta exclusivamente Admin ya no ve ni puede confundir la ficha de certificación con su perfil administrativo.

- Alumna o cuenta Alumna+Admin: mantiene la ficha de datos y certificación.
- Admin sin matrícula: muestra únicamente identidad y acceso administrativo.

## Estado de certificación en Admin

La vista `Alumnas` muestra el estado de la ficha de certificación:

- Incompleta
- Pendiente de confirmar
- Confirmada
- Sin datos remotos

Esto evita tener que abrir cada ficha para saber si la alumna está preparada.

## Identidad en la navegación

La tarjeta inferior de perfil usa siempre el nombre real de la cuenta autenticada.

Al cambiar a Admin ya no sustituye el nombre por `Administración`; por ejemplo, Tere sigue viendo `Tere · Mi perfil · Admin`.

## Certificado dentro de Mi perfil

Si existe una credencial emitida, `Mi perfil` muestra:

- estado válido/revocado;
- código público;
- acceso a la comprobación pública.

No se muestran hashes, IDs internos ni datos privados.

El botón de certificado usa el código concreto del propio botón y no depende del alumno activo en memoria, evitando abrir accidentalmente otra credencial.

## Limpieza de HTML

Se corrigió una regla `prefers-reduced-motion` que había quedado fuera de `</html>` durante el trabajo incremental. Ahora forma parte del `<style>` principal dentro de `<head>`.

También se eliminó del asset de desarrollo el script HUD que Netlify había inyectado al servir la página. Ese script pertenece al hosting y no debe formar parte del código fuente que posteriormente se vuelva a desplegar.

## Asset de desarrollo actual

`development-14t-clean-source-index.html`

Versión: `33`

SHA-256:

`42d613a7f7fa8fc9d011497361bb0d40723b7f4c9b6cc8a4b60ad8125a9e2f1c`

Comprobaciones estructurales realizadas:

- apertura/cierre de botones equilibrada: 129/129;
- backticks de template literal: número par;
- un único bloque `<style>` dentro del documento;
- sin HUD Netlify embebido;
- el documento termina correctamente en `</html>`.

Producción de Netlify sigue sin ser sustituida.
