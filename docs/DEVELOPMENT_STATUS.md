# Estado de desarrollo

Última actualización: 2026-09-29

## Producción

- Hosting: Netlify.
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`.
- Deploy actual: `6aa2b472eea4967d3570df63`.
- Publicado: 2026-09-10.
- Origen del deploy: manual / drop; no está enlazado a un commit.
- Producción no se ha sustituido durante las mejoras v81–v83.
- Netlify no tiene variables de entorno configuradas actualmente; no se ha detectado una `service_role` ni secreto backend alojado allí.

## Desarrollo actual

Supabase mantiene el alias operativo `development-current-index.html`, y GitHub contiene ya la fuente completa editable en:

`frontend/development-current/index.html`

Estado actual:

- versión: **83**
- SHA-256: `150e5440c78613efc53dd01fdb4d37533a0337ef220f8943195310898b807292`
- snapshot: `development-14zd-layout-resilience-index.html`
- rama GitHub: `develop`
- `develop`: 121 commits por delante de `main`, 0 por detrás en la comprobación del 2026-09-29.
- PR de preproducción: #1, borrador y mergeable.
- `netlify.toml` preparado para publicar `frontend/development-current`.

### Evolución reciente

- v53: identidad y progreso por UUID.
- v54: caché local por cuenta y purga en logout.
- v55–57: enlaces de invitación seguros y formato 24 hex.
- v58–59: semántica de botones y accesibilidad de buscadores.
- v60–68: escape y saneado progresivo de identidad, recursos, Admin, currículo y drawer.
- v69: recuperación por email aislada del preview.
- v70: logout con estado explícito de revocación remota.
- v71: recovery inválido/caducado falla cerrado y sanea credenciales de URL.
- v72: minimización de PII local.
- v81: baseline de control operativo y ajuste de preproducción.
- v82: sincronización del nombre visible del perfil con certificación y escape reforzado de contenido de lecciones.
- v83: resiliencia de layout para textos largos, tarjetas, botones, etiquetas y recursos; marcador interno de versión corregido.

## Funcionalidad cerrada

### Navegación y UX

- Navegación determinista; sin dependencia de `history.back()`.
- Restauración de posición al volver desde un módulo.
- Continuación por primera clase pendiente.
- CTAs contextuales según progreso, entrega y feedback.
- Mi perfil integrado en navegación de escritorio y avatar compacto en móvil.
- Protección de cambios sin guardar en perfil y drawers.
- Microtransiciones cortas y `prefers-reduced-motion`.
- Layout v83 tolerante a nombres, etiquetas y contenidos largos.
- Recursos de lección apilados en móvil cuando el ancho no permite mantener texto y CTA en línea.
- Tablas conservan scroll horizontal contenido en su wrapper.

### Perfil y certificación

- Nombre, primer apellido y segundo apellido opcional.
- Teléfono opcional y privado; email Auth de solo lectura.
- Foto de perfil opcional.
- Sin DNI/NIE/pasaporte.
- Confirmación explícita del nombre para certificado.
- El encabezado de Mi perfil y la vista previa del certificado usan la misma identidad compuesta.
- Emisión v2 bloqueada en backend sin ficha confirmada.
- Email y teléfono fuera del certificado y del verificador público.
- Verificador público v2 limitado a datos estrictamente necesarios.

### Invitaciones y onboarding

- Alta administrada por invitación.
- Código 24 hex / 96 bits, caducidad por defecto 7 días.
- Bloqueo tras intentos fallidos según política existente.
- Matrícula ligada a invitación validada y a identidad real.
- Cuenta Auth sin matrícula aceptada se elimina para evitar huérfanas.
- Allowlist/bootstrap legacy retirado.

### Identidad, progreso, caché y sesión

- Sin gates funcionales por nombres concretos.
- Sincronización mediante `user_id`.
- Backups de progreso ligados al UUID activo.
- Sesión Auth en `sessionStorage`.
- Refresh serializado.
- Caché académica asociada a la cuenta activa y purga al cambiar de cuenta o cerrar sesión.
- Recovery inválido elimina sesión temporal y limpia credenciales de URL.
- Email Auth no se duplica innecesariamente en estado local persistente.

## Seguridad e infraestructura

- Proyecto Supabase: `pioc-campus`.
- Todas las tablas públicas observadas tienen RLS habilitado.
- Assets/chunks/manifests históricos del frontend permanecen protegidos según las políticas existentes.
- Funciones y rutas legacy privilegiadas se mantienen neutralizadas según las migraciones versionadas.
- Render dinámico de lecciones v82 escapa resumen, conceptos, teoría, práctica, resultado esperado, objetivos, pasos, errores, defensa oral y checklist.
- Netlify: 0 variables de entorno configuradas en la revisión del 2026-09-29.

### Supabase Advisors

Seguridad:
- `Leaked Password Protection` sigue desactivado.
- `brand_asset_repository` tiene RLS activado y 0 políticas; al ser repositorio interno, permanece inaccesible a clientes hasta que se defina una necesidad real de exposición.

Rendimiento:
- Existen avisos de índices aún no usados y políticas permisivas superpuestas.
- No se eliminan índices ni se fusionan políticas sin pruebas de equivalencia de permisos por rol.

## QA técnico actual

GitHub Actions incluye `.github/workflows/frontend-guard.yml`.

El guard comprueba, entre otras cosas:

- parseo sintáctico de todos los scripts inline;
- marcador de versión;
- botones con `type` explícito;
- ausencia de URLs `javascript:`;
- sincronización del nombre de perfil;
- escape de contenido sensible de lecciones;
- ausencia del render directo anterior de `l.summary`;
- reglas de resiliencia visual v83.

Resultado actual del workflow **Frontend guard**: **PASS**.

Último run verde comprobado:
- commit: `d5f16d0e94767b74ca7ffe54af3cc2f353ae5a58`
- conclusión: `success`.

Matrices históricas relevantes:
- `docs/QA_PREPRODUCCION_V68.md`
- `docs/QA_AUTH_RECOVERY_V69.md`
- `docs/QA_SESSION_REVOCATION_V70.md`
- `docs/QA_RECOVERY_FAIL_CLOSED_V71.md`
- `docs/QA_DYNAMIC_HTML_XSS_V71.md`
- `docs/QA_PRIVACY_LOCAL_PII_V72.md`
- `docs/QA_PROFILE_AVATAR_AND_CONTEXTUAL_PANELS_V74.md`
- `docs/QA_PROGRESSIVE_PRACTICE_TRACK_V75.md`
- `docs/QA_STUDENT_WHITE_LABEL_V76.md`
- `docs/QA_NETLIFY_RELEASE_PACKAGE_V79.md`
- `docs/QA_LOGIN_CODE_RAIN_V80.md`

## Publicación y trazabilidad

Regla desde v82:

1. la fuente completa debe existir en GitHub;
2. debe tener commit recuperable;
3. el guard de frontend debe pasar;
4. el SHA de la versión debe quedar documentado;
5. solo después se considera candidata a Netlify.

El conector Netlify disponible actualmente permite desplegar un sitio existente, pero no ofrece una operación para enlazar el sitio manual actual con un repositorio Git. Por eso no se fuerza todavía un deploy de producción que volvería a perder trazabilidad.

## Pendiente antes de producción

1. QA visual responsive real: móvil, tablet y escritorio.
2. Login, F5, refresh y logout; vistas Alumna/Admin y cuenta dual-role.
3. Segunda cuenta real: invitación → activación → primer login → aparición en Admin.
4. Clase/progreso → entrega → evaluación → feedback → desbloqueo con dos cuentas.
5. Cambio de cuenta en el mismo navegador para confirmar purga de caché.
6. Recuperación de contraseña real y redirect desde el origen final autorizado.
7. Responsable legal y email de privacidad reales.
8. Activar/revisar Leaked Password Protection en Supabase Auth.
9. Enlazar Netlify con GitHub o establecer un mecanismo de publicación equivalente que conserve commit/hash.
10. Publicar la candidata validada y ejecutar smoke test.
11. Solo después fusionar `develop` a `main`.
