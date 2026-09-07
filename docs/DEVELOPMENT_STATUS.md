# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14
- Producción no se ha sustituido durante los cambios 14S/14T/14R/14U de esta sesión.

## Desarrollo actual

Supabase mantiene un alias estable al asset de trabajo más reciente:

`development-current-index.html`

Estado actual:

- versión de desarrollo: **52**
- SHA-256: `77db0d842b3a5506ffb5c6060383f9876dacf4a3f22f5de721a8c947cc289009`
- snapshots previos conservados:
  - `development-14u-before-invite-ui-index.html` · v50
  - `development-14u-activation-ui-index.html` · v51

Existe además una Edge Function de **preview de desarrollo** separada de producción. El preview sigue protegido por clave y usa `noindex`, `no-store`, `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`, `Permissions-Policy` restrictiva y una CSP específica para el campus.

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
- El snapshot del certificado usa el nombre confirmado y no incluye email/teléfono.
- Verificador público `verify_master_certificate_v2` reducido a nombre, programa, finalización, estado y código.
- El verificador legacy `verify_program_certificate` ya no es ejecutable por `anon` ni `authenticated`.
- Estado de ficha visible para Admin.
- Certificado emitido visible desde Mi perfil cuando exista.
- La información legal completa sigue pendiente de responsable/email reales.

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
- `pioc-publish-web`, antiguo publicador sin autenticación, está desactivado con HTTP 410.
- `pioc-tere-access`, antiguo acceso especial con email/clave embebidos, también se ha desactivado con HTTP 410 y ahora requiere JWT.
- El antiguo allowlist de bootstrap ya no bloquea el alta legítima de alumnas invitadas. Una cuenta sin invitación ni bootstrap no obtiene perfil/matrícula y por tanto no obtiene acceso al campus.

### Invitaciones de alumnas · 14U

Backend:

- `admin_create_student_invite_v2`
- `get_admin_student_invites_v2`
- `admin_generate_student_activation_code`
- `admin_cancel_student_invite_v2`

Todos los RPC de administración requieren sesión autenticada y rol Admin del programa.

- La RLS de `student_invites` está ahora acotada al rol Admin del programa, no a un rol global heredado.
- `get_admin_student_invites_v2`, `admin_generate_student_activation_code` y `admin_cancel_student_invite_v2` usan `SECURITY INVOKER` y se apoyan en RLS.
- `admin_create_student_invite_v2` conserva `SECURITY DEFINER` porque también verifica si ya existe una cuenta en Auth; antes de cualquier escritura comprueba el rol Admin del programa.
- Los códigos nuevos tienen 24 caracteres hexadecimales (96 bits de entropía).
- Caducidad por defecto: 7 días.
- Tras 5 códigos incorrectos se bloquea la activación durante 15 minutos.
- El endpoint público de activación acepta códigos antiguos de 12 caracteres y nuevos de 24 para compatibilidad.
- Contraseña de activación: mínimo 12 caracteres y al menos 3 tipos de caracteres.
- El endpoint no devuelve `user_id` ni usa respuestas innecesariamente detalladas para correos no válidos.
- CORS limitado a producción y al origen Supabase del preview.

Frontend v52:

- Login incluye `Tengo un código de invitación`.
- Formulario de activación con email, código, contraseña y confirmación.
- Los enlaces con fragmento `#invite=...` precargan email/código sin enviarlos al servidor y limpian el fragmento al abrir el formulario.
- Admin → Alumnas incorpora `Gestionar invitaciones`.
- Admin puede crear, regenerar, cancelar y copiar el enlace de activación.
- Una invitación aceptada pasa a matrícula real y el alumnado aparece por UUID, sin tocar el frontend.

### Móvil

- Cabecera móvil simplificada.
- `Cerrar sesión` pasa a Mi perfil en móvil.
- Toasts por encima de la navegación inferior.
- Drawer, safe-area y touch targets revisados.
- Guardar perfil permanece accesible en formularios largos sin tapar la navegación.

## QA técnico ejecutado

### Asset v52

- documento termina en `</html>`: PASS
- botones apertura/cierre equilibrados: PASS (`143/143`)
- forms apertura/cierre equilibrados: PASS (`5/5`)
- template literals con backticks pares: PASS
- formulario de activación presente: PASS
- endpoint de activación referenciado: PASS
- gestión Admin de invitaciones presente: PASS
- RPC crear/regenerar/cancelar/listar presentes: PASS
- sin `service_role` en frontend: PASS
- sin credencial Admin local: PASS

### Backend de invitaciones

Se ejecutó QA transaccional con invitaciones ficticias temporales antes y después del endurecimiento RLS:

- lectura Admin de invitaciones: PASS
- creación de invitación: PASS
- código de 24 caracteres: PASS
- cancelación: PASS
- política RLS por Admin del programa: PASS
- limpieza del dato de QA: PASS

No se modificó la invitación real pendiente durante estas pruebas.

### Certificación pública

- `verify_program_certificate` legacy: `anon=false`, `authenticated=false`.
- `verify_master_certificate_v2`: `anon=true` y es el único verificador público previsto.

## Supabase Advisors

### Seguridad

Avisos actuales:

- `Leaked Password Protection`: desactivado.
- `admin_create_student_invite_v2`: aviso por ser `SECURITY DEFINER` ejecutable por usuarios autenticados. Es intencionado y el propio RPC exige rol Admin del programa antes de consultar Auth o escribir la invitación. Los otros RPC de invitaciones ya se han pasado a `SECURITY INVOKER`.

### Rendimiento

Existen avisos informativos de índices aún no utilizados y varias políticas RLS permisivas superpuestas. No se han modificado automáticamente para evitar cambiar semántica de permisos sin QA específico.

## Pendiente antes de producción

1. Cerrar los datos reales de protección de datos: responsable y email de privacidad.
2. QA en navegador sobre el preview de desarrollo.
3. Probar 320/360/390/412 px, tablet y escritorio.
4. Login real, recarga, cuenta Alumna, Admin y Alumna+Admin.
5. Probar de extremo a extremo una invitación de QA desde Admin hasta activación y primer login.
6. Comprobar listado Admin sin duplicados tras alta de una segunda alumna.
7. Entrega, evaluación, aislamiento entre usuarios y certificado.
8. Revisar `Leaked Password Protection` en Supabase Auth.
9. Solo después actualizar producción y `main`.
