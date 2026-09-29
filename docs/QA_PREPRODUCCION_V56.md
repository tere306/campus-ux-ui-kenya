# QA preproducción · Frontend v56

Fecha: 2026-09-07

Asset actual: `development-current-index.html`

- versión: `56`
- SHA-256: `8a068f7ecf9804dcca1190ba62eeeb55f2df03f2210cb01e542bf272997aebbb`
- producción Netlify: **sin cambios**

## A. Comprobaciones automáticas / estructurales

| Control | Estado |
|---|---|
| HTML termina correctamente en `</html>` | PASS |
| Apertura/cierre de botones | PASS · 143/143 |
| Apertura/cierre de formularios | PASS · 5/5 |
| Template literals / backticks equilibrados | PASS |
| `service_role` ausente del frontend | PASS |
| Login Admin local/legacy ausente de desarrollo | PASS |
| Identidad académica fija por nombre ausente | PASS |
| Progreso de clases por UUID de Auth | PASS |
| Gate curricular genérico para cualquier Alumna | PASS |
| `history.back()` ciego ausente | PASS |
| Caché local vinculada a cuenta | PASS |
| Logout purga caché sensible | PASS |
| Logout no vuelve a persistir estado anterior | PASS |
| Enlace de invitación no copia URL/clave del preview | PASS |
| Advertencia de no compartir enlace desde preview | PASS |

## B. Backend / permisos ya comprobados

| Control | Estado |
|---|---|
| Identidad autenticada sin permisos ve 0 perfiles ajenos | PASS |
| Sin permisos ve 0 matrículas/accesos/progreso | PASS |
| Sin permisos ve 0 entregas/intentos/evaluaciones | PASS |
| Sin permisos ve 0 expedientes/certificados | PASS |
| `academy_frontend_assets` no legible por anon | PASS |
| `academy_frontend_chunks` no legible por anon | PASS |
| Única RPC pública anónima prevista: verificador v2 | PASS |
| Verificador legacy bloqueado | PASS |
| `public.is_admin()` bloqueado para anon/PUBLIC | PASS |
| `academy_backend_meta` público solo en columnas mínimas | PASS |
| RPC académica autenticada sigue funcionando tras reducción de grants | PASS |
| FK `student_learning_journal.program_id` con índice dedicado | PASS |
| `pioc-campus` legacy retirado con HTTP 410 | PASS |

## C. Alumna · QA real en navegador pendiente

- [ ] Login con email/contraseña real.
- [ ] Recarga/F5 mantiene o recupera sesión correctamente.
- [ ] Inicio carga sin flashes de datos de otra cuenta.
- [ ] Tarjeta inferior izquierda abre **Mi perfil**.
- [ ] Nombre, apellidos y teléfono opcional se guardan.
- [ ] Cambiar nombre invalida confirmación previa del certificado.
- [ ] Confirmar nombre vuelve a marcar la ficha como lista.
- [ ] `← Volver al programa` vuelve al Programa y restaura scroll.
- [ ] Empezar/Continuar/Revisar llevan a la clase correcta.
- [ ] Completar y desmarcar clase respeta confirmación y sincronización.
- [ ] Entrega: borrador → envío → bloqueo mientras espera revisión.
- [ ] Feedback/evaluación aparece al alumno tras publicación.
- [ ] Logout vuelve al login y no deja datos personales/progreso visibles.
- [ ] Login posterior con otra cuenta no hereda caché académica.

## D. Admin · QA real pendiente

- [ ] Vista Admin disponible solo si Supabase devuelve rol Admin.
- [ ] Alumnas se listan desde matrículas reales, sin duplicados.
- [ ] Abrir ficha de alumna muestra estado de certificación correcto.
- [ ] Gestionar invitaciones carga sin errores.
- [ ] Crear invitación genera código/enlace y fecha de caducidad.
- [ ] Desde preview se muestra el aviso de no compartir antes de release.
- [ ] Regenerar código invalida el anterior.
- [ ] Cancelar invitación la saca de activas.
- [ ] Evaluar entrega valida rúbrica, feedback y evita doble publicación.
- [ ] Desbloqueo de módulo procede exclusivamente del backend.

## E. Invitación / segunda cuenta · E2E pendiente

Realizar con un correo de QA controlado y limpiar o conservar como cuenta de prueba según se decida.

1. Admin crea invitación.
2. Abrir enlace sobre la **release nueva ya publicada** (no sobre producción actual v14).
3. Activar con contraseña de 12+ caracteres / 3 clases.
4. Confirmar creación de perfil, rol Alumna y matrícula actual.
5. Primer login.
6. Confirmar que solo M1 está accesible inicialmente según regla académica.
7. Completar una clase y verificar persistencia tras F5.
8. Confirmar que Admin ve la nueva alumna por UUID y sin duplicados.
9. Cerrar sesión y alternar entre ambas cuentas para validar aislamiento local/remoto.

## F. Responsive / accesibilidad pendiente

Probar al menos:

- [ ] 320 px
- [ ] 360 px
- [ ] 390 px
- [ ] 412 px
- [ ] tablet vertical/horizontal
- [ ] escritorio 1280+

En cada tamaño revisar cabecera, navegación inferior/lateral, drawers, teclado virtual, safe-area, botones ≥44 px, formularios largos, toasts y ausencia de scroll horizontal accidental.

Accesibilidad manual:

- [ ] navegación solo teclado;
- [ ] foco visible;
- [ ] foco atrapado y restaurado en dialogs/drawers;
- [ ] Escape cierra cuando corresponde;
- [ ] errores llevan foco al campo;
- [ ] lectura básica con VoiceOver/NVDA;
- [ ] `prefers-reduced-motion` sin transiciones innecesarias.

## G. Release blockers

No publicar como release final hasta cerrar:

1. retiro efectivo del acceso legacy del Netlify público;
2. QA visual/browser;
3. E2E con segunda cuenta;
4. logout/cambio de cuenta y caché local;
5. recuperación de contraseña en el dominio final;
6. responsable legal + email de privacidad;
7. revisión/activación de Leaked Password Protection en Supabase Auth.

## Veredicto actual

**READY FOR BROWSER QA — NOT READY FOR PRODUCTION**

La estructura y los controles backend están suficientemente avanzados para iniciar QA real, pero todavía hay dependencias de navegador y de despliegue que no deben inferirse a partir de comprobaciones estáticas.
