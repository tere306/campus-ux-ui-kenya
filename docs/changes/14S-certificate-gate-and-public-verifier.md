# 14S · Certificado ligado a la ficha confirmada

Fecha: 2026-09-07

## Emisión

La emisión de nuevos certificados queda bloqueada si la ficha del alumno no contiene:

- nombre;
- primer apellido;
- confirmación explícita del nombre para el certificado;
- timestamp de esa confirmación.

El segundo apellido sigue siendo opcional.

El certificado toma el nombre desde `first_name + last_name_1 + last_name_2`, no desde el nombre técnico/legacy del perfil.

Si el alumno cambia nombre o apellidos, el trigger de perfil invalida la confirmación previa y será necesario confirmar de nuevo antes de emitir.

Los certificados ya emitidos siguen siendo inmutables; no se reescriben al editar después el perfil.

## Datos privados

No se incorporan al certificado:

- email;
- teléfono;
- DNI/NIE/pasaporte;
- IDs internos del alumno.

## Verificador público

La RPC pública `verify_master_certificate_v2` se ha reducido a la información mínima:

- estado (`valid`, `revoked`, `not_found`);
- código del certificado;
- nombre del titular;
- programa;
- fecha de finalización.

Se han retirado de la respuesta pública:

- hashes de certificado/expediente;
- UUID/verification id;
- versión curricular;
- carga horaria;
- timestamps internos de emisión/revocación;
- scope técnico de la credencial.

## Migración

`supabase/migrations/20260907162000_master_student_profile_certificate_gate_14s.sql`

Aplicada correctamente en Supabase el 2026-09-07.

## Prueba no destructiva

`verify_master_certificate_v2('INVALID')` devuelve únicamente:

```json
{"valid": false, "status": "not_found"}
```

No se crearon certificados de prueba ni registros académicos falsos en producción.
