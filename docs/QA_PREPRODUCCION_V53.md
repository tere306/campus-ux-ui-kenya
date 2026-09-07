# QA de preproducción · v53

Asset: `development-current-index.html`

SHA-256: `e46631cb09cb81a628a0fef1985bf2795ee7b3e065cf7a2aa64ac45c0b909686`

## PASS técnico automatizado

- [x] HTML termina correctamente.
- [x] 143 botones abiertos / 143 cerrados.
- [x] 5 formularios abiertos / 5 cerrados.
- [x] Template literals equilibrados.
- [x] Sin `service_role` en frontend.
- [x] Sin `history.back()` ciego.
- [x] Sin `sdata('tere')`.
- [x] Sin identificadores funcionales literales `Tere` / `Kenya`.
- [x] Progreso de clases identificado por UUID Auth.
- [x] RPC de progreso backend sin referencias a nombres concretos.
- [x] Scan de funciones `public/private`: sin lógica Tere/Kenya.
- [x] Verificador legacy no ejecutable por `anon`/`authenticated`.
- [x] Verificador v2 es la única superficie pública prevista.
- [x] `public.is_admin()` ya no es ejecutable por `anon`.
- [x] Identidad sin permisos no puede leer perfiles, matrículas, progreso, entregas, evaluaciones, expedientes o certificados.

## Invitaciones

- [x] Crear invitación (QA transaccional).
- [x] Código de activación de 24 hex / 96 bits.
- [x] Cancelar invitación.
- [x] RLS de invitaciones acotada al Admin del programa.
- [x] RPC de listar/generar/cancelar reducidos a SECURITY INVOKER.
- [x] Endpoint de activación con límite de intentos y contraseña fuerte.
- [ ] Activación real de extremo a extremo con segunda cuenta de QA.
- [ ] Primer login real de esa cuenta.
- [ ] Aparición automática en Admin sin modificar frontend.

## Navegación visual pendiente de navegador

- [ ] `← Volver al programa` visible y correcto.
- [ ] Restauración de scroll del Programa.
- [ ] Continuar módulo abre primera clase pendiente.
- [ ] Perfil desde tarjeta inferior izquierda.
- [ ] Avatar/perfil en móvil.
- [ ] CTAs de Inicio según estado.
- [ ] Drawers sin perder contexto.

## Perfil / certificado pendiente de navegador

- [ ] Guardar nombre/apellidos.
- [ ] Segundo apellido opcional.
- [ ] Teléfono opcional.
- [ ] Email solo lectura.
- [ ] Confirmación de nombre.
- [ ] Cambiar nombre invalida confirmación.
- [ ] Sin DNI/NIE/pasaporte.
- [ ] Emisión bloqueada sin ficha confirmada.
- [ ] Verificador público mínimo.

## Responsive pendiente

- [ ] 320×568
- [ ] 360×800
- [ ] 390×844
- [ ] 412×915
- [ ] tablet
- [ ] escritorio

Comprobar en cada tamaño: overflow, targets táctiles, navegación inferior, toast, drawer, teclado y CTA sticky.

## Bloqueos antes de producción

1. Datos reales de responsable de privacidad + email de privacidad.
2. QA visual real de la versión de desarrollo.
3. Segunda cuenta real de QA para validar aislamiento y onboarding completo.
4. Revisar/activar Leaked Password Protection en Supabase Auth.
5. No actualizar `main`/Netlify producción antes de cerrar los puntos anteriores.
