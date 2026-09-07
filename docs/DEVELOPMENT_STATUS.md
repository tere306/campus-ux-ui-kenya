# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14
- Producción no se ha sustituido durante los cambios 14S/14T de esta sesión.

## Desarrollo actual

Supabase mantiene un alias estable al asset de trabajo más reciente:

`development-current-index.html`

Estado actual:

- versión de desarrollo: **34**
- SHA-256: `47fec7929d842fc6ca59a89913f586f3b42c4a2287a1a075893fe113c304abc2`
- asset histórico equivalente: `development-14t-copy-audit-index.html`

## Cambios acumulados principales

- `← Volver al programa` contextual y determinista.
- Restauración de posición al volver desde un módulo al Programa.
- Mi perfil integrado en la tarjeta inferior izquierda de escritorio.
- Avatar de perfil compacto en móvil.
- Ficha del alumno dentro de Mi perfil.
- Nombre + apellidos para certificado; segundo apellido opcional.
- Sin DNI/NIE/pasaporte.
- Teléfono opcional y privado.
- Confirmación explícita del nombre de certificado.
- Invalidación de confirmación al modificar nombre/apellidos.
- Bloqueo backend de emisión si la ficha no está confirmada.
- Verificador público reducido a datos mínimos.
- Estado de ficha visible para Admin.
- Certificado emitido visible desde Mi perfil cuando exista.
- Copy de botones más explícito.
- Jerarquía de CTA revisada en clases, módulos y dashboard.
- Estados `Guardando`, `Enviando`, `Publicando` y `aria-busy`.
- Protección contra pérdida de cambios en perfil, entregas y evaluaciones.
- Cabecera móvil simplificada; `Cerrar sesión` pasa a Mi perfil en móvil.
- Microtransiciones de 160 ms sin animaciones decorativas.
- `prefers-reduced-motion` respetado.
- HTML de desarrollo limpiado del HUD inyectado por Netlify.

## QA estático del asset v34

Comprobado en Supabase:

- documento termina en `</html>`: PASS
- sin HUD Netlify embebido: PASS
- botones apertura/cierre equilibrados: PASS
- forms apertura/cierre equilibrados: PASS
- un único bloque de estilos: PASS
- template literals con backticks pares: PASS
- sin `history.back()` ciego: PASS
- navegación contextual al Programa: PASS
- restauración del contexto del Programa: PASS
- protección de cambios sin guardar del perfil: PASS
- protección de drawers editables: PASS
- loading en borrador/entrega/evaluación: PASS
- reduced motion: PASS
- perfil accesible en escritorio y móvil: PASS
- sin `service_role` en frontend: PASS
- sin campos de documento de identidad: PASS
- verificador público mínimo: PASS

## Pendiente antes de producción

1. Cerrar los datos reales de protección de datos: responsable y email de privacidad.
2. Ejecutar QA en navegador sobre una URL desplegada de esta versión.
3. Probar 320/360/390/412 px, tablet y escritorio.
4. Login real, recarga, Alumna/Admin, perfil, entrega, evaluación y certificado.
5. Solo después actualizar producción y `main`.
