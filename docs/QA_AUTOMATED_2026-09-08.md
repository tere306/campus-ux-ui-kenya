# QA automatizado — 2026-09-08

## Alcance
- Rama revisada: `develop`.
- Proyecto Supabase: `pioc-campus` (`azacjdyxgknfqarcemhi`).
- Producción Netlify: sin cambios.
- `main`: sin merge.
- Release final: no publicada.

## Estado Git
- `develop` estaba en `1dc60d1fec478ef6d5413c0caa4901257b33a216` al iniciar esta pasada.
- Comparación `main...develop`: `develop` 80 commits por delante y 0 por detrás.

## Supabase Security Advisor
Único aviso detectado:
- `auth_leaked_password_protection`: **Leaked Password Protection Disabled**.

No se detectó en esta pasada ningún lint de seguridad crítico adicional.

Referencia oficial:
https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

## Performance Advisor
En la revisión previa del mismo ciclo de QA se observaron avisos de:
- índices todavía no usados;
- múltiples políticas RLS permisivas para una misma operación/rol.

No se han eliminado índices ni fusionado políticas automáticamente. Antes de cualquier refactor de RLS debe demostrarse equivalencia de autorización con cuentas/roles reales, porque una optimización de rendimiento no compensa introducir una regresión de aislamiento.

## Edge Functions revisadas
Se verificó en la auditoría previa de esta misma fase que los endpoints legacy revisados estaban neutralizados con HTTP 410 y sin operación privilegiada activa, entre ellos:
- `pioc-campus`;
- `pioc-publish-web`;
- `patch-v9-admin-nav`.

También se comparó `activate-student-invite` desplegada con `develop`: el flujo revisado coincide con el código versionado y mantiene las protecciones esperadas (código 24-hex, expiración/bloqueo, política de contraseña y borrado del usuario Auth si el enrollment no queda validado).

## Deuda detectada
`campus-development-preview` mantiene la clave de preview incrustada en el source desplegado de la Edge Function. No se publica aquí su valor.

Recomendación antes de producción:
1. mover la clave a un secret/runtime env;
2. rotarla;
3. verificar que el preview sigue protegido y operativo;
4. confirmar que ninguna copia de la clave aparece en Git o artefactos públicos.

No se cambia ahora para evitar romper el preview sin una vía verificada de gestión/rotación de secretos.

## Veredicto de esta pasada
- Sin nueva regresión automática detectada.
- `develop` sigue siendo candidato a **browser QA**, no a producción final.
- Prioridades siguientes:
  1. QA visual/responsive real;
  2. login/F5/logout y cambio entre cuentas;
  3. flujo real alumno ↔ admin con dos identidades;
  4. recovery/email redirect;
  5. habilitar/revisar Leaked Password Protection;
  6. externalizar y rotar la clave del preview;
  7. completar datos legales reales antes de alumnos reales.
