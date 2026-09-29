# 14T · Navegación, botones y cambios sin guardar

Fecha: 2026-09-07

## Objetivo

Reducir fricción y ambigüedad sin sobrecargar la interfaz con animaciones decorativas.

## Jerarquía de acciones

- En clases completadas, `Siguiente clase →` pasa a ser la acción principal.
- `Marcar como pendiente` queda como acción secundaria.
- En la última clase completada, `Ir al proyecto →` pasa a ser CTA principal.
- Los módulos ya aprobados dejan de mostrar un CTA primario y pasan a `Revisar módulo` como acción secundaria.
- En el primer acceso se elimina el CTA duplicado `Empezar Módulo 1` de la tarjeta introductoria; la acción principal queda en `Tu siguiente paso`.
- El aviso `Completar ficha` / `Revisar y confirmar` del dashboard queda como acción secundaria para no competir con el siguiente paso académico.

## Copy de botones

Se sustituyen etiquetas genéricas por acciones explícitas:

- `Abrir` → `Abrir módulo`
- `Entregar` → `Preparar entrega`
- `Continuar` → `Continuar borrador`
- `Ver` → `Ver entrega`
- `Iterar` → `Corregir y reenviar`
- `Evaluar` → `Evaluar entrega`
- `Gestionar ficha` → `Abrir ficha`
- `Evaluaciones` → `Ver evaluaciones`
- `Ver todas` → `Ver todas las evaluaciones`
- `Recargar` → `Actualizar cola`

No quedan botones con el texto exacto genérico `Abrir`, `Ver` o `Continuar` en este asset.

## Microinteracciones

Los botones incorporan transiciones de 160 ms únicamente para:

- color de fondo;
- borde;
- color de texto;
- feedback de estado.

No se añaden rebotes, zooms, parallax ni desplazamientos decorativos. `prefers-reduced-motion` elimina estas transiciones.

## Protección de cambios sin guardar

La ficha del alumno detecta cambios pendientes.

Si el usuario intenta:

- navegar a otra sección;
- cambiar Alumna/Admin;
- abrir una sección del menú móvil;
- cerrar sesión;
- recargar/cerrar la pestaña;

con datos de perfil sin guardar, el campus avisa antes de descartarlos.

El aviso solo aparece cuando existe riesgo real de perder cambios.

## Asset de desarrollo

`development-14t-unsaved-navigation-index.html`

Versión: `22`

SHA-256:

`6dbd4a4dbe29b187b1091a1458db722c155c5a0a7bdaea9fe1c9b026fa32b48c`

Producción de Netlify no se ha sustituido por este asset.
