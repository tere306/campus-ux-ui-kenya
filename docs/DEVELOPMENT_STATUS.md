# Estado de desarrollo

Última actualización: 2026-09-08

## Producción

- Hosting: Netlify
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`
- Deploy actual: `6a9e8ed5b2c90359c1b8081d`.
- Producción no se ha sustituido durante los cambios de preproducción.
- El bundle público actual conserva autenticación legacy/local embebida y no se considera baseline de seguridad.
- Hotfix exacto preparado y no desplegado: `production-security-hotfix-no-legacy-auth-index.html`, v16, SHA-256 `8d9e9f4be9ad60a53e640495e13daf798b2bd43484398b3b7991259afe925d04`.

## Desarrollo actual

Alias estable en Supabase: `development-current-index.html`.

- versión: **71**
- SHA-256: `f3b4aadee130d94222f0faa351e6d488f99d86bfee57bc876ce0e05b9c8fb004`
- v53: identidad y progreso por UUID.
- v54: caché local por cuenta y purga en logout.
- v55–57: enlaces de invitación seguros y formato exclusivamente 24 hex.
- v58–59: semántica de botones y accesibilidad de buscadores.
- v60–63: escape/saneado de identidad, recursos y encabezados renderizados mediante `innerHTML`.
- v64: estado/copy operativo alineado con Supabase.
- v65–68: ampliación de escape de contenido dinámico en Admin, currículo y drawer de alumna.
- v69: la recuperación por email no puede iniciarse desde preview para evitar callbacks accidentales a producción; el flujo real queda reservado al origen final.
- v70: logout con estado explícito de revocación remota; la limpieza local sigue siendo fail-safe y se avisa si Supabase no pudo confirmar la revocación.
- v71: recovery inválido/caducado falla cerrado: elimina la sesión temporal local y sanea `token_hash`, `type` y fragmento de la URL antes de exigir un enlace nuevo.

El preview de desarrollo sigue separado de producción y aplica `noindex`, `no-store`, anti-frame, `nosniff`, `no-referrer`, Permissions-Policy y CSP específica. La clave de preview no se versiona, pero actualmente permanece incrustada en el source desplegado de `campus-development-preview`; debe externalizarse a runtime secret y rotarse antes de producción.

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

### Invitaciones y onboarding

- Alta administrada por invitación.
- Código 24 hex / 96 bits, caducidad por defecto 7 días.
- Bloqueo 15 min tras 5 fallos.
- Contraseña 12–256 caracteres y mínimo 3 clases.
- La matrícula exige hash de invitación validado en `app_metadata`; no basta coincidencia de email.
- Una cuenta Auth creada sin matrícula aceptada se elimina para evitar huérfanas.
- Estados de invitación caducada/bloqueada no se revelan antes de demostrar un código correcto.
- El contador de intentos fallidos es atómico mediante `record_student_invite_failure_v2`; ejecutable solo por `service_role`.
- Allowlist/bootstrap legacy retirado.
- `admin_create_student_invite_v2` es `SECURITY INVOKER` + rol Admin + RLS.

### Identidad, progreso, caché y sesión

- Sin gates funcionales por nombres concretos.
- Sincronización mediante `user_id` real.
- Backups de progreso ligados al UUID activo.
- Sesión Auth en `sessionStorage`.
- Refresh serializado; un fallo de refresh elimina la sesión local y la marca expirada.
- Caché académica local asociada a la cuenta; cambio de cuenta o logout elimina la caché sensible anterior.
- Logout intenta revocación remota y siempre limpia sesión/caché local; v70 avisa si la revocación remota no pudo confirmarse.
- Recovery inválido/caducado elimina la sesión temporal local y limpia parámetros de credencial de la URL antes de pedir un enlace nuevo.
- Supabase es la autoridad académica.

## Seguridad e infraestructura

- Todas las tablas base de `public` tienen RLS habilitado.
- Una identidad autenticada sin matrícula/rol no ve perfiles, matrículas, accesos, progreso, entregas, evaluaciones, expedientes ni certificados.
- `anon`: 0 privilegios de tabla, 0 escritura, 0 secuencias, 0 `MAINTAIN`; solo 5 SELECT de columna mínimos en `academy_backend_meta`.
- Assets/chunks/manifests de frontend sin lectura anónima.
- Bucket histórico `pioc-web` privado.
- Funciones privadas de trigger sin ejecución directa para `anon`/`authenticated`.
- Todas las funciones `SECURITY DEFINER` revisadas tienen `search_path` explícito.
- Única RPC pública para `anon`: `verify_master_certificate_v2(text)`.
- `publish-frontend-release` y otros publicadores/helpers legacy permanecen neutralizados con HTTP 410.

## QA técnico actual

Matrices principales:
- `docs/QA_PREPRODUCCION_V68.md`
- `docs/QA_AUTH_RECOVERY_V69.md`
- `docs/QA_SESSION_REVOCATION_V70.md`
- `docs/QA_RECOVERY_FAIL_CLOSED_V71.md`
- `docs/QA_INVITE_ACTIVATION_2026-09-08.md`
- `docs/QA_INVITE_ATOMIC_LOCKOUT_2026-09-08.md`
- `docs/QA_RLS_PRIVILEGES_2026-09-08.md`

Estado v71:
- 143 botones de apertura / 143 cierres: PASS.
- 5 formularios de apertura / 5 cierres: PASS.
- sin `service_role` en frontend.
- sin `history.back()`.
- sesión Auth en `sessionStorage` y refresh serializado.
- recuperación v69 preservada.
- logout v70 conserva limpieza local y expone fallo de revocación remota.
- recovery inválido v71 elimina sesión temporal y sanea URL de credenciales.

## Supabase Advisors

Seguridad: solo queda **Leaked Password Protection** desactivado.

Rendimiento: aparecen índices todavía no utilizados y políticas permisivas superpuestas. No se eliminan/fusionan de forma prematura porque el volumen real todavía es mínimo y una refactorización de RLS requiere QA de equivalencia.

## Estimación de preproducción

- backend/seguridad automática: ~98%
- frontend funcional/QA estático: ~97–98%
- avance global: ~89–91%

Lo restante es sobre todo validación real y configuración externa, no construcción base.

## Pendiente antes de producción

1. QA visual responsive: 320/360/390/412, tablet y escritorio.
2. Login, F5, refresh, logout normal y logout con fallo de red; vistas Alumna/Admin y cuenta dual-role.
3. Invitación real de segunda cuenta → activación → primer login → aparición en Admin.
4. Clase/progreso → entrega → evaluación → feedback → desbloqueo con dos cuentas.
5. Cambio de cuenta en el mismo navegador para confirmar purga de caché.
6. Recuperación de contraseña real y redirect del email desde el origen final autorizado.
7. Responsable legal y email de privacidad reales; completar aviso antes de alumnado real.
8. Activar/revisar Leaked Password Protection en Supabase Auth.
9. Externalizar/rotar la clave de `campus-development-preview` y verificar acceso autorizado/no autorizado.
10. Sustituir el deploy público y ejecutar smoke test.
11. Solo después fusionar `develop` a `main`.
