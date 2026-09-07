# 14T · Acceso contextual al perfil

Fecha: 2026-09-07

## Decisión UX

La zona superior derecha que antes mostraba el nombre de la cuenta y el texto técnico de sesión pasa a ser el acceso principal al perfil personal.

## Comportamiento

- Avatar con iniciales + nombre + `Mi perfil · Alumna/Admin`.
- Click/tap abre una página `Mi perfil`.
- En móvil se conserva solo el avatar para evitar saturar la cabecera.
- El detalle técnico de la sesión deja de ocupar espacio principal.
- El acceso se marca como activo cuando la página `profile` está abierta.
- El botón es accesible mediante teclado y `aria-current`.

## Página de perfil inicial

Incluye:

- identidad de la cuenta;
- email autenticado cuando está disponible;
- rol/es del campus;
- estado de matrícula;
- versión curricular;
- sección reservada para la ficha del alumno y datos de certificación.

La sección de certificación deja explícito que no se recogerán DNI, NIE, pasaporte ni otros documentos de identidad y que email/teléfono permanecerán privados.

## Estado de desarrollo

Asset de desarrollo Supabase:

`development-14t-profile-entry-index.html`

Versión: `17`

SHA-256:

`299a0f7067ab847ce2292460b3d36e9f7947d54c5dc9ec3c58519d4a7eceffad`

Producción no se ha sobrescrito con este cambio todavía.
