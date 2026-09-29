# Estado de desarrollo

Última actualización: 2026-09-29

## Producción

- Hosting: Netlify.
- Sitio: `https://fancy-cranachan-c98e89.netlify.app/`.
- Deploy actual: `6aa2b472eea4967d3570df63`.
- Publicado: 2026-09-10.
- Origen del deploy: manual / `drop`; no está enlazado a un commit.
- Producción no se ha sustituido durante las mejoras v81–v86.
- Netlify tiene 0 variables de entorno configuradas; no se ha detectado una `service_role` ni secreto backend alojado allí.
- Incidencia conocida del deploy actual: `/campus-logo.webp` devuelve 404. La candidata v85+ elimina esta dependencia y usa assets oficiales ZAVRA versionados.

## Desarrollo actual

Supabase mantiene el alias operativo `development-current-index.html`, y GitHub contiene la fuente completa editable y publicable en:

`frontend/development-current/`

Estado actual:

- versión: **86**
- SHA-256 HTML: `61d55f06c7ee1e15c81cb7149314333cd4412be033e1f3eaee88d48960244715`
- snapshot Supabase: `development-14zg-visual-polish-index.html`
- rama GitHub: `develop`
- `develop`: **141 commits por delante de `main` y 0 por detrás** en la comprobación del 2026-09-29.
- PR de preproducción: #1, borrador y mergeable.
- `netlify.toml` publica `frontend/development-current`.
- `_headers` y `_redirects` viven dentro del directorio publicable.

### Evolución reciente

- v53: identidad y progreso por UUID.
- v54: caché local por cuenta y purga en logout.
- v55–57: invitaciones seguras y formato 24 hex.
- v58–59: semántica de botones y accesibilidad.
- v60–68: escape y saneado progresivo de identidad, recursos, Admin, currículo y drawer.
- v69: recuperación por email aislada del preview.
- v70: logout con estado explícito de revocación remota.
- v71: recovery inválido/caducado falla cerrado y sanea credenciales de URL.
- v72: minimización de PII local.
- v81: baseline de control operativo.
- v82: identidad de perfil sincronizada con certificación y render de lecciones endurecido.
- v83: resiliencia de layout para textos largos, tarjetas, botones, etiquetas y recursos.
- v84: composición del perfil móvil adaptada a nombres y emails largos.
- v85: migración de `campus-logo.webp` a los tres assets oficiales ZAVRA, versionados y verificados por SHA.
- v86: corrección del `\\n` literal visible y pulido de estados de certificación en móvil tras revisión de capturas reales.

## Identidad visual y assets

El paquete de desarrollo usa tres binarios maestros procedentes del repositorio interno de marca:

- `zavra-logo-black.png` — SHA-256 `a720dd56c8d5c0e226a239be35a7c4c4ef810f6c1062a6dd7da55e1ecc1f4f1c`
- `zavra-logo-white.png` — SHA-256 `fc16b864bec32a2416d917b75de39091f2fefa4255415524459052db7c21dc18`
- `zavra-logo-black-tagline.png` — SHA-256 `5566affb278928c54d7799919c666d67a8d1eb23edd5e550e56f916745540a43`

Uso:
- carga sobre fondo oscuro: logo blanco;
- acceso sobre tarjeta clara: logo negro con tagline;
- topbar clara: logo negro compacto.

El guard comprueba existencia y hash de los tres archivos.

## Funcionalidad cerrada

### Navegación y UX

- Navegación determinista; sin dependencia de `history.back()`.
- Restauración de posición al volver desde un módulo.
- Continuación por primera clase pendiente.
- CTAs contextuales según progreso, entrega y feedback.
- Mi perfil integrado en navegación de escritorio y avatar compacto en móvil.
- Protección de cambios sin guardar en perfil y drawers.
- Microtransiciones cortas y `prefers-reduced-motion`.
- Layout tolerante a nombres, etiquetas y contenidos largos.
- Recursos de lección apilados en móvil cuando el ancho no permite texto + CTA en línea.
- Tablas con scroll horizontal contenido en su wrapper.
- Ficha de alumna móvil revisada con identidad extensa ficticia para detectar encajonados.

