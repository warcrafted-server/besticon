# Informe Fase 1: investigación (9-11-2026)

Estados: CONFIRMADA / VERIFICADA / EXPERIMENTAL / NO DISPONIBLE / DESCONOCIDA. Nada se ha ejecutado aún dentro del cliente.

## Cliente (local)

- Cliente Forever en `C:\Wow\World of Warcraft\_forever_` (producto `wowf`), build **1.60.1.70862** (`.build.info`). CONFIRMADA.
- Almacenamiento CASC/TACT (`Data/data`, 48 GB). La UI de Blizzard y los iconos no están en disco como archivos sueltos. CONFIRMADA.
- La familia es Mainline (API moderna, restricciones tipo Midnight). VERIFICADA (wiki Patch 1.60.1, fuentes de prensa; no es documentación oficial de la API).
- TOC: Interface `16001` usado por addons de Forever (Icon Finder Plus, RushForever). Sufijo `_Forever.toc` aceptado como alias de `_Camelot` desde la Beta 4 (build 70291). VERIFICADA.
- Lua: **5.1** (`_VERSION`). CONFIRMADA en el cliente.
- `GetBuildInfo()` en el juego: `1.60.1`, `70862`, `Nov 6 2026`, `16001`. CONFIRMADA.

## Iconos

- El catálogo de iconos son BLP en `Interface/ICONS/` dentro de CASC, referenciables por ruta o FileDataID. VERIFICADA (listfile).
- `community-listfile.csv` (wow-listfile, 154 MB, descargado y analizado): **37 112** rutas `interface/icons/*`. Incluye `inv_camelot_camping_campbenefits` (7808144) e `inv_camelot_camping_campfirenearby` (7808147). `inv_camelot_camping_welcomingcampfire` (7808148) también está: mi afirmación inicial de que faltaba era un error de lectura. Los nombres no están verificados (aviso del propio repo).
- Licencia del listfile: **DESCONOCIDA** (sin LICENSE visible). No incluirlo tal cual en el addon sin resolverlo.
- Alternativa propia: enumerar `Interface/ICONS` directamente del CASC local con CascLib (MIT). Sin licencia dudosa y refleja el build real. Pendiente de probar que CascLib abre este build (DESCONOCIDA).
- Los iconos nuevos de Forever pueden faltar en el listfile; extraer del cliente es la vía fiable.

## API de iconos y macros

- `GetMacroIcons` y `GetLooseMacroIcons`: existen como funciones. CONFIRMADA (su firma y lo que devuelven, EXPERIMENTAL hasta ejecutar `tools/BestIconDump`).
- `C_Macro` solo contiene `RunMacroText`, `GetMacroName` y `GetSelectedMacroIcon`. CONFIRMADA. No hay función de `C_Macro` para asignar icono.
- `IconSelectorPopupFrameTemplate` como global: `nil` (es plantilla XML, no concluyente). `SetMacroIcon`, `GetMacroItemIcons`: DESCONOCIDA hasta el volcado.
- Icon Finder Plus (Kaiba12, licencia «All Rights Reserved») funciona en Forever ampliando el selector de Blizzard. Es un indicio de que el selector compartido existe, pero no se puede reutilizar su código. Un dato suyo: evitó un escaneo de hechizos por fuerza bruta porque «podía provocar cierres» en Forever.
- Restricciones: las de Midnight («secrets») también rigen en Forever. Aplicar un icono a una macro no está en combate, así que debería ser viable, pero NO confirmado.

## Addons similares y licencias

| Proyecto | Uso | Licencia |
|---|---|---|
| Icon Finder Plus | Referencia de funciones (buscar por FileDataID, nombre de hechizo) | All Rights Reserved: no copiar código |
| wow-listfile | Fuente de rutas | Desconocida |
| CascLib | Extracción local | MIT |

## Propuesta técnica

1. **Datos**: script propio (Python/Node) que lee el CASC local y genera `Data/Icons_*.lua` por tramos (carga diferida). Cada registro: id, ruta, categoría, alias. Los alias se generan por reglas sobre el nombre (`campfire` → hoguera, fuego, campamento) en un archivo aparte y editable.
2. **Addon**: `BestIcon.toc` (Interface 16001), módulos Core, DB, Search, UI, Favoritos, Historial, Locales (esES/enUS), Macros. Comando `/besticon` con alias `/bi`.
3. **Macros**: probar primero en el cliente qué API existe; si no, mostrar la ruta/ID para copiarlos.

## Bloqueos y decisiones que necesito de ti

Decididas: cuenta GitHub `warcrafted-server`; comando `/besticon` (alias `/bi`); el catálogo se saca del propio cliente.

1. **Volcado en el juego**: copiar `tools/BestIconDump` a `_forever_/Interface/AddOns/`, `/bidump` y `/reload`. Genera `BestIconDumpDB` en SavedVariables con las listas reales de iconos y los globales del selector.
2. **Licencia** del proyecto: pendiente, la decides tú antes del primer push.

## Volcado del cliente (`/bidump`, 9-11-2026) — CONFIRMADA

- `GetMacroIcons()` devuelve 2 688 FileDataIDs numéricos; `GetMacroItemIcons()` 25 026; unión sin duplicados: **27 714**. `GetLooseMacroIcons()` devuelve lista vacía. Todas se llaman pasándoles una tabla que rellenan.
- Los 27 714 IDs tienen nombre en el listfile comunitario (`interface/icons/*`). Los tres iconos `inv_camelot_camping_*` están en el volcado.
- El listfile tiene 9 398 iconos más que el cliente no lista como iconos de macro. El catálogo se basa en el volcado, no en el listfile.
- Globales del selector presentes: `IconSelectorEditBoxMixin`, `IconSelectorPopupFrameIconFilterTypes`, `IconSelectorPopupFrameModes`, `IconSelectorPopupFrameTemplateMixin`, `IsAnyIconSelectorPopupFrameShown`, `MacroFrame_LoadUI`, `ShowMacroFrame`. Esto indica que el selector compartido de Blizzard existe (integración posible, EXPERIMENTAL hasta probarla).
- Siguiente: los nombres siguen dependiendo del listfile (licencia desconocida).
