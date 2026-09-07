# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14
- Producción todavía no se ha sustituido durante los cambios 14S/14T/14R/14U/14V.
- Auditoría detectó que el bundle actualmente publicado conserva un acceso legacy/local embebido en frontend. No se documenta aquí el valor de esa credencial.
- Se ha preparado un hotfix basado exactamente en producción que elimina ese acceso legacy sin incorporar todavía el resto de cambios de desarrollo:
  - asset: `production-security-hotfix-no-legacy-auth-index.html`
  - versión: 16
  - SHA-256: `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`
- El hotfix no se ha desplegado todavía en Netlify porque el sitio actual es un deploy manual y el conector disponible no permite sustituir de forma segura el archivo del deploy sin una operación explícita de publicación.

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
- La comprobación de versión curricular se aplica a cualquier cuenta con rol Alumna.
- Importación de copias valida dinámicamente todas las entradas de `studentData`.
- Eliminados textos y lógica residuales específicos de alumnas concretas del asset de desarrollo.
- Scan de funciones `public/private`: no quedan referencias por nombre a alumnas concretas.

### Autenticación y seguridad

- Desarrollo: solo Supabase Auth real.
- Sin login Admin local/legacy en desarrollo.
- Sin restauración automática de sesiones heredadas.
- Selector Alumna/Admin únicamente desde roles de Supabase.
- Sin `service_role` en frontend.
- Directorio Admin desde matrículas reales.
- `pioc-publish-web` y accesos especiales legacy deshabilitados.
- `public.is_admin()` ya no es ejecutable por `anon`.
- Única función pública ejecutable por `anon`: `verify_master_certificate_v2(text)`.
- Una cuenta sin invitación/matrícula/rol no obtiene acceso académico.
- `academy_frontend_assets` y `academy_frontend_chunks` dejaron de ser públicamente legibles. El acceso anónimo fue revocado y la lectura autenticada queda limitada por RLS a Admin del programa.
- `academy_backend_meta` permanece públicamente legible porque el login lo usa para comprobar la salud/versión del backend y no contiene datos personales.

## QA técnico ejecutado

### Asset v53

- documento termina correctamente: PASS
- botones apertura/cierre: PASS (`143/143`)
- forms apertura/cierre: PASS (`5/5`)
- template literals con backticks pares: PASS
- sin `service_role`: PASS
- sin `sdata('tere')`: PASS
- sin identificadores funcionales fijos de alumnas: PASS
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
- funciones públicas `anon`: únicamente verificador v2
- frontend assets/chunks públicos: CERRADO

## Supabase Advisors

Avisos actuales:

- `Leaked Password Protection`: desactivado; requiere configuración de Auth fuera de las acciones disponibles en este conector.
- `admin_create_student_invite_v2`: aviso por `SECURITY DEFINER`; es intencionado porque necesita comprobar Auth, y antes de consultar/escribir verifica rol Admin del programa.

No se han eliminado índices ni fusionado políticas RLS de rendimiento sin QA específico.

## Pendiente antes de producción

1. Resolver el hotfix de autenticación legacy en el deploy público actual o sustituirlo por la release nueva validada.
2. Responsable legal y email de privacidad reales.
3. QA visual en navegador sobre preview.
4. Responsive 320/360/390/412, tablet y escritorio.
5. Login, F5, logout, Alumna, Admin y Alumna+Admin.
6. Invitación real de QA de extremo a extremo y primer login de segunda alumna.
7. Confirmar que Admin lista segunda alumna sin duplicados y por UUID.
8. Entrega → evaluación → feedback → desbloqueo con dos cuentas reales.
9. Certificado y verificador público reales cuando exista un expediente finalizable.
10. Activar/revisar Leaked Password Protection en Supabase Auth.
11. Solo después actualizar `main` con la release validada.
