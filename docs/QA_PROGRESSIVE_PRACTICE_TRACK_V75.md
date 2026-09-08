# QA · Itinerario práctico progresivo · v75

Fecha: 2026-09-08

## Objetivo

Evitar que el alumnado tenga que buscar por su cuenta un caso o material antes de poder empezar una práctica, especialmente al inicio del Máster, y aumentar la autonomía de forma gradual.

## Progresión aplicada

- **M1 · Nivel 1 · Caso asignado:** IKEA España es el caso común. La alumna no elige web todavía.
- **M2 · Nivel 2 · Caso común + evidencia propia:** se mantiene el dominio IKEA, pero la alumna empieza a obtener evidencia real. Cuando una actividad requiera participantes, no se permite inventar respuestas; si no puede reclutarlos, debe documentar la limitación.
- **M3 · Nivel 3 · Elección controlada:** se elige un flujo entre tres opciones: compra/carrito, entrega-recogida o devolución/incidencia.
- **M4–M6 · Nivel 3 · Continuidad:** el flujo elegido se lleva a Figma, Design System y responsive sin cambiar de producto.
- **M7–M9 · Nivel 4 · Implementación:** el trabajo propio pasa a HTML accesible, CSS y JavaScript.
- **M10 · Nivel 4 · Release y medición:** la implementación desplegada se convierte en el caso principal para SEO, rendimiento y QA.
- **M11 · Nivel 5 · Trabajo real:** case study, portfolio, alcance y defensa se construyen a partir del trabajo propio.
- **M12 · Nivel 5 · Autonomía profesional:** proyecto final propio, acotado y defendible con evidencia.

## Cambios de contenido

- `curriculum_modules_v2.metadata.practice_track` contiene ahora el nivel, modo, caso/contexto y regla de continuidad de cada módulo.
- La clase **1.1** queda fijada a IKEA España con URL directa y pasos de auditoría concretos.
- El cambio se registró en `program_curriculum_changes` como mejora de contenido.

## Cambios de frontend

Fuente dinámica: `development-current-index.html`, versión **75**.

- El drawer **Guía práctica** muestra el nivel de autonomía del módulo antes de la tarea.
- M1 y M2 ofrecen acceso directo al caso base.
- M3 muestra las tres rutas disponibles para elegir.
- M4–M10 recuerdan que se continúa el mismo proyecto en vez de obligar a buscar uno nuevo.
- M11–M12 explican claramente cuándo el trabajo pasa a ser del propio alumno.
- El texto de la guía deja explícito que el Campus aporta caso, contexto y siguientes pasos.

## Verificación

- Source version: `75`.
- Longitud lógica: `730351` caracteres.
- SHA-256 actual en Supabase: `56e6c2ed18840cc2ece9392e97d03ac64a56aefb7cb401098936f11c609d7778`.
- `PRACTICE_TRACK_UI`: presente.
- Etiqueta `4.14R · Itinerario práctico progresivo y autonomía guiada`: presente.
- Los 12 módulos tienen `practice_track` y una progresión 1→5 comprobada.
- El bloque JavaScript nuevo se validó con `node --check`: PASS.

## Pendiente de QA real

- Abrir la guía de 1.1 y comprobar el CTA de IKEA.
- Abrir una clase del M3 y revisar que aparecen las tres opciones.
- Abrir una clase de M7/M10/M12 y comprobar que el nivel de autonomía cambia correctamente.
- Revisar drawer en móvil como bottom sheet.
- Publicar únicamente mediante paquete Netlify completo que restaure `_headers` y `_redirects`.