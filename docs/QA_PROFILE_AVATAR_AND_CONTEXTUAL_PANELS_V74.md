# QA · Perfil visual y paneles contextuales · v74

Fecha: 2026-09-08

## Alcance

- Foto de perfil opcional para cuentas del Campus.
- Almacenamiento privado de avatar en Supabase Storage.
- Avatar reutilizado en Mi perfil, cabecera y navegación lateral.
- Fallback por iniciales cuando no existe foto o no puede cargarse.
- Compresión/crop en navegador a 512×512 WebP antes de subir.
- Subida, cambio y eliminación de foto.
- Panel contextual de práctica desde cada clase.
- En la clase 1.1 el panel ofrece el caso asignado de IKEA España con enlace directo.
- Limpieza adicional de referencias técnicas visibles en la experiencia de alumna.

## Backend

Migración aplicada: `20260908121809_campus_profile_avatar_storage_v14u`.

- `profiles.avatar_path` añadido.
- Bucket `campus-avatars`: privado.
- Límite de objeto: 2 MB.
- MIME admitidos: JPEG, PNG, WebP.
- RLS de Storage: lectura propia o Admin; escritura/actualización/borrado únicamente en la carpeta del propio usuario.
- Check de `avatar_path`: la ruta debe pertenecer al UUID del perfil y usar el patrón de avatar esperado.
- La foto no forma parte del certificado ni del verificador público.

## Frontend

Fuente dinámica: `development-current-index.html`, versión 74.

- SHA-256 de la fuente en Supabase: `c9371d964b81133b0c96bf05eb3a3d0f7dd4cea05e442cedf54beedf2a50dbf4`.
- Tamaño lógico: 725865 caracteres.
- JavaScript local extraído y validado con `node --check`: PASS.
- Marcadores estáticos comprobados: runtime de avatar, UI de foto, carga/subida/eliminación, botón de guía práctica, drawer de guía e IKEA: PASS.

## UX / privacidad

- Avatar opcional; las iniciales siguen siendo fallback.
- No se solicita documento de identidad.
- La foto se sirve autenticada desde bucket privado.
- Se eliminaron textos de alumna como “guardado en Supabase” y referencias de estado que exponían al proveedor técnico.
- Los paneles son secundarios/contextuales; la navegación principal continúa siendo por páginas.
- En móvil los drawers mantienen el comportamiento de bottom sheet ya introducido en v73.

## Seguridad

Security Advisor tras la migración: sin nuevos hallazgos derivados de este cambio. Permanece el aviso previo de proyecto `auth_leaked_password_protection`: Leaked Password Protection está desactivado.

## Pendiente de QA real

- Subir una foto desde una sesión real de alumna y comprobar persistencia tras F5/nuevo login.
- Cambiar la foto y comprobar eliminación best-effort del objeto anterior.
- Eliminar la foto y verificar fallback por iniciales.
- Abrir “Guía práctica” en desktop y móvil.
- Comprobar que IKEA abre en nueva pestaña y que el panel conserva foco/cierre accesible.
- Publicar v74 en Netlify únicamente con paquete completo que conserve `_headers` y `_redirects` además de `campus-logo.webp`.
