# Arquitectura de Best Icon

Namespace compartido `local ADDON, BI = ...` en todos los archivos. Orden de carga en `BestIcon.toc`.

| Carpeta | Contenido |
|---|---|
| `Core/` | `Init.lua` (crea `BI.DB`, eventos y comandos), `Config.lua` (`BestIconDB`: posición, tamaño, `iconSize`, `favorites`, `history`, `activeTab`, `lastSelected`), `DB.lua` (acceso al catálogo: `Count`, `Get(pos)`, `GetByID`, `Path`) |
| `Locales/` | `Locale.lua` (`BI.L` con fallback a enUS y luego a la clave), `enUS.lua`, `esES.lua`. Ninguna cadena visible fuera de aquí |
| `Data/` | `Icons_NN.lua` (generados), `Aliases/esES_*.lua` (alias por palabra), `Categories.lua` (reglas por palabra) |
| `Search/` | `Normalize.lua` (minúsculas, sin tildes, plurales), `Index.lua` (índice por palabra, `BuildAsync` por tramos), `Search.lua` (`Run(consulta, categoría)`) |
| `Features/` | `Favorites.lua`, `History.lua`, `Results.lua` (resultados por pestaña, sin interfaz) |
| `Macros/` | `Macros.lua`: `Apply`, `UsePosition` y botón en `MacroPopupFrame` |
| `UI/` | `Main.lua` (ventana, pestañas, búsqueda), `Grid.lua` (cuadrícula virtualizada propia con Slider y botones reciclados), `Info.lua` (panel de información) |

## Datos

- **Catálogo:** `{FileDataID, "Nombre_De_Ruta"}`, unos 3 000 por archivo. Se regenera con `python tools/build_catalog.py <BestIconDump.lua> <community-listfile-withcapitals.csv>`. El volcado sale del juego con `tools/BestIconDump` (`/bidump` y `/reload`; el archivo queda en `WTF/Account/<cuenta>/SavedVariables/BestIconDump.lua`).
- **Alias:** `BI.Aliases.<locale>[palabra_en_ingles] = {sinónimos}`, sin tildes. Para ver qué palabras faltan por traducir, `tools/build_vocab.py` genera `tools/vocab.tsv` con frecuencias.
- **Añadir un idioma:** crear `Data/Aliases/<locale>_NN.lua` y `Locales/<locale>.lua`, y listarlos en el TOC. La búsqueda consulta todos los idiomas cargados.
- **Añadir una categoría:** una entrada en `Data/Categories.lua` y sus textos `cat_<clave>` en `Locales/`.

## Búsqueda

Cada palabra de la consulta se normaliza y se compara con las palabras de la ruta y sus alias: exacta (3), prefijo (2), subcadena de al menos 3 letras (1). Deben casar todas las palabras. Orden: puntuación, nombre más corto, ID. La construcción del índice (unos 1,6 s en Lua de escritorio) se hace por tramos para no bloquear el cliente.

## Integración con macros

`C_Macro` no permite asignar iconos, así que se actúa sobre el selector de Blizzard: `MacroPopupFrame:GetIndexOfIcon` y `IconSelector:SetSelectedIndex`. No se pulsa nunca el botón de aceptar ni se tocan frames protegidos, y no se actúa en combate.
