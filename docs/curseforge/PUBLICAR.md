# Publicar en CurseForge

Guía para quien sube el proyecto. Base: documentación de autores de CurseForge (support.curseforge.com), leída el 2026-11-10. La subida la hace el titular desde su cuenta; no se automatiza ni se guardan tokens en el repo.

## Antes de subir

1. `python tools/package.py` genera `dist/BestIcon-<versión>.zip` (una sola carpeta raíz `BestIcon/`, con `LICENSE` y `CREDITS.md`).
2. Probar en el cliente lo que la descripción promete: pestañas, favoritos y el botón *Usar en macro* (ya confirmados en el cliente). Si algo falla, quitarlo de `DESCRIPTION.md`.
3. Capturas limpias (sin chat) para la galería: (a) ventana con la búsqueda «campfire»; (b) la misma con «hoguera»; (c) panel de información de un icono; (d) ventana junto a `/macro` con el selector abierto; (e) pestaña Favoritos.

## Crear el proyecto

1. https://authors.curseforge.com/#/projects/create/choose-game → World of Warcraft → Addon.
2. **Name:** `Best Icon` (debe ser único). **Summary:** «Visual icon browser for WoW Forever: search 27,714 icons by name in English and Spanish, preview them and copy IDs or paths for macros.»
3. **Description:** pegar `DESCRIPTION.md` en el editor Markdown. **Logo:** `logo.png` (400×400, PNG).
4. **Categorías:** elegir las que mejor encajen entre las que ofrezca el desplegable (Main y hasta 4 adicionales).
5. **License:** *Custom License* y pegar el texto de `LICENSE` (WNCL-TP-1.0); las licencias estándar no la cubren.
6. Galería: pestaña *Images* del proyecto, con título y descripción por imagen.

## Subir el archivo

1. Pestaña *Files* → subir `BestIcon-0.1.0.zip`.
2. **Release type:** Release. **Supported version:** la etiquetada *Forever* (1.60.1 en otros addons Forever).
3. **Changelog:** pegar `CHANGELOG-0.1.0.md` en formato Markdown.
4. Queda «Under Review»; moderación puede pedir cambios. Tras aprobarse, anotar el ID del proyecto y añadir `## X-Curse-Project-ID: <id>` al `.toc` en una versión posterior.

## Riesgos a tener presentes

- La política de moderación exige permiso o licencia para contenido ajeno y créditos. Los nombres de iconos del listfile comunitario no tienen licencia declarada (ver `CREDITS.md`). Se publica asumiendo ese riesgo; si moderación lo objeta, habrá que quitar los nombres o contactar con wow-listfile.
- Títulos y descripciones en inglés primero; el español va después.
- No se permiten re-subidas sin cambios y cada archivo necesita changelog.