### Perfil y certificación

- Nombre, primer apellido y segundo apellido opcional.
- Teléfono opcional y privado; email Auth de solo lectura.
- Foto de perfil opcional.
- Sin DNI/NIE/pasaporte.
- Confirmación explícita del nombre para certificado.
- Encabezado de Mi perfil y vista previa del certificado comparten identidad compuesta.
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
- Assets/chunks/manifests históricos permanecen protegidos por las políticas existentes.
- Funciones/rutas legacy privilegiadas se mantienen neutralizadas según migraciones versionadas.
- Render dinámico de lecciones v82 escapa resumen, conceptos, teoría, práctica, resultado, objetivos, pasos, errores, defensa oral y checklist.
- El frontend usa clave Supabase publicable; CI falla si aparecen `service_role` o prefijo `sb_secret_`.
- Netlify: 0 variables de entorno configuradas en la revisión del 2026-09-29.

### Supabase Advisors

Seguridad:
- `Leaked Password Protection` sigue desactivado.
- `brand_asset_repository` tiene RLS activado y 0 políticas; permanece como repositorio interno no expuesto.

Rendimiento:
- Hay índices aún no usados y políticas permisivas superpuestas.
- No se eliminan/fusionan sin QA de equivalencia por rol.

## QA automático actual

### Frontend guard

Workflow: `.github/workflows/frontend-guard.yml`.

Comprueba, entre otras cosas:

- parseo de todos los scripts inline;
- marcador de versión;
- botones con `type` explícito;
- ausencia de URLs `javascript:`;
- ausencia de credenciales backend;
- sincronización del nombre de perfil;
- escape de contenido de lecciones;
- reglas de resiliencia v83/v84/v86;
- existencia de assets locales referenciados;
- hashes de logos ZAVRA;
- presencia de `_headers` y `_redirects`.

Último resultado comprobado: **PASS** en commit `fe93ebe44b56a0f404563a7763801efaea99dd3e`.

### Visual smoke

Workflow: `.github/workflows/visual-smoke.yml`.

Ejecuta Chromium real con datos ficticios y sin credenciales reales.

Cobertura actual:
- 28 escenarios;
- 1440 × 1000 y 390 × 844;
- login;
- 8 vistas de alumna;
- 5 vistas Admin;
- nombres/emails deliberadamente largos;
- reduced motion;
- detección de errores JavaScript;
- detección de overflow horizontal;
- detección de imágenes visibles rotas.

Último resultado comprobado: **PASS**.
En todos los escenarios:
- `scrollWidth == viewport width`;
- imágenes rotas visibles: 0;
- errores de página: 0.

Matriz específica: `docs/QA_VISUAL_V86.md`.

## Publicación y trazabilidad

Regla vigente:

1. fuente completa en GitHub;
2. commit recuperable;
3. hashes conocidos;
4. Frontend guard en verde;
5. Visual smoke en verde;
6. solo después, candidata a Netlify.

El conector Netlify disponible permite desplegar el sitio existente pero no ofrece una operación para vincular el site manual actual a un repositorio Git. No se fuerza un deploy opaco que vuelva a perder trazabilidad.

## Pendiente antes de producción

1. Spot-check adicional en tablet y dispositivo móvil real.
2. Login, F5, refresh y logout con cuentas reales; vistas Alumna/Admin y cuenta dual-role.
3. Segunda cuenta real: invitación → activación → primer login → aparición en Admin.
4. Clase/progreso → entrega → evaluación → feedback → desbloqueo con dos cuentas.
5. Cambio de cuenta en el mismo navegador para confirmar purga de caché.
6. Recuperación de contraseña real y redirect desde el origen final autorizado.
7. Responsable legal y email de privacidad definitivos.
8. Activar/revisar Leaked Password Protection en Supabase Auth.
9. Enlazar Netlify con GitHub o establecer publicación equivalente que conserve commit/hash.
10. Publicar la candidata validada y ejecutar smoke test contra el dominio final.
11. Solo después fusionar `develop` a `main`.
