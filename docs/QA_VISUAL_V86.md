# QA visual y responsive · v86

Fecha: 2026-09-29

## Candidata

- alias Supabase: `development-current-index.html`
- versión: **86**
- snapshot: `development-14zg-visual-polish-index.html`
- SHA-256 HTML: `61d55f06c7ee1e15c81cb7149314333cd4412be033e1f3eaee88d48960244715`

## Metodología

El workflow `Visual smoke` sirve la fuente versionada de GitHub y ejecuta Chromium real con identidades ficticias. No usa contraseñas ni cuentas reales y bloquea las llamadas de Supabase con respuestas mock durante esta prueba visual.

Viewports:
- escritorio: 1440 × 1000;
- móvil: 390 × 844.

Escenarios:
- login;
- Alumna: Inicio, Programa, Aula, Entregas, Biblioteca, Portfolio, Progreso y Mi perfil;
- Admin: Panel, Alumnas, Evaluaciones, Contenido y Ajustes.

Total: **28 escenarios**.

## Criterios automáticos

- sin errores JavaScript de página;
- sin overflow horizontal global;
- sin elementos visibles fuera del viewport salvo wrappers de tabla previstos;
- sin imágenes visibles rotas;
- encabezado principal presente en vistas autenticadas;
- capturas full-page conservadas como artifact de GitHub Actions.

Resultado v86: **PASS**.

- 28/28 escenarios;
- `scrollWidth == viewport width` en todos;
- imágenes rotas: 0;
- errores de página: 0.

## Revisión visual manual de capturas

La revisión v85 detectó dos problemas que no aparecían como overflow:

1. secuencia `\\n` literal visible sobre la aplicación;
2. etiqueta “Pendiente de confirmar” excesivamente estrecha en ficha de alumna móvil.

v86 corrige ambos:
- el separador entre auth boot y login vuelve a ser un salto real de línea;
- `.profile-card-head` apila estado y contenido de forma legible en móvil.

La captura v86 de perfil móvil mantiene un nombre ficticio largo y un email largo sin romper la tarjeta. La etiqueta de estado queda horizontal y el contenido mantiene jerarquía visual.

## Marca y assets

Se eliminó la dependencia perdida `campus-logo.webp`.

Assets oficiales versionados:
- `zavra-logo-black.png` — `a720dd56c8d5c0e226a239be35a7c4c4ef810f6c1062a6dd7da55e1ecc1f4f1c`
- `zavra-logo-white.png` — `fc16b864bec32a2416d917b75de39091f2fefa4255415524459052db7c21dc18`
- `zavra-logo-black-tagline.png` — `5566affb278928c54d7799919c666d67a8d1eb23edd5e550e56f916745540a43`

El Frontend guard comprueba sus hashes y el Visual smoke comprueba que no se renderice ninguna imagen rota.

## Producción

Producción no fue modificada durante este QA.

El deploy público actual `6aa2b472eea4967d3570df63` sigue siendo manual y su antigua ruta `/campus-logo.webp` devuelve 404. Este defecto queda corregido en la candidata v85+ pero no se considera resuelto en producción hasta desplegarla y hacer smoke test sobre el dominio final.
