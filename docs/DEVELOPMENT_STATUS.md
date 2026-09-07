# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14
- Producción no se ha sustituido durante los cambios 14S/14T/14R de esta sesión.

## Desarrollo actual

Supabase mantiene un alias estable al asset de trabajo más reciente:

`development-current-index.html`

Estado actual:

- versión de desarrollo: **42**
- SHA-256: `3ffd0b612f25173c5ead566fcf24494e99b56ffba2bd52ab93735661e8e70cd2`
- asset histórico equivalente: `development-14r-email-login-only-index.html`

## Cambios acumulados principales

### Navegación y UX

- `← Volver al programa` contextual y determinista.
- Restauración de posición al volver desde un módulo al Programa.
- El acceso a un módulo en curso continúa por la primera clase pendiente en lugar de volver siempre a la clase 1.
- Los CTAs del Programa distinguen `Empezar módulo`, `Continuar módulo` y `Revisar módulo`.
- Mi perfil integrado en la tarjeta inferior izquierda de escritorio.
- Avatar de perfil compacto en móvil.
- Copy de botones más explícito y jerarquía de CTA revisada.
- Microtransiciones de 160 ms sin animaciones decorativas.
- `prefers-reduced-motion` respetado.

### Ficha del alumno y certificación

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

### Formularios y acciones

- Estados `Guardando`, `Enviando`, `Publicando` y `aria-busy`.
- Protección contra pérdida de cambios en perfil, entregas y evaluaciones.
- Los drawers editables advierten antes de perder cambios.
- Marcar una clase ya completada como pendiente requiere confirmación explícita.
- El botón de clase se bloquea mientras Supabase confirma la escritura para impedir dobles acciones.
- Errores de formulario llevan el foco al campo que necesita corrección.
- Touch targets principales revisados para móvil.

### Autenticación y seguridad

- El desarrollo utiliza únicamente Auth real de Supabase para iniciar sesión.
- Eliminado el acceso administrativo local/de contingencia embebido en frontend.
- Eliminada la restauración automática de sesiones locales heredadas.
- El campo de acceso exige email y usa `type=email`.
- El selector Alumna/Admin depende exclusivamente de los roles devueltos por Supabase.
- Sin `service_role` en frontend.
- La clave presente en cliente es únicamente publishable.

### Móvil

- Cabecera móvil simplificada.
- `Cerrar sesión` pasa a Mi perfil en móvil.
- Toasts colocados por encima de la navegación inferior.
- Drawer, safe-area y touch targets revisados.
- Guardar perfil permanece accesible en formularios largos sin tapar la navegación.

## QA estático del asset actual

Comprobado durante las iteraciones 34–42:

- documento termina en `</html>`: PASS
- sin HUD Netlify embebido: PASS
- botones apertura/cierre equilibrados: PASS
- forms apertura/cierre equilibrados: PASS
- un único bloque de estilos: PASS
- template literals con backticks pares: PASS
- sin `history.back()` ciego: PASS
- navegación contextual al Programa: PASS
- restauración del contexto del Programa: PASS
- continuación inteligente de módulo: PASS
- protección de cambios sin guardar del perfil: PASS
- protección de drawers editables: PASS
- loading en clase/borrador/entrega/evaluación/perfil: PASS
- reduced motion: PASS
- perfil accesible en escritorio y móvil: PASS
- acceso únicamente mediante Auth real en desarrollo: PASS
- sin credenciales administrativas embebidas en el asset de desarrollo: PASS
- sin `service_role` en frontend: PASS
- sin campos de documento de identidad: PASS
- verificador público mínimo: PASS

## Supabase Advisors

### Seguridad

El advisor de Supabase mantiene un aviso de configuración de Auth:

- Leaked Password Protection: desactivado.

No se ha cambiado automáticamente porque es una configuración de Auth del proyecto, no una migración de datos.

### Rendimiento

Hay avisos informativos de índices aún no utilizados y varias políticas RLS permisivas superpuestas. No se han eliminado ni fusionado automáticamente porque requieren una revisión específica de consultas y permisos para no degradar la seguridad.

## Pendiente antes de producción

1. Cerrar los datos reales de protección de datos: responsable y email de privacidad.
2. Ejecutar QA en navegador sobre una URL desplegada de esta versión.
3. Probar 320/360/390/412 px, tablet y escritorio.
4. Login real, recarga, Alumna/Admin, perfil, entrega, evaluación y certificado.
5. Revisar la configuración `Leaked Password Protection` de Supabase Auth.
6. Solo después actualizar producción y `main`.
