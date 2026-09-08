# 14S · Estado de ficha de certificación para Admin

Fecha: 2026-09-07

## Objetivo

Cuando Admin abre la ficha de una alumna, el campus muestra también el estado real de sus datos de certificación.

## Estados

- `Incompleta`: falta nombre y/o primer apellido.
- `Pendiente de confirmar`: los datos están guardados pero la alumna aún no ha confirmado cómo aparecerá su nombre.
- `Confirmada`: nombre de certificado confirmado y preparado para emisión.

Si hay teléfono de contacto, Admin puede verlo dentro de la ficha privada de la alumna. No se expone públicamente.

## Emisión de certificado

Aunque el expediente académico esté finalizado, el botón `Emitir certificado verificable` solo aparece si la ficha de certificación está preparada.

Si no lo está, Admin ve un mensaje claro indicando que la alumna debe completar/confirmar su nombre desde `Mi perfil`.

El backend aplica la misma regla, de modo que la protección no depende únicamente de la interfaz.

## Inicio de la alumna

El aviso `Completar ficha` / `Revisar y confirmar` desaparece una vez que la alumna confirma correctamente el nombre. El estado confirmado sigue siendo visible dentro de `Mi perfil`, evitando ruido permanente en Inicio.

## Perfil en navegación

En escritorio, `Mi perfil` está integrado en la tarjeta inferior de la navegación lateral, junto al nombre y porcentaje de progreso. En móvil, el acceso se mantiene mediante el avatar compacto de la cabecera.

## Asset de desarrollo

`development-14s-14t-admin-profile-status-index.html`

Versión: `20`

SHA-256:

`c2b4a96917cdd35cda5b68e10ffb17dda7c33dce20785b3488091cfa0a418ee0`

Producción de Netlify permanece sin sustituir por este asset.
