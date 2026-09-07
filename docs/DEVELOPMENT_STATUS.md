# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Release de frontend registrada como actual en Supabase: v14.
- Producción todavía no se ha sustituido durante los cambios 14S/14T/14R/14U/14V/14W.
- La auditoría detectó que el bundle publicado conserva un acceso legacy/local embebido. La credencial no se documenta ni se versiona.
- Hotfix preparado sobre la producción actual, sin incorporar el resto de cambios de desarrollo:
  - asset: `production-security-hotfix-no-legacy-auth-index.html`
  - versión: 16
  - SHA-256: `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`
- No se ha desplegado el hotfix: el sitio Netlify actual es un deploy manual (`drop`) y no existe todavía una operación segura de sustitución del archivo desde el conector disponible.

## Desarrollo actual

Alias estable en Supabase:

`development-current-index.html`

Estado actual:

- versión de desarrollo: **56**
- SHA-256: `8a068f7ecf9804dcca1190ba62eeeb55f2df03f2210cb01e542bf272997aebbb`
- v53: identidad dinámica y progreso por UUID.
- v54: caché local asociada a la cuenta y purga al cerrar sesión.
- v55: los enlaces de invitación dejan de copiar la URL del preview y apuntan exclusivamente al dominio de producción.
- v56: aviso explícito en preview para no enviar el enlace de activación antes de publicar la release.

Existe una Edge Function de preview separada de producción. El preview está protegido por clave, `noindex`, `no-store`, `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`, `Permissions-Policy` restrictiva y CSP específica.

## Cambios acumulados principales

### Navegación y UX

- `← Volver al programa` contextual y determinista.
- Restauración de posición al volver desde un módulo al Programa.
- Un módulo en curso continúa por la primera clase pendiente.
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
- En preview, el enlace compartible ya no incluye la clave del preview: siempre se genera contra producción y se muestra una advertencia mientras la release no esté publicada.

### Identidad dinámica y progreso · 14V

- Eliminado el último gate de sincronización dependiente de nombres concretos.
- Sincronización de clases mediante `localStudentIdFromAuth()` y `user_id` real de Supabase.
- Backups de progreso registran el UUID activo.
- Reconciliación local/remota sobre la alumna autenticada.
- Gate curricular genérico para cualquier cuenta Alumna.
- Importación de copias valida dinámicamente todas las entradas de `studentData`.
- Scan de funciones `public/private`: no quedan referencias por nombre a alumnas concretas.

### Privacidad de caché local · 14W

- La sesión Auth ya estaba en `sessionStorage`; se mantiene así.
- La caché académica local queda asociada al usuario autenticado mediante `LOCAL_CACHE_OWNER_KEY`.
- Si se detecta un propietario de caché distinto, se descartan las copias locales antes de hidratar la nueva cuenta.
- Al cerrar sesión se eliminan estado, recuperación y backups locales sensibles y no se vuelve a persistir el estado anterior.
- El backend remoto sigue siendo la autoridad académica.

### Autenticación y seguridad

- Desarrollo: solo Supabase Auth real.
- Sin login Admin local/legacy en desarrollo.
- Sin restauración automática de sesiones heredadas.
- Selector Alumna/Admin únicamente desde roles de Supabase.
- Sin `service_role` en frontend.
- Directorio Admin desde matrículas reales.
- `pioc-publish-web` y accesos especiales legacy deshabilitados.
- `public.is_admin()` no es ejecutable por `anon`.
- Única función `public` ejecutable por `anon`: `verify_master_certificate_v2(text)`.
- Una cuenta sin invitación/matrícula/rol no obtiene acceso académico.
- `academy_frontend_assets` y `academy_frontend_chunks`: sin lectura anónima; lectura autenticada limitada por RLS a Admin.
- `academy_backend_meta`: el login solo puede leer las columnas mínimas `product_id`, `schema_version`, `curriculum_version`, `status`, `updated_at`; `notes` ya no es legible por `anon` ni por el rol genérico `authenticated`.

## QA técnico ejecutado

### Asset v56

- documento termina correctamente: PASS
- botones apertura/cierre: PASS (`143/143`)
- forms apertura/cierre: PASS (`5/5`)
- template literals con backticks pares: PASS
- sin `service_role`: PASS
- sin identificadores funcionales fijos de alumnas: PASS
- sincronización por UUID: PASS
- caché local aislada por propietario: PASS
- cierre de sesión sin re-persistir la caché anterior: PASS
- enlaces de invitación sin copiar la URL/clave del preview: PASS

### Seguridad / aislamiento

- identidad sin permisos: 0 perfiles, matrículas, accesos, progreso, entregas, intentos, evaluaciones, expedientes y certificados visibles.
- verificador con código inválido: únicamente `valid:false / status:not_found`.
- constructor de certificado: sin email/teléfono y exige nombre confirmado.
- funciones públicas anónimas: únicamente verificador v2.
- frontend assets/chunks públicos: CERRADO.
- consulta pública mínima de `academy_backend_meta`: PASS tras reducir privilegios por columna.
- RPC académica autenticada comprobada tras el cambio de privilegios: PASS.

## Supabase Advisors

Seguridad pendiente:

- `Leaked Password Protection`: desactivado; requiere configuración de Auth fuera de las acciones disponibles en este conector.
- `admin_create_student_invite_v2`: único `SECURITY DEFINER` público ejecutable por `authenticated`; es intencionado porque consulta Auth y exige rol Admin del programa antes de consultar/escribir.

Rendimiento:

- Se añadió `student_learning_journal_program_id_idx` para cubrir la FK `student_learning_journal_program_id_fkey` detectada por el advisor.
- No se eliminan índices marcados como no usados: el volumen actual es todavía demasiado bajo para concluir que sobran.
- No se fusionan todavía políticas RLS permisivas duplicadas sin QA específico de semántica.

## Pendiente antes de producción

1. Resolver el hotfix de autenticación legacy del deploy público o sustituirlo directamente por la release nueva validada.
2. Responsable legal y email de privacidad reales.
3. QA visual en navegador sobre preview.
4. Responsive 320/360/390/412, tablet y escritorio.
5. Login, F5, logout, Alumna, Admin y Alumna+Admin.
6. Invitación real de QA de extremo a extremo y primer login de segunda alumna.
7. Confirmar que Admin lista segunda alumna sin duplicados y por UUID.
8. Entrega → evaluación → feedback → desbloqueo con dos cuentas reales.
9. Recuperación de contraseña una vez que el dominio de producción tenga la release nueva.
10. Certificado y verificador público reales cuando exista un expediente finalizable.
11. Activar/revisar Leaked Password Protection en Supabase Auth.
12. Solo después actualizar `main` con la release validada.
