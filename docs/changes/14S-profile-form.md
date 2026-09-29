# 14S · Ficha del alumno dentro de Mi perfil

Fecha: 2026-09-07

## UX

La ficha del alumno se integra en la zona `Mi perfil`, accesible desde la esquina superior derecha del campus.

### Campos

- Nombre (obligatorio)
- Primer apellido (obligatorio)
- Segundo apellido (opcional)
- Correo electrónico (solo lectura, procede de Auth)
- Teléfono (opcional)

No se incluye DNI, NIE, pasaporte ni ningún campo de documento identificativo.

### Certificación

- Previsualización dinámica del nombre.
- Confirmación específica del nombre para el certificado.
- Si nombre/apellidos cambian, la confirmación anterior se invalida automáticamente en base de datos.
- Email y teléfono se consideran privados y no deben exponerse en el certificado ni en el verificador público.

### Guardado

- Escritura real sobre `public.profiles` mediante la sesión autenticada.
- RLS existente limita la edición del alumno a su propia fila.
- El trigger `private.guard_profile_update()` mantiene protegidos `user_id`, `real_name`, `role`, `student_code`, `active` y `created_at`.
- Se evita confirmar el nombre mientras existen cambios sin guardar.
- Feedback de `Cambios sin guardar`, `Guardando…`, éxito y error.

### Móvil

La acción Guardar se mantiene accesible en una barra sticky ligera sobre la navegación inferior.

## Protección de datos

La estructura de datos ya admite constancia de lectura de la información de privacidad, pero la UI de confirmación legal no se activa todavía: antes de beta hay que configurar el nombre legal del responsable y el email de privacidad. No se inventan esos datos.

## Base de datos

Migración:

`supabase/migrations/20260907141500_student_profile_certificate_data_14s.sql`

Aplicada correctamente en Supabase el 2026-09-07.

## Asset de desarrollo

`development-14s-profile-form-index.html`

Versión: `18`

SHA-256:

`24d45d0a58d289008a01cb37e8db220462939c379c3134e785147fa4be895dd2`

Este asset aún no sustituye la producción de Netlify.
