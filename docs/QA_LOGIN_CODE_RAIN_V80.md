# QA · Portada con lluvia de código azul · v80

Fecha: 2026-09-08

## Objetivo

Añadir a la portada/login del Campus una animación ambiental inspirada en terminales de código, manteniendo la identidad navy + índigo/violeta del producto.

## Implementación

- Canvas decorativo a pantalla completa dentro del login.
- Glifos de código (`0`, `1`, símbolos, `UXUIWEB`) en tonos azul, índigo y violeta.
- Caída vertical con estelas cortas y brillo suave.
- La tarjeta de acceso permanece por encima de la animación y conserva fondo blanco sólido.
- El contenido principal mantiene contraste mediante overlay y sombreado ligero.
- La animación se pausa cuando el login no está visible o la pestaña queda en segundo plano.
- `prefers-reduced-motion: reduce` desactiva el movimiento y conserva una composición estática.
- Densidad y tamaño se reducen en pantallas estrechas para evitar sobrecarga visual y consumo innecesario.

## QA estático

- JavaScript extraído y validado con `node --check`: PASS.
- Canvas marcado `aria-hidden="true"`: PASS.
- No captura eventos de puntero: PASS.
- Sin dependencias externas nuevas: PASS.
- `_headers` y `_redirects` se mantienen en el paquete de despliegue.

## Estado

- Fuente dinámica del Campus actualizada a v80.
- Producción no se ha sustituido automáticamente en esta iteración.
- Paquete manual preparado para Netlify con `index.html`, `campus-logo.webp`, `_headers` y `_redirects`.
