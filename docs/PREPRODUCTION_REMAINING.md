# Preproducción · trabajo restante

Actualizado: 2026-09-07

## Estimación de avance

- Backend / Supabase / RLS / seguridad automática: **95%**
- Frontend funcional y QA estático: **90%**
- QA real en navegador y responsive: **pendiente principal**
- Release / despliegue final: **pendiente hasta superar QA**
- Avance global estimado de preproducción: **80–85%**

La estimación no significa que se pueda publicar con un 80–85%: los pasos restantes incluyen pruebas de extremo a extremo y son bloqueadores obligatorios.

## Lo que todavía puede hacerse sin intervención de la usuaria

- continuar auditoría estática de accesibilidad, formularios y navegación;
- revisar consistencia de roles, permisos y superficie RPC;
- revisar migraciones y trazabilidad GitHub/Supabase;
- preparar checklist de smoke test y rollback;
- mantener `development-current-index.html` validado y versionado.

## Bloqueadores que requieren navegador/configuración real

1. QA visual y responsive: 320/360/390/412, tablet y escritorio.
2. Login real, F5, logout y cambio Alumna/Admin.
3. Segunda cuenta real: invitación → activación → primer login → aparición en Admin.
4. Flujo académico real: progreso → entrega → evaluación → feedback → desbloqueo.
5. Cambio de cuenta en un mismo navegador para comprobar purga de caché.
6. Recuperación de contraseña: recepción del email y redirect real.
7. Datos legales definitivos: responsable del tratamiento y email de privacidad.
8. Activar/revisar Leaked Password Protection en Supabase Auth.
9. Promoción a producción y smoke test posterior al deploy.

## Regla de salida

No fusionar el PR de preproducción ni sustituir el deploy público hasta que los bloqueadores anteriores estén comprobados. Producción se mantiene intacta mientras tanto.

## Frontend actual

- versión: **v59**
- asset: `development-14x-search-accessibility-index.html`
- alias: `development-current-index.html`
- SHA-256: `5e7863558a430923e5db1a4b3dabbb089410f2c65b2e7d6b6ca4152e56722f83`
- v58 hizo explícito `type="button"` en 66 acciones que dependían del tipo implícito, conservando 5 submits reales.
- v59 añade nombre accesible a los dos campos de búsqueda que dependían solo de placeholder.
