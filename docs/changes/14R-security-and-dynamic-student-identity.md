# 14R · Seguridad de acceso e identidad dinámica de alumnado

Fecha: 2026-09-07

## Objetivo

Eliminar dependencias de identidad local y preparar el campus para trabajar con cuentas reales de Supabase sin asociarlas por nombre.

## Cambios de frontend en desarrollo

El asset estable `development-current-index.html` ha avanzado hasta la versión 50.

SHA-256 de v50:

`e1f1b96ceb1a3e09e61fb4171f1c1aecac9bb6eea31086a438c52f1776a6d56e`

### Auth

- Inicio de sesión únicamente mediante Supabase Auth real.
- Eliminado el acceso administrativo local/de contingencia del frontend de desarrollo.
- Eliminada la restauración de sesiones heredadas.
- El selector Alumna/Admin se deriva únicamente de los roles remotos.
- Login por email con `type=email`.
- No existe `service_role` en el frontend.

### Identidad de alumnado

Antes, parte de la compatibilidad local asociaba estudiantes mediante nombres concretos. Esto no es adecuado para una beta real.

La versión 50 cambia la identidad local de trabajo para usar el `user_id` estable de Supabase:

- la alumna autenticada usa su UUID remoto como identificador local de sesión;
- Admin relaciona entregas, perfiles y resumen académico por `studentId`, no por coincidencias de nombre;
- el directorio local de la interfaz se hidrata desde el overview remoto de matrículas;
- se elimina la lista estática de estudiantes del estado inicial;
- se elimina la asignación administrativa basada en un nombre concreto;
- se eliminan identidades/estados de activación hardcodeados del bundle.

Esto permite que futuras matrículas reales se incorporen sin editar el frontend para añadir nombres manualmente.

## Navegabilidad acumulada

- `← Volver al programa` determinista.
- Restauración de posición del Programa.
- Continuación por la primera clase pendiente.
- CTAs de módulo según estado: empezar, continuar, revisar, entregar o revisar feedback.
- `Ruta cercana` de Inicio usa el estado académico real para elegir la acción.
- Mi perfil integrado en la tarjeta inferior izquierda.

## Seguridad de publicación

La antigua Edge Function `pioc-publish-web` permitía ejecutar una publicación de Storage sin autenticación de usuario. No estaba referenciada por el frontend actual y existe el flujo autenticado `publish-frontend-release`.

Se ha desactivado `pioc-publish-web` conservando el slug y devolviendo HTTP 410. No se ha cambiado Netlify producción.

## Pendiente de QA

El cambio de identidad dinámica requiere validación en navegador antes de producción:

1. login real de una cuenta Alumna;
2. login de una cuenta Admin;
3. cuenta con rol Alumna + Admin;
4. persistencia después de recarga;
5. listado Admin sin estudiantes duplicados;
6. entregas/evaluaciones enlazadas al UUID correcto;
7. perfil y certificado del alumno correcto;
8. aislamiento entre usuarios.

Producción continúa sin sustituirse por este asset.
