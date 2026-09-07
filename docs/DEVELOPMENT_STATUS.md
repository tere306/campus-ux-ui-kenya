# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14
- Producción no se ha sustituido durante los cambios 14S/14T/14R/14U/14V de esta sesión.

## Desarrollo actual

Supabase mantiene un alias estable al asset de trabajo más reciente:

`development-current-index.html`

Estado actual:

- versión de desarrollo: **53**
- SHA-256: `e46631cb09cb81a628a0fef1985bf2795ee7b3e065cf7a2aa64ac45c0b909686`
- snapshot previo conservado: `development-14v-before-dynamic-lesson-sync-index.html` · v52
- asset histórico actual: `development-14v-dynamic-lesson-sync-index.html`

Existe una Edge Function de preview separada de producción. El preview está protegido por clave, `noindex`, `no-store`, `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`, `Permissions-Policy` restrictiva y CSP específica.

## Cambios acumulados principales

### Navegación y UX

- `← Volver al programa` contextual y determinista.
- Restauración de posición al volver desde un módulo al Programa.
- Módulo en curso continúa por la primera clase pendiente.
- CTAs contextuales: empezar, continuar, revisar, preparar entrega, ver entrega o revisar feedback.
- Mi perfil integrado en la tarjeta inferior izquierda de escritorio y avatar compacto en móvil.
- Microtransiciones breves y funcionales; `prefers-reduced-motion` respetado.

### Ficha del alumno y certificación

- Ficha dentro de Mi perfil.
- Nombre + apellidos para certificado; segundo apellido opcional.
- Sin DNI/NIE/pasaporte.
- Teléfono opcional y privado.
- Confirmación explícita del nombre y anulación automática si cambia.
- Emisión bloqueada en backend si la ficha no está confirmada.
- Snapshot del certificado sin email/teléfono.
- Verificador público `verify_master_certificate_v2` limitado a nombre, programa, finalización, estado y código.
- Verificador legacy deshabilitado para `anon` y `authenticated`.

### Invitaciones de alumnas · 14U

- Alta gestionada desde Admin.
- Códigos de activación de 24 caracteres hexadecimales (96 bits).
- Caducidad por defecto 7 días.
- Bloqueo 15 minutos tras 5 intentos fallidos.
- Contraseña de activación: mínimo 12 caracteres y 3 tipos de caracteres.
- Admin puede crear, regenerar, cancelar y copiar enlace de activación.
- Una invitación aceptada crea matrícula real y el alumnado aparece por UUID.
- RLS de invitaciones acotada al rol Admin del programa.
- Endpoint público no devuelve `user_id` ni detalles innecesarios.

### Identidad dinámica y progreso · 14V

- Eliminado el último gate de sincronización que dependía del nombre `Tere`.
- La sincronización de clases usa `localStudentIdFromAuth()` y el `user_id` real de Supabase.
- Backups de progreso registran el UUID activo en vez de un identificador fijo.
- Reconciliación local/remota de clases aplica sobre la alumna autenticada.
- La comprobación de versión curricular se aplica a cualquier cuenta con rol Alumna, no a un nombre concreto.
- Importación de copias valida dinámicamente todas las entradas de `studentData`.
- Eliminados textos y lógica residuales específicos de `Tere`/`Kenya` del asset de desarrollo.

### Autenticación y seguridad

- Solo Supabase Auth real.
- Sin login Admin local/legacy.
- Sin restauración automática de sesiones heredadas.
- Selector Alumna/Admin únicamente desde roles de Supabase.
- Sin `service_role` en frontend.
- Directorio Admin desde matrículas reales.
- `pioc-publish-web` y accesos especiales legacy deshabilitados.
- Una cuenta sin invitación/matrícula/rol no obtiene acceso académico.

## QA técnico ejecutado

### Asset v53

- documento termina en `</html>`: PASS
- botones apertura/cierre: PASS (`143/143`)
- forms apertura/cierre: PASS (`5/5`)
- template literals con backticks pares: PASS
- sin `service_role`: PASS
- sin `sdata('tere')`: PASS
- sin identificador literal `'tere'`: PASS
- sin referencias funcionales a Kenya: PASS
- sincronización por `localStudentIdFromAuth()`: PASS
- gate curricular genérico para cualquier Alumna: PASS

### Seguridad / aislamiento

- identidad sin permisos: 0 perfiles visibles
- 0 matrículas visibles
- 0 accesos de módulos visibles
- 0 progreso visible
- 0 entregas/intentos/evaluaciones visibles
- 0 expedientes/certificados visibles
- verificador con código inválido: solo `valid:false / status:not_found`
- constructor de certificado: sin email/teléfono y exige nombre confirmado

## Supabase Advisors

Avisos actuales:

- `Leaked Password Protection`: desactivado; requiere configuración de Auth fuera de las acciones disponibles en este conector.
- `admin_create_student_invite_v2`: aviso por `SECURITY DEFINER`; es intencionado porque necesita comprobar Auth, y antes de consultar/escribir verifica rol Admin del programa.

No se han eliminado índices ni fusionado políticas RLS de rendimiento sin QA específico.

## Pendiente antes de producción

1. Responsable legal y email de privacidad reales.
2. QA visual en navegador sobre preview.
3. Responsive 320/360/390/412, tablet y escritorio.
4. Login, F5, logout, Alumna, Admin y Alumna+Admin.
5. Invitación real de QA de extremo a extremo y primer login de segunda alumna.
6. Confirmar que Admin lista segunda alumna sin duplicados y por UUID.
7. Entrega → evaluación → feedback → desbloqueo con dos cuentas reales.
8. Certificado y verificador público reales cuando exista un expediente finalizable.
9. Activar/revisar Leaked Password Protection en Supabase Auth.
10. Solo después actualizar producción y `main`.
