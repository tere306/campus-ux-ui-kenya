# 14T · Acceso contextual al perfil

Fecha: 2026-09-07

## Decisión UX actualizada

El acceso principal al perfil se coloca en la **tarjeta inferior de la navegación lateral**, exactamente en la zona donde se mostraban el nombre de la alumna y el porcentaje completado.

Esta ubicación se considera más natural porque esa tarjeta ya representa a la persona que está usando el campus.

## Escritorio

La tarjeta inferior pasa a ser interactiva y muestra:

- avatar con inicial;
- nombre;
- `Mi perfil · X% completado` en modo Alumna;
- `Mi perfil · Admin` en modo Admin;
- chevron de navegación;
- estado activo cuando la página `profile` está abierta.

Al pulsarla se abre `Mi perfil`.

El acceso de perfil de la cabecera superior se oculta en escritorio para evitar duplicidad.

## Móvil

Como la tarjeta inferior del sidebar desaparece al convertirse la navegación en barra inferior, el avatar de perfil se conserva en la cabecera **solo en móvil**. De este modo el perfil sigue siendo accesible sin añadir otro elemento a la bottom navigation.

## Página Mi perfil

Incluye:

- identidad de la cuenta;
- email autenticado cuando está disponible;
- rol/es del campus;
- estado de matrícula;
- versión curricular;
- ficha del alumno;
- nombre para certificación;
- estado de confirmación del nombre.

No se recogen DNI, NIE, pasaporte ni otros documentos de identidad. Email y teléfono permanecen privados.

## Integración con Inicio

Mientras la ficha esté incompleta o el nombre no esté confirmado, Inicio muestra un aviso contextual con CTA `Completar ficha` o `Revisar y confirmar`.

Cuando el nombre queda confirmado, el estado cambia a `Datos de certificación confirmados` y el aviso deja de comportarse como una tarea pendiente.

## Estado de desarrollo actual

Asset Supabase:

`development-14s-14t-profile-readiness-index.html`

Versión: `19`

SHA-256:

`1973fbb057f5960a50d636f943dc4dd28dc35b7ead5688313748c5101d6dc060`

Producción de Netlify no se ha sobrescrito con este asset todavía.
