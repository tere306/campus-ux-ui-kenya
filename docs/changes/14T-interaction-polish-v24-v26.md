# 14T · Pulido de interacción v24–v26

Fecha: 2026-09-07

## Estados de carga

Las acciones persistentes principales ya no se limitan a deshabilitarse sin explicación.

Se muestran estados contextuales y `aria-busy` en:

- `Guardar cambios` → `Guardando…`
- confirmación del nombre → `Confirmando…`
- `Guardar borrador` → `Guardando…`
- `Enviar entrega` / nueva iteración → `Enviando…`
- `Publicar evaluación` → `Publicando…`

Se mantiene la protección contra doble click mientras existe una petición activa.

Asset intermedio: `development-14t-action-loading-index.html` · v24.

## Cabecera móvil y perfil

En pantallas móviles se elimina el botón `Salir` de la cabecera para reducir saturación junto al selector Alumna/Admin y el avatar.

`Cerrar sesión` permanece disponible dentro de `Mi perfil`, con texto explícito y tamaño táctil completo.

En escritorio se conserva el acceso habitual.

Asset intermedio: `development-14t-mobile-profile-nav-index.html` · v25.

## Volver al programa conservando contexto

Cuando una alumna entra a un módulo desde `Programa`, el campus conserva la posición del listado.

Al pulsar `← Volver al programa` desde el aula:

- vuelve de forma determinista a `Programa`;
- no usa un `history.back()` ciego;
- restaura la posición previa del listado;
- mantiene el foco accesible en el título sin forzar el scroll al inicio.

Si el módulo se abrió desde Inicio u otro acceso directo, no se reutiliza una posición antigua del Programa.

## Asset actual de esta pasada

`development-14t-program-return-context-index.html`

Versión: `26`

SHA-256:

`5ae252d8be2237eda43d9be7a5d913aefa27496c78524ab70c563260717d050b`

Producción de Netlify continúa intacta.
