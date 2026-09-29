# QA · white-label operativo · v79

Fecha: 2026-09-08

## Objetivo

Evitar que la experiencia del Campus exponga nombres de proveedores o lenguaje de infraestructura como parte de la interfaz académica.

## Cambios

- estados de conexión pasan de “backend” a “servicio del Campus / servicio académico”;
- mensajes de sesión pasan de “Auth real” a “sesión segura” cuando se muestran en UI;
- estados de entregas, accesos, resumen, cierre y certificado usan lenguaje académico;
- Admin deja de mostrar nombres de proveedores en títulos, ayudas, confirmaciones y toasts;
- evaluaciones publicadas, desbloqueos y finalización del expediente hablan de Campus/expediente y no del proveedor;
- preparación de release habla de producción, URL oficial del Campus y cabeceras de seguridad;
- el contenido docente conserva términos técnicos como backend cuando forman parte del temario y no identifican un proveedor concreto.

## Verificación del candidato local

Archivo: `campus-v79-production/index.html`.

- JavaScript: `node --check` PASS.
- `Supabase` como etiqueta visible/cadena de marca en el HTML candidato: **0**.
- `Netlify` como etiqueta visible/cadena de marca en el HTML candidato: **0**.
- `service_role` en frontend: **0**.
- el logo sigue referenciado como `campus-logo.webp`.

Los dominios técnicos necesarios para ejecución continúan existiendo como constantes/URLs de runtime en minúsculas (`*.supabase.co`, `*.netlify.app`). No se muestran como copy del Campus y no contienen claves administrativas.

## Fuente dinámica

`development-current-index.html` actualizado a **v79**.

- caracteres: 730302 en la versión almacenada tras la normalización de copy;
- SHA-256 PostgreSQL UTF-8: `f31035bd374371fad6b285517cdb71b4c10bc1f2fd89643561255ae85ca94e79`;
- comprobación SQL: sin etiquetas `Supabase` ni `Netlify`.

La fuente dinámica y el candidato local son funcionalmente equivalentes en este bloque de white-label, aunque no se declara identidad byte-a-byte entre ambas representaciones.

## Producción

No modificada durante este cambio. El deploy actual sigue siendo `6a9fe602a0f119440cda97c1`.
