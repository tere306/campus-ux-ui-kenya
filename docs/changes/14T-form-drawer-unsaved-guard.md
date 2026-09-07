# 14T · Protección de formularios largos en drawers

Fecha: 2026-09-07

## Problema

Los formularios de entrega y evaluación se abren en paneles laterales. Antes, cerrar con `×`, pulsar fuera del panel o usar `Esc` podía descartar cambios no guardados sin advertencia.

## Solución

Se añade una protección común de cambios pendientes para drawers editables.

Cuando hay cambios sin guardar en:

- una entrega del alumno;
- una evaluación Admin;

el campus avisa antes de cerrar mediante:

- botón `×`;
- click en el fondo del drawer;
- tecla `Esc`.

El aviso solo aparece cuando el formulario ha cambiado realmente. Los cierres programáticos posteriores a un guardado siguen siendo directos.

## Entregas

Se marca el drawer como modificado al cambiar:

- memoria;
- enlace principal;
- enlace de evidencia.

Guardar borrador o enviar correctamente cierra el panel y limpia el estado pendiente.

## Evaluaciones

Se marca el drawer como modificado al cambiar:

- cualquier criterio de rúbrica;
- feedback docente;
- inserción de la plantilla de feedback.

Publicar correctamente limpia el estado pendiente.

## UX

El mensaje es simple: `Cambios sin guardar` y ofrece `Salir sin guardar` o cancelar para volver al formulario.

No se añade un modal en acciones normales; solo aparece cuando existe riesgo real de perder trabajo.

## Asset de desarrollo

`development-14t-form-drawer-guard-index.html`

Versión: `23`

SHA-256:

`3bbadcfc6ed9ff1063c01572ac29a3a29ee109d05997aeae1db5e230dcffb3f2`

Producción de Netlify permanece intacta.
