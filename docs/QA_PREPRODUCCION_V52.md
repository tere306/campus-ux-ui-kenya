# QA de preproducción · v52

Este checklist debe ejecutarse sobre el preview de desarrollo antes de sustituir Netlify producción.

## 1. Acceso y sesión

- [ ] Login real por email y contraseña.
- [ ] Error de credenciales comprensible.
- [ ] Recuperación de contraseña.
- [ ] Recarga con sesión válida.
- [ ] Cierre de sesión.
- [ ] Cuenta solo Alumna no ve Admin.
- [ ] Cuenta solo Admin no ve navegación académica de alumna.
- [ ] Cuenta Alumna + Admin puede alternar vistas.
- [ ] No existe ningún acceso local/legacy.

## 2. Invitación y activación de alumna

### Desde Admin

- [ ] Admin → Alumnas muestra `Gestionar invitaciones`.
- [ ] El drawer carga las invitaciones existentes.
- [ ] Crear invitación exige nombre y email válidos.
- [ ] Se genera código temporal de 24 caracteres.
- [ ] El código tiene fecha de caducidad.
- [ ] `Copiar enlace` copia un enlace con fragmento `#invite=...`.
- [ ] Regenerar código invalida el anterior.
- [ ] Cancelar invitación invalida el código.
- [ ] Una invitación aceptada no puede cancelarse desde este flujo.

### Desde Alumna

- [ ] Login muestra `Tengo un código de invitación`.
- [ ] El enlace de invitación abre directamente el formulario de activación.
- [ ] Email y código llegan precargados cuando vienen en fragmento.
- [ ] El fragmento con email/código desaparece de la URL al abrir el formulario.
- [ ] Código inválido muestra error sin crear usuario.
- [ ] Contraseña <12 caracteres se rechaza.
- [ ] Contraseña que no cumple 3 tipos de caracteres se rechaza.
- [ ] Contraseñas distintas se rechazan.
- [ ] Código correcto activa la cuenta.
- [ ] Después de activar, el login queda precargado con el email.
- [ ] La alumna puede iniciar sesión con la contraseña recién creada.
- [ ] La nueva alumna aparece en Admin sin modificar frontend.
- [ ] La matrícula y rol `student` se crean correctamente.
- [ ] El Módulo 1 queda disponible por el backend.

## 3. Identidad dinámica

- [ ] La alumna autenticada se identifica por `user_id`, no por nombre.
- [ ] Admin lista matrículas reales sin duplicados.
- [ ] Una nueva matrícula aparece sin modificar el bundle.
- [ ] La ficha abierta por Admin corresponde al UUID correcto.
- [ ] Entregas y evaluaciones corresponden a la persona correcta.
- [ ] Dos alumnas con nombres similares no se mezclan.

## 4. Navegación

- [ ] Inicio → siguiente acción correcta.
- [ ] Programa → módulo.
- [ ] Módulo en progreso abre la primera clase pendiente.
- [ ] `← Volver al programa` vuelve al Programa.
- [ ] Se restaura la posición anterior del Programa.
- [ ] Clase anterior / siguiente clase son coherentes.
- [ ] Entrega → volver/cerrar sin perder cambios accidentalmente.
- [ ] Admin mantiene contexto alumna/evaluación.

## 5. Perfil y datos de certificación

- [ ] Tarjeta inferior izquierda abre Mi perfil.
- [ ] Nombre mostrado se actualiza con nombre/apellidos guardados.
- [ ] Segundo apellido opcional.
- [ ] Teléfono opcional.
- [ ] Email de cuenta en solo lectura.
- [ ] No existen campos de documento de identidad.
- [ ] Guardar muestra loading/éxito/error.
- [ ] Cambios sin guardar generan aviso al salir.
- [ ] Confirmar nombre de certificado funciona.
- [ ] Editar nombre invalida confirmación anterior.
- [ ] Ficha no confirmada impide emisión del certificado.

## 6. Progreso

- [ ] Marcar clase completada persiste tras F5.
- [ ] Doble click no duplica la operación.
- [ ] Marcar una completada como pendiente pide confirmación.
- [ ] Conflicto de otra sesión no sobrescribe datos silenciosamente.
- [ ] El siguiente módulo solo se desbloquea según regla académica.

## 7. Entregas y evaluaciones

- [ ] Guardar borrador persiste.
- [ ] Enviar crea intento remoto.
- [ ] Entrega enviada queda bloqueada durante evaluación.
- [ ] Admin publica rúbrica y feedback.
- [ ] Alumna ve feedback correcto.
- [ ] Suspenso abre iteración sin destruir intento anterior.
- [ ] Aprobado desbloquea siguiente módulo.
- [ ] Alumna no puede evaluarse a sí misma.
- [ ] Alumna A no puede leer/modificar entregas de Alumna B.

## 8. Certificación

- [ ] No se puede emitir sin ficha confirmada.
- [ ] Certificado usa nombre confirmado.
- [ ] Certificado no contiene email ni teléfono.
- [ ] Certificado conserva snapshot histórico.
- [ ] Editar el nombre después de emitir no muta el certificado anterior.
- [ ] Verificador público muestra únicamente nombre, programa, fecha, estado y código.
- [ ] Código inválido no filtra información.
- [ ] No existe búsqueda pública por nombre, email o UUID.

## 9. Responsive

Probar:

- [ ] 320×568
- [ ] 360×800
- [ ] 390×844
- [ ] 412×915
- [ ] tablet
- [ ] escritorio

En cada tamaño:

- [ ] sin overflow horizontal accidental;
- [ ] botones accesibles;
- [ ] navegación inferior no tapa contenido;
- [ ] toast no tapa navegación;
- [ ] drawer usable;
- [ ] formulario de activación usable;
- [ ] gestor de invitaciones usable;
- [ ] teclado móvil no tapa el CTA principal;
- [ ] perfil y formularios legibles.

## 10. Seguridad

- [ ] No existen credenciales administrativas embebidas.
- [ ] No existe `service_role` en frontend.
- [ ] `pioc-publish-web` responde como desactivado.
- [ ] `pioc-tere-access` responde como desactivado.
- [ ] Preview requiere su clave y no está indexado.
- [ ] Preview no puede cargarse en iframe.
- [ ] RLS mantiene aislamiento entre estudiantes.
- [ ] Admin obtiene permisos por backend, no por UI.
- [ ] Invitaciones Admin requieren rol Admin del programa.
- [ ] Endpoint público de activación no devuelve `user_id`.
- [ ] Tras 5 códigos incorrectos se aplica bloqueo temporal.
- [ ] Una cuenta Auth sin invitación/matrícula no obtiene acceso al campus.

## QA técnico ya ejecutado

- [x] v52 termina en `</html>`.
- [x] botones equilibrados `143/143`.
- [x] forms equilibrados `5/5`.
- [x] template literals con backticks pares.
- [x] sin `service_role` en frontend.
- [x] sin login Admin local.
- [x] formulario de activación presente.
- [x] RPC Admin de invitaciones presentes.
- [x] lectura Admin de invitaciones desde backend.
- [x] creación temporal de invitación QA.
- [x] código QA de 24 caracteres.
- [x] cancelación de invitación QA.
- [x] limpieza del dato QA.

## Bloqueos conocidos

- Falta configurar responsable legal y email de privacidad antes de beta real.
- `Leaked Password Protection` permanece pendiente de activar desde la configuración de Supabase Auth.
- Falta QA real en navegador de la cadena Admin → invitación → activación → primer login.

## Regla de release

No actualizar `main` ni Netlify producción mientras exista un fallo crítico, un problema de aislamiento entre usuarios o un fallo en activación/login real.
