# QA de preproducción · v50

Este checklist debe ejecutarse sobre el preview de desarrollo antes de sustituir Netlify producción.

## Acceso y sesión

- [ ] Login real por email y contraseña.
- [ ] Error de credenciales comprensible.
- [ ] Recuperación de contraseña.
- [ ] Recarga con sesión válida.
- [ ] Cierre de sesión.
- [ ] Cuenta solo Alumna no ve Admin.
- [ ] Cuenta solo Admin no ve navegación académica de alumna.
- [ ] Cuenta Alumna + Admin puede alternar vistas.

## Identidad dinámica

- [ ] La alumna autenticada se identifica por `user_id`, no por nombre.
- [ ] Admin lista matrículas reales sin duplicados.
- [ ] Una nueva matrícula puede aparecer sin modificar el frontend.
- [ ] La ficha abierta por Admin corresponde al UUID correcto.
- [ ] Entregas y evaluaciones corresponden a la persona correcta.

## Navegación

- [ ] Inicio → siguiente acción correcta.
- [ ] Programa → módulo.
- [ ] Módulo en progreso abre la primera clase pendiente.
- [ ] `← Volver al programa` vuelve al Programa.
- [ ] Se restaura la posición anterior del Programa.
- [ ] Clase anterior / siguiente clase son coherentes.
- [ ] Entrega → volver/cerrar sin perder cambios accidentalmente.
- [ ] Admin mantiene contexto alumno/evaluación.

## Perfil

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

## Progreso

- [ ] Marcar clase completada persiste tras F5.
- [ ] Doble click no duplica la operación.
- [ ] Marcar una completada como pendiente pide confirmación.
- [ ] Conflicto de otra sesión no sobrescribe datos silenciosamente.

## Entregas y evaluaciones

- [ ] Guardar borrador persiste.
- [ ] Enviar crea intento remoto.
- [ ] Entrega enviada queda bloqueada durante evaluación.
- [ ] Admin publica rúbrica y feedback.
- [ ] Alumna ve feedback correcto.
- [ ] Suspenso abre iteración sin destruir intento anterior.
- [ ] Aprobado desbloquea siguiente módulo.

## Certificación

- [ ] No se puede emitir sin ficha confirmada.
- [ ] Certificado usa nombre confirmado.
- [ ] Certificado no contiene email/teléfono.
- [ ] Verificador público muestra únicamente datos mínimos.
- [ ] Código inválido no filtra información.

## Responsive

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
- [ ] teclado móvil no tapa el CTA principal;
- [ ] perfil y formularios legibles.

## Seguridad

- [ ] No existe acceso local/legacy.
- [ ] No existen credenciales administrativas embebidas.
- [ ] No existe `service_role` en frontend.
- [ ] RLS mantiene aislamiento entre estudiantes.
- [ ] Admin obtiene permisos por backend, no por UI.
- [ ] Preview no está indexado y no se usa como producción.

## Bloqueos conocidos

- Falta configurar responsable legal y email de privacidad antes de beta real.
- `Leaked Password Protection` permanece pendiente de activar desde la configuración de Supabase Auth.

## Regla de release

No actualizar `main` ni Netlify producción mientras exista un fallo crítico o de aislamiento de usuario.
