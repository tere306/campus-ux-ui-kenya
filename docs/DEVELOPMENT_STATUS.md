# Estado de desarrollo

Última actualización: 2026-09-07

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Deploy actual: `6a9e8ed5b2c90359c1b8081d`.
- Producción no se ha sustituido durante los cambios de preproducción.
- El bundle público actual conserva autenticación legacy/local embebida y no se considera baseline de seguridad.
- Hotfix exacto preparado y no desplegado: `production-security-hotfix-no-legacy-auth-index.html`, v16, SHA-256 `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`.

## Desarrollo actual

Alias estable en Supabase: `development-current-index.html`.

- versión: **64**
- SHA-256: `6acbca1ff4cdc0b9e5c513a497e77555c9c0117890598a1d551eac9981d66063`
- v53: identidad y progreso por UUID.
- v54: caché local por cuenta y purga en logout.
- v55–57: enlaces de invitación seguros y formato exclusivamente 24 hex.
- v58–59: semántica de botones y accesibilidad de buscadores.
- v60–63: escape/saneado de identidad, recursos y encabezados renderizados mediante `innerHTML`.
- v64: estado/copy operativo alineado con la realidad actual; currículo `4.14D-12x48-full` marcado como `published` igual que en Supabase.

El preview de desarrollo sigue separado de producción, protegido por clave rotada, `noindex`, `no-store`, anti-frame, `nosniff`, `no-referrer`, Permissions-Policy y CSP específica. La clave no se versiona.

## Funcionalidad cerrada

### Navegación y UX

- `← Volver al programa` determinista; sin `history.back()`.
- Restauración de posición al volver desde un módulo.
- Continuación por primera clase pendiente.
- CTAs contextuales según progreso/entrega/feedback.
- Mi perfil integrado en tarjeta inferior de escritorio y avatar compacto en móvil.
- Protección de cambios sin guardar en perfil y drawers.
- Microtransiciones cortas y `prefers-reduced-motion` respetado.

### Perfil y certificación

- Nombre, primer apellido y segundo apellido opcional.
- Teléfono opcional/privado; email de Auth read-only.
- Sin DNI/NIE/pasaporte.
- Confirmación explícita del nombre; cambiarlo invalida la confirmación.
- Emisión v2 bloqueada en backend sin ficha confirmada.
- Email/teléfono fuera del certificado y del verificador público.
- Verificador público v2 limitado a nombre, programa, finalización, estado y código.
- Verificador legacy y rutas legacy de emisión/revocación sin ejecución para `anon` ni `authenticated`.
- En el momento de retirar la emisión legacy había 0 certificados legacy.

### Invitaciones y onboarding

- Alta administrada por invitación.
- Código 24 hex / 96 bits, caducidad por defecto 7 días.
- Bloqueo 15 min tras 5 fallos.
- Contraseña 12–256 caracteres y mínimo 3 clases.
- La matrícula exige hash de invitación validado por la Edge Function en `app_metadata`; no basta coincidencia de email.
- Una cuenta Auth creada sin matrícula aceptada se elimina para evitar huérfanas.
- Allowlist/bootstrap legacy retirado.
- `admin_create_student_invite_v2` es `SECURITY INVOKER` + rol Admin + RLS.

### Identidad, progreso y caché

- Sin gates funcionales por nombres concretos.
- Sincronización mediante `user_id` real.
- Backups de progreso ligados al UUID activo.
- Sesión Auth en `sessionStorage`.
- Caché académica local asociada a la cuenta; cambio de cuenta o logout elimina la caché sensible anterior.
- Supabase es la autoridad académica.

## Seguridad e infraestructura

- Todas las tablas base de `public` tienen RLS habilitado.
- Una identidad autenticada sin matrícula/rol no ve perfiles, matrículas, accesos, progreso, entregas, evaluaciones, expedientes ni certificados.
- `anon`: 0 privilegios de tabla, 0 escritura, 0 secuencias, 0 `MAINTAIN`; solo 5 SELECT de columna mínimos en `academy_backend_meta`.
- Assets/chunks/manifests de frontend sin lectura anónima.
- Bucket histórico `pioc-web` privado.
- Funciones privadas usadas solo como triggers sin ejecución directa para `anon`/`authenticated`.
- Todas las funciones `SECURITY DEFINER` revisadas tienen `search_path` explícito.
- Única RPC pública para `anon`: `verify_master_certificate_v2(text)`.
- `publish-frontend-release` retirado a HTTP 410: ya no existe un publicador de frontend con `service_role`; la publicación objetivo es Netlify.
- Los demás publicadores/helpers legacy permanecen neutralizados con 410.

## QA técnico v64

- 143 botones de apertura / 143 cierres: PASS.
- 5 formularios de apertura / 5 cierres: PASS.
- 5 submits reales y 0 botones con tipo implícito: PASS.
- 28 controles auditados y 0 sin nombre accesible: PASS.
- referencias `aria-describedby` / `aria-labelledby`: 0 destinos inexistentes.
- enlaces externos con `target="_blank"`: `noopener` presente.
- sin `service_role` en frontend.
- sin `history.back()`.
- recursos externos pasan por `safeHttpHref`; título/descripción se escapan.
- identidad de perfil/alumnas escapada antes de entrar en HTML dinámico.
- `head()` escapa eyebrow/título/subtítulo.
- estado curricular embebido coincide con Supabase: `published`.
- el único `status:'draft'` restante corresponde al estado real de un borrador de entrega.

## Supabase Advisors

Seguridad: solo queda **Leaked Password Protection** desactivado; requiere configuración de Auth fuera de las acciones disponibles aquí.

Rendimiento: aparecen índices todavía no utilizados y políticas permisivas superpuestas. No se eliminan/fusionan de forma prematura porque el volumen real todavía es mínimo y una refactorización de RLS requiere QA de equivalencia.

## Estimación de preproducción

- backend/seguridad automática: ~97%
- frontend funcional/QA estático: ~95%
- avance global: ~85–88%

Lo restante es sobre todo validación real, no construcción.

## Pendiente antes de producción

1. QA visual responsive: 320/360/390/412, tablet y escritorio.
2. Login, F5, logout, vistas Alumna/Admin y cuenta con ambos roles.
3. Invitación real de segunda cuenta → activación → primer login → aparición en Admin.
4. Clase/progreso → entrega → evaluación → feedback → desbloqueo con dos cuentas.
5. Cambio de cuenta en el mismo navegador para confirmar purga de caché.
6. Recuperación de contraseña real y redirect del email.
7. Responsable legal y email de privacidad reales; completar aviso antes de alumnado real.
8. Activar/revisar Leaked Password Protection en Supabase Auth.
9. Sustituir el deploy público y ejecutar smoke test.
10. Solo después fusionar `develop` a `main`.
