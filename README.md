# Campus UX/UI Kenya

Repositorio oficial de código y copias de seguridad del campus UX/UI.

## Estado inicial

- Frontend de producción: Netlify
- Backend / datos / Auth: Supabase (`pioc-campus`)
- Producción identificada: https://fancy-cranachan-c98e89.netlify.app/
- Este repositorio se utilizará como copia versionada del código y de la documentación técnica.

## Política de ramas

- `main`: versión estable.
- `develop`: trabajo previo a producción.
- `backup/...`: snapshots antes de cambios importantes.
- `feature/...`: cambios aislados cuando sea necesario.

## Seguridad

No subir nunca:

- `.env`
- contraseñas
- claves `service_role`
- tokens privados
- secretos administrativos
- datos personales exportados de alumnos

## Regla de trabajo

Antes de cada cambio importante:

1. crear backup recuperable;
2. trabajar fuera de `main` cuando proceda;
3. probar el cambio;
4. documentar el resultado;
5. actualizar `main` solo cuando esté validado.
