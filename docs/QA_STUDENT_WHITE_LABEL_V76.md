# QA · White-label de experiencia Alumna · v76

Fecha: 2026-09-08

## Objetivo

Evitar que la experiencia de alumnado exponga nombres de proveedores o jerga de infraestructura cuando el mensaje puede expresarse como lenguaje de producto.

## Cambios

Se han sustituido mensajes visibles durante sincronización, conflictos, guardado, conexión y cierre de sesión:

- `Supabase no confirmó el cambio` → `El campus no confirmó el cambio`.
- Conflictos de `versión remota` → `versión más reciente del campus`.
- `progreso remoto` → `progreso` / `progreso sincronizado`.
- `entregas remotas` → `entregas`.
- `borrador remoto` → `borrador más reciente del campus`.
- `evaluación remota` → `evaluación`.
- `permisos remotos` → `permisos de módulos`.
- `cierre remoto` → `cierre académico`.
- `respaldo local` → `guardado en este dispositivo` cuando el mensaje se muestra a la alumna.
- El aviso de logout ya no indica que la sesión debe invalidarse “en Supabase”; explica el efecto en otros dispositivos.
- El aviso offline habla de `cambios en línea` y no de `escrituras remotas`.

## Alcance

Las referencias técnicas se conservan donde son útiles para **Administración/Ajustes** y en código interno. El objetivo no es ocultar la arquitectura al equipo técnico, sino que el alumnado no tenga que conocer proveedores para entender el estado de su trabajo.

Las referencias `Netlify` restantes están en metadata/documentación interna o en la pantalla Admin de preparación de producción, no en las páginas principales de Alumna.

## Frontend

- Alias: `development-current-index.html`.
- Versión: **76**.
- Longitud lógica: `730586` caracteres.
- SHA-256 actual en Supabase: `ba6229534a198f6f619094c804c2b8b4f417c1cdd5f4f6d73bb0f0d17e36637a`.
- `PRACTICE_TRACK_UI` de v75 preservado.
- JavaScript del snapshot local equivalente validado con `node --check`: PASS.

## Comprobaciones estáticas

PASS:

- no queda el mensaje `Supabase no confirmó el cambio`;
- no queda `invalidarla en Supabase` en el logout;
- no queda el banner `El progreso remoto de clases no está disponible`;
- se mantiene el itinerario práctico progresivo de v75.

## Pendiente de QA real

- provocar offline/online y revisar copy visible;
- provocar un conflicto de progreso con dos pestañas;
- comprobar cierre de sesión con red y con fallo de red;
- revisar Alumna completa antes del release.