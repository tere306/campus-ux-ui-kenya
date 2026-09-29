# QA de HTML dinámico y superficie XSS — v71

Fecha: 2026-09-08
Rama: `develop`
Baseline: `development-current-index.html` v71
SHA-256: `f3b4aadee130d94222f0faa351e6d488f99d86bfee57bc876ce0e05b9c8fb004`

## Objetivo

Revisar de forma estática los principales sinks de ejecución/HTML y comprobar que los datos remotos o introducidos por alumnas/admin no entren en plantillas dinámicas sin escape o validación de URL.

## Barrido de sinks

- `innerHTML`: 29 ocurrencias. Revisadas por contexto.
- `insertAdjacentHTML`: 0.
- `outerHTML`: 0.
- `document.write`: 0.
- `eval(`: 0.
- `new Function(`: 0.
- `onerror=`: 0.
- Las dos ocurrencias textuales de `javascript:` pertenecen al contenido didáctico del curso sobre rendimiento JavaScript, no a URLs ni handlers ejecutables.
- Las ocurrencias textuales de `onclick=` detectadas por el barrido corresponden principalmente a asignaciones de propiedades DOM en JavaScript (`element.onclick=...`), no a interpolación de handlers con datos de usuario.

## Zonas revisadas

### Verificador público de certificados

El render dinámico usa `esc(...)` para:
- título/programa,
- nombre de alumna,
- código de certificado.

El resto de estados son valores internos controlados (`valid`, `revoked`, `not_found`, `unavailable`). No se encontró interpolación de HTML remoto sin escape.

### Entregas y evaluación

Datos introducidos por la alumna o procedentes de Supabase:
- texto de entrega: `esc(sub.text)`;
- feedback: `esc(...)`;
- nombre de alumna: `esc(name)`;
- URLs de proyecto/evidencia: solo generan `<a>` si pasan `safeHttpHref(...)` y luego se escapan en atributo;
- enlaces externos generados usan `target="_blank"` + `rel="noopener"`.

Los campos editables se vuelcan en `<textarea>`/`value` con escape.

### Gestión de invitaciones

- nombre y email: `esc(...)` antes del render;
- código de activación: `esc(...)`;
- enlace generado: origen fijo de producción + parámetros serializados con `URL` / `URLSearchParams`, y posteriormente `esc(...)` dentro del atributo `value`;
- mensajes de error de red insertados mediante `esc(networkMessage(err))`.

### Ficha Admin de alumna

Se escapan antes de entrar en HTML:
- nombre/identidad,
- nombre de certificado,
- teléfono,
- acción contextual,
- identificador de expediente,
- hash mostrado,
- código de certificado,
- actividad reciente,
- títulos de módulos y fuentes dinámicas.

Los valores numéricos/booleanos restantes proceden de coerciones (`Number(...)`, contadores, flags internos).

### Banners y confirmaciones

Los mensajes dinámicos de errores/sync pasan por `esc(...)`. `askConfirm(...)` escapa `title`, `message`, `hint` y `requireText` antes de construir el diálogo.

## Observaciones

Algunos bloques de currículo (`prompt`, rúbricas, requisitos, etc.) se insertan como HTML sin `esc(...)`, pero son contenido estático incluido en el propio asset del campus, no contenido de usuario ni lectura remota mutable. No constituyen una vía XSS mientras ese corpus siga siendo parte versionada/controlada del bundle.

No se encontró una vía XSS explotable en esta revisión estática de v71.

## Resultado

**PASS — sin hallazgos que requieran una nueva versión de frontend.**

Esta revisión no sustituye QA en navegador con payloads reales cuando esté disponible la herramienta de browser testing.

Producción Netlify, `main` y release final permanecen sin cambios.
