# QA invitación y activación — 2026-09-08

## Alcance
Auditoría del flujo `student_invites` → `activate-student-invite` → `auth.users` → matrícula.

Producción Netlify no se ha modificado. `main` no se ha fusionado.

## Estado previo verificado
- Edge Function `activate-student-invite`: v5, `verify_jwt=false` por diseño, ya que el invitado aún no dispone de sesión.
- Body máximo: 4096 bytes.
- Código: 24 caracteres hexadecimales (96 bits).
- Contraseña: 12–256 caracteres, mínimo 3 clases.
- Bloqueo: 15 minutos tras 5 intentos fallidos.
- Código almacenado únicamente como SHA-256.
- Comparación del hash mediante comparación de longitud constante.
- `service_role` solo se obtiene desde runtime env de la Edge Function.

## Cadena de matrícula
`auth.users` tiene un trigger `academy_enroll_pending_invite` que llama a `private.on_auth_user_created_enroll_invite()`.

El trigger pasa `new.raw_app_meta_data ->> 'student_invite_hash'` a `private.enroll_pending_invite(...)`.

La función interna solo procesa invitaciones que:
- coinciden por email;
- están `pending` o `sent`;
- tienen exactamente el mismo hash de invitación;
- no están usadas;
- no han caducado;
- no están bloqueadas.

Después crea/actualiza perfil, matrícula y progreso, y marca la invitación como `accepted`, limpia el hash y marca `activation_used_at`.

Ambas funciones internas son `SECURITY DEFINER`, están en esquema `private`, usan `search_path=''` y no tienen `EXECUTE` para `anon` ni `authenticated`.

## Integridad observada
En la comprobación de esta pasada:
- 0 usuarios creados mediante invitación sin matrícula asociada;
- 0 invitaciones aceptadas sin `activation_used_at`;
- 0 invitaciones usadas con estado distinto de `accepted`;
- 0 códigos activos sin expiración;
- 0 invitaciones con >=5 intentos y sin lock registrado.

## Hallazgo: enumeración de estado
La v5 comprobaba `activation_locked_until` y expiración antes de demostrar que el código suministrado coincidía.

Consecuencia: con un email conocido y cualquier código de formato válido era posible distinguir algunos estados de invitación (`429` bloqueada / `410` caducada) frente a un email sin invitación. No otorgaba acceso, pero exponía metadatos de existencia/estado.

## Corrección aplicada
Edge Function actualizada a **v6**.

Nuevo orden:
1. localizar invitación candidata;
2. calcular y comparar el hash suministrado;
3. si el hash no coincide, responder de forma genérica;
4. solo si el hash coincide se revelan estados legítimos como bloqueo o caducidad;
5. si el registro de un intento fallido devuelve error, responder 500 en vez de fingir que el contador quedó persistido.

La v6 mantiene:
- CORS allowlist actual;
- 24-hex;
- política de contraseña;
- límite de body;
- cleanup de usuario Auth si la matrícula no queda aceptada;
- `verify_jwt=false` intencional para onboarding sin sesión.

## Deuda residual
El incremento de `activation_attempts` sigue siendo read-modify-write en la Edge Function. En concurrencia extrema dos peticiones simultáneas podrían competir y subcontar un intento. Con un secreto de 96 bits esto no crea una vía práctica de adivinación, pero antes de una escala alta conviene convertir el incremento/bloqueo en una operación SQL atómica.

No se introduce una migración improvisada en esta pasada: cualquier cambio de ese tipo debe versionarse y probarse con equivalencia del flujo real.

## Veredicto
El flujo de invitación queda más resistente a enumeración y mantiene la protección contra cuentas Auth huérfanas. Sigue pendiente el E2E con una segunda identidad real antes de producción.