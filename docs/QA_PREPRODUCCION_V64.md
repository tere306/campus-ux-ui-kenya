# QA preproducción · Frontend v64

Fecha: 2026-09-07

Asset actual: `development-current-index.html`

- versión: `64`
- SHA-256: `6acbca1ff4cdc0b9e5c513a497e77555c9c0117890598a1d551eac9981d66063`
- producción Netlify: **sin cambios**

## A. QA automático / estático

| Control | Estado |
|---|---|
| HTML termina en `</html>` | PASS |
| Botones apertura/cierre | PASS · 143/143 |
| Formularios apertura/cierre | PASS · 5/5 |
| Botones sin tipo explícito | PASS · 0 |
| Submits reales conservados | PASS · 5 |
| Controles de formulario auditados | PASS · 28 |
| Controles sin nombre accesible | PASS · 0 |
| Referencias ARIA a ids inexistentes | PASS · 0 |
| `history.back()` | PASS · ausente |
| `service_role` en frontend | PASS · ausente |
| Invitación legacy 12 hex | PASS · ausente |
| Recursos: href validado por `safeHttpHref` | PASS |
| Recursos: título/descripción escapados | PASS |
| Identidad Admin escapada antes de HTML dinámico | PASS |
| Identidad de alumnas escapada en vistas Admin | PASS |
| `head()` escapa eyebrow/título/subtítulo | PASS |
| Estado curricular embebido coincide con DB | PASS · `published` |
| Copy de login/admin provisional obsoleto | PASS · retirado |

El único `status:'draft'` restante corresponde al estado funcional de un borrador de entrega, no al estado del currículo.

## B. Backend y seguridad comprobados

| Control | Estado |
|---|---|
| Todas las tablas base `public` con RLS | PASS |
| Identidad autenticada sin permisos ve datos académicos ajenos | PASS · 0 |
| `anon` con privilegios de tabla | PASS · 0 |
| `anon` con escritura/secuencias/MAINTAIN | PASS · 0 |
| `academy_backend_meta` anónimo | PASS · 5 columnas mínimas |
| Assets/chunks/manifests legibles por anon | PASS · no |
| Bucket histórico `pioc-web` | PASS · privado |
| Funciones trigger privadas ejecutables directamente | PASS · 0 |
| SECURITY DEFINER sin `search_path` explícito | PASS · 0 |
| Verificador público inválido | PASS · `valid:false/status:not_found` |
| Rutas legacy de certificado ejecutables por usuarios | PASS · no |
| Certificados legacy existentes al retirarlas | PASS · 0 |
| `publish-frontend-release` privilegiado operativo | PASS · retirado a 410 |
| Security Advisor | WARN único · Leaked Password Protection |

## C. Onboarding

Backend ya validado:

- [x] código 24 hex / 96 bits;
- [x] caducidad y bloqueo temporal;
- [x] contraseña 12–256 / 3 clases;
- [x] matrícula ligada al hash validado;
- [x] cleanup de cuenta huérfana;
- [x] allowlist legacy retirada;
- [x] creación de invitación Admin en transacción: PASS;
- [x] rollback: 0 filas QA persistentes.

Pendiente en navegador real:

- [ ] crear invitación de segunda cuenta controlada;
- [ ] abrir enlace sobre release nueva;
- [ ] activar cuenta;
- [ ] primer login;
- [ ] comprobar perfil + rol + matrícula;
- [ ] comprobar aparición única en Admin por UUID.

## D. Alumna · QA manual pendiente

- [ ] Login real.
- [ ] F5/recarga conserva o renueva sesión sin errores.
- [ ] Inicio sin flash de datos de otra cuenta.
- [ ] Tarjeta inferior abre Mi perfil.
- [ ] Guardar nombre/apellidos/teléfono.
- [ ] Cambio de nombre invalida confirmación del certificado.
- [ ] Confirmar nombre vuelve a dejar la ficha lista.
- [ ] Navegación Módulo → Programa restaura contexto/scroll.
- [ ] Completar/desmarcar clase sincroniza correctamente.
- [ ] Borrador → envío → espera de evaluación.
- [ ] Feedback/evaluación visible tras publicación.
- [ ] Logout no deja datos personales/progreso visibles.
- [ ] Otra cuenta no hereda caché local.

## E. Admin · QA manual pendiente

- [ ] Vista Admin solo con rol real.
- [ ] Listado de alumnas sin duplicados.
- [ ] Ficha individual y estado de certificación correcto.
- [ ] Crear/regenerar/cancelar invitación.
- [ ] Evaluación valida rúbrica y feedback.
- [ ] Protección contra doble publicación.
- [ ] Desbloqueo de módulo procede del backend.
- [ ] Finalización/certificado solo cuando backend lo permita.

## F. Responsive y accesibilidad manual

Anchos mínimos a revisar: 320, 360, 390, 412 px; tablet vertical/horizontal; escritorio 1280+.

Comprobar cabecera, navegación, drawers, teclado virtual, safe-area, targets táctiles ≥44 px, formularios largos, toasts y scroll horizontal.

Accesibilidad manual:

- [ ] teclado únicamente;
- [ ] foco visible;
- [ ] trap/restauración de foco en dialogs/drawers;
- [ ] Escape;
- [ ] errores llevan foco al campo;
- [ ] VoiceOver/NVDA básico;
- [ ] reduced motion.

## G. Recuperación y legal

- [ ] envío real de email de recuperación;
- [ ] redirect autorizado al dominio final;
- [ ] cambio de contraseña y nuevo login;
- [ ] responsable legal real;
- [ ] email de privacidad real;
- [ ] aviso completo antes de alumnado real;
- [ ] activar/revisar Leaked Password Protection.

## H. Release

- [ ] confirmar candidate hash final;
- [ ] sustituir Netlify únicamente tras QA;
- [ ] smoke test público;
- [ ] verificar que el acceso legacy ya no existe en producción;
- [ ] comprobar login, verificador, invitación y recuperación en URL final;
- [ ] fusionar `develop` → `main` solo después del smoke test.

## Veredicto

**READY FOR BROWSER QA — NOT READY FOR PRODUCTION**

La parte automática/estructural está prácticamente cerrada. El riesgo restante se concentra en integración real de navegador, dos cuentas, correo/redirect y cierre legal.
