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

- versión de desarrollo: **50**
- SHA-256: `e1f1b96ceb1a3e09e61fb4171f1c1aecac9bb6eea31086a438c52f1776a6d56e`
- asset histórico equivalente: `development-14r-dynamic-student-cleanup-index.html`

Existe además una Edge Function de **preview de desarrollo** separada de producción, protegida por una clave no publicada en el repositorio, con `noindex`, `no-store` y cabeceras de versión/hash. Sirve para QA visual sin sustituir Netlify producción.

## Cambios acumulados principales

### Navegación y UX

- `← Volver al programa` contextual y determinista.
- Restauración de posición al volver desde un módulo al Programa.
- El acceso a un módulo en curso continúa por la primera clase pendiente.
- Los CTAs distinguen `Empezar`, `Continuar`, `Revisar`, `Preparar entrega`, `Ver entrega` y `Revisar feedback` según el estado real.
- `Ruta cercana` de Inicio usa la acción académica correcta para cada módulo.
- Mi perfil integrado en la tarjeta inferior izquierda de escritorio.
- El nombre mostrado en perfil usa los datos personales confirmados cuando existen.
- Avatar de perfil compacto en móvil.
- Microtransiciones breves y funcionales; `prefers-reduced-motion` respetado.

### Ficha del alumno y certificación

- Ficha del alumno dentro de Mi perfil.
- Nombre + apellidos para certificado; segundo apellido opcional.
- No se solicitan documentos de identidad.
- Teléfono opcional y privado.
- Confirmación explícita del nombre de certificado.
- Invalidación de confirmación al modificar nombre/apellidos.
- Bloqueo backend de emisión si la ficha no está confirmada.
- Verificador público reducido a datos mínimos.
- Estado de ficha visible para Admin.
- Certificado emitido visible desde Mi perfil cuando exista.
- Copy de privacidad de desarrollo limpiado; la información legal completa sigue pendiente de responsable/email reales.

### Formularios y acciones

- Estados `Guardando`, `Enviando`, `Publicando` y `aria-busy`.
- Protección contra pérdida de cambios en perfil, entregas y evaluaciones.
- Drawers editables con confirmación antes de descartar cambios.
- Marcar una clase ya completada como pendiente requiere confirmación explícita.
- El botón de clase se bloquea mientras Supabase confirma la escritura.
- Errores de formulario llevan el foco al campo que necesita corrección.
- Touch targets principales revisados para móvil.

### Autenticación, identidad y seguridad

- Inicio de sesión únicamente mediante Supabase Auth real.
- Eliminado el acceso administrativo local/de contingencia del frontend de desarrollo.
- Eliminada la restauración automática de sesiones locales heredadas.
- Login por email con `type=email`.
- Selector Alumna/Admin únicamente desde roles de Supabase.
- Sin `service_role` en frontend.
- Eliminadas identidades y estados de activación hardcodeados del bundle.
- El alumnado ya no se asocia por coincidencia de nombre: la identidad de trabajo usa el UUID `user_id` de Supabase.
- El directorio Admin se hidrata desde las matrículas/resumen remoto.
- Eliminada la lista estática inicial de estudiantes.
- `pioc-publish-web`, antiguo publicador sin autenticación, se ha desactivado con HTTP 410; el flujo autenticado `publish-frontend-release` permanece disponible.

### Móvil

- Cabecera móvil simplificada.
- `Cerrar sesión` pasa a Mi perfil en móvil.
- Toasts por encima de la navegación inferior.
- Drawer, safe-area y touch targets revisados.
- Guardar perfil permanece accesible en formularios largos sin tapar la navegación.

## QA estático del asset actual

Comprobado en v50:

- documento termina en `</html>`: PASS
- botones apertura/cierre equilibrados: PASS
- forms apertura/cierre equilibrados: PASS
- template literals con backticks pares: PASS
- sin `history.back()` ciego: PASS
- navegación contextual al Programa: PASS
- continuación inteligente de módulo: PASS
- perfil inferior de escritorio: PASS
- login real únicamente: PASS
- sin sesión legacy: PASS
- sin login Admin local: PASS
- sin mapeo de estudiantes por nombre: PASS
- sin lista estática de estudiantes: PASS
- sin `service_role` en frontend: PASS

## Supabase Advisors

### Seguridad

Aviso de configuración pendiente:

- Leaked Password Protection: desactivado.

No se ha cambiado automáticamente porque el conector actual no expone la configuración de Auth necesaria.

### Rendimiento

Existen avisos informativos de índices aún no utilizados y varias políticas RLS permisivas superpuestas. No se han modificado automáticamente para evitar cambiar semántica de permisos sin QA específico.

## Pendiente antes de producción

1. Cerrar los datos reales de protección de datos: responsable y email de privacidad.
2. QA en navegador sobre el preview de desarrollo.
3. Probar 320/360/390/412 px, tablet y escritorio.
4. Login real, recarga, cuenta Alumna, Admin y Alumna+Admin.
5. Comprobar listado Admin sin duplicados tras el cambio a UUID.
6. Entrega, evaluación, aislamiento entre usuarios y certificado.
7. Revisar `Leaked Password Protection` en Supabase Auth.
8. Solo después actualizar producción y `main`.
