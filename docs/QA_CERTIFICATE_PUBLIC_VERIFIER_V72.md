# QA · certificado y verificador público · v72

Fecha: 2026-09-08

## Alcance

Auditoría de integridad del certificado v2, generación de códigos públicos, verificador anónimo, revocación e inmutabilidad del expediente/credencial.

## Generación del código

`private.prepare_certificate_v2()` genera un `verification_id` mediante `gen_random_uuid()` y deriva el código público como:

`MUXUI-` + UUID en mayúsculas sin guiones.

Formato esperado por el verificador:

`^MUXUI-[A-F0-9]{32}$`

El código es no secuencial y de alta entropía. La tabla impone unicidad sobre:

- `certificate_code`
- `verification_id`
- `certificate_hash`
- `completion_record_id`

Esto impide duplicados de código/hash y más de un certificado por expediente final.

## Verificador público

Única RPC accesible por `anon` para esta función:

`verify_master_certificate_v2(text)`

La RPC pública delega en `private.verify_master_certificate_private_v2`.

Comportamiento comprobado:

- formato inválido -> `{ valid:false, status:'not_found' }`
- formato válido pero inexistente -> `{ valid:false, status:'not_found' }`
- válido existente -> datos mínimos de verificación
- revocado existente -> mismo conjunto mínimo, con `status:'revoked'`

Datos públicos devueltos únicamente:

- estado válido/revocado
- código de certificado
- nombre del certificado
- título del programa
- fecha de finalización

No devuelve:

- email
- teléfono
- notas
- TFM
- transcript completo
- hashes internos
- UUID de alumna
- razón de revocación

El rol `anon` no tiene SELECT directo sobre `student_certificates_v2` ni `student_certificate_revocations_v2`; la exposición pública se limita a la RPC.

## Enumeración

El verificador no diferencia entre código con formato incorrecto y código correctamente formado pero inexistente: ambos devuelven `not_found`.

Los códigos no son secuenciales y el espacio de búsqueda efectivo es impracticable para enumeración por fuerza bruta.

Mostrar `valid` frente a `revoked` para un código real es comportamiento funcional intencional de un verificador de credenciales, no una fuga adicional de identidad.

## Integridad e inmutabilidad

`student_certificates_v2` tiene trigger `prevent_certificate_mutation_v2` que bloquea cualquier `UPDATE` o `DELETE` después de emisión.

La revocación se registra en tabla separada `student_certificate_revocations_v2`; su PK es `certificate_id`, por lo que solo puede existir una revocación por certificado.

La revocación no reescribe el snapshot ni el hash original del certificado.

La emisión requiere:

- sesión autenticada;
- rol Admin real del programa;
- expediente finalizado;
- perfil de certificación completo;
- nombre de certificado confirmado;
- currículo actual correcto.

## Prueba directa

En el estado actual no hay certificados reales emitidos (`certificate_count = 0`). Se probaron dos códigos sintéticos sin tocar datos:

- `MUXUI-00000000000000000000000000000000`
- `not-a-certificate`

Ambos devolvieron exactamente `valid=false, status=not_found`.

## Resultado

**PASS**

No se ha identificado una vía práctica de falsificación, enumeración o lectura anónima directa de certificados. No se requiere cambio de frontend ni migración; baseline se mantiene en v72.

## Pendiente real

Cuando exista el primer certificado real, ejecutar smoke end-to-end:

1. emitir desde Admin;
2. abrir verificador público sin sesión;
3. comprobar datos mínimos;
4. revocar con motivo válido;
5. verificar que pasa a `revoked` sin alterar snapshot/hash;
6. confirmar que el expediente final permanece inmutable.
