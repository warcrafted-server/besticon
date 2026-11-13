# Best Icon

[English](#english) · [Español](#español)

---

## English

Visual icon browser for **WoW Forever** (build 1.60.1, Interface 16001). Search the 27,714 icons of the client by words in English or Spanish and use them in your macros.

### Requirements

- WoW Forever (`_forever_` client, Interface 16001).

### Installation

Install **Best Icon** from the CurseForge app (select your Forever installation), or copy the addon to `World of Warcraft\_forever_\Interface\AddOns\BestIcon\` and restart the game or type `/reload`.

### Usage

Commands: `/besticon` or `/bi` open and close the window; `/besticon help` shows the help.

- **Search:** type in the search box, no Enter needed. English and Spanish are searched together ("campfire", "hoguera", "fogata"…), ignoring capitals and accents, and plurals work. A numeric ID or a path also works.
- **Category:** the button next to the search filters by Camps, Food and drink, Weapons, etc.
- **Select:** click an icon to see its preview, name, ID, path, categories and keywords. ID and path can be copied with Ctrl+C.
- **Favorites:** right-click an icon (or use the panel button). **History:** the last 40 selected icons. Both are in the tabs at the bottom.
- **Icon size:** slider at the bottom right. The window can be moved and resized, and remembers its position and size.
- **Macros:** open `/macro`, press *New* or *Change Name/Icon* and, with the picker open, use *Use in macro* or double-click an icon. Then confirm in the macro window. If it cannot be applied automatically, the addon tells you what to do and you can copy the ID or path.

### Feature status

| Feature | Status |
|---|---|
| Interface 16001, Lua 5.1 | CONFIRMED |
| Catalog of 27,714 icons (`GetMacroIcons` + `GetMacroItemIcons`) | CONFIRMED |
| Bilingual search, categories, favorites, history, tabs, size slider | CONFIRMED (tested in the client) |
| Select the icon in Blizzard's macro picker | CONFIRMED (tested in the client) |
| Assign an icon to a macro through the API (`C_Macro`) | NOT AVAILABLE (only `RunMacroText`, `GetMacroName`, `GetSelectedMacroIcon` exist) |

Technical details: [docs/INFORME-FASE1.md](docs/INFORME-FASE1.md), [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) and [docs/COBERTURA-IDIOMAS.md](docs/COBERTURA-IDIOMAS.md) (in Spanish).

### Development

```
pip install lupa
python tests/run_tests.py          # logic: search, aliases, favorites, macros (simulated)
python tests/run_ui_smoke.py       # UI with a simulated client; accepts esES as an argument
```

Development uses a junction `AddOns\BestIconDev` pointing to this folder, with its own `BestIconDev.toc` (ignored by git), so it can live next to the published version; enable only one of them at a time. Data tools are in `tools/` (in-game dump, catalog and vocabulary generation).

### Credits and license

**Best Icon** is developed and maintained by **WarCrafted**.
Copyright (C) 2026 WarCrafted.

Licensed under [WNCL-TP-1.0](LICENSE): free to use, study, modify and share for non-commercial purposes. Selling or any commercial use requires written permission. It covers only original material; third-party components keep their own licenses.

Copies and forks must keep this attribution and link to https://github.com/warcrafted-server/besticon.

#### Third-party material

| Component | Author | License | Link |
| --- | --- | --- | --- |
| Icon names (`Data/Icons_*.lua`), from the community listfile | wowdev community | Not declared by the source | https://github.com/wowdev/wow-listfile |

The icons belong to Blizzard Entertainment and are not distributed: they are read from the game client.

Full credits: [CREDITS.md](CREDITS.md).

---

## Español

Buscador visual de iconos para **WoW Forever** (build 1.60.1, Interface 16001). Busca entre los 27 714 iconos del cliente por palabras en español o inglés y facilita usarlos en macros.

### Requisitos

- WoW Forever (cliente `_forever_`, Interface 16001).

### Instalación

Instala **Best Icon** desde la app de CurseForge (selecciona tu instalación de Forever), o copia el addon a `World of Warcraft\_forever_\Interface\AddOns\BestIcon\` y reinicia el juego o escribe `/reload`.

### Uso

Comandos: `/besticon` o `/bi` abren y cierran la ventana; `/besticon help` muestra la ayuda.

- **Buscar:** escribe en la caja de búsqueda, sin pulsar Enter. Funciona en español e inglés a la vez («hoguera», «campfire», «fogata»…), ignora mayúsculas y tildes y acepta plurales. También acepta un ID numérico o una ruta.
- **Categoría:** el botón junto a la búsqueda filtra por Campamentos, Comida y bebida, Armas, etc.
- **Seleccionar:** clic en un icono para ver su vista previa, nombre, ID, ruta, categorías y palabras clave. El ID y la ruta se pueden copiar con Ctrl+C.
- **Favoritos:** clic derecho en un icono (o el botón del panel). **Historial:** los últimos 40 seleccionados. Se consultan en las pestañas inferiores.
- **Tamaño de icono:** deslizador abajo a la derecha. La ventana se mueve y se redimensiona, y recuerda posición y tamaño.
- **Macros:** abre `/macro`, pulsa *Nuevo* o *Cambiar nombre/icono* y, con el selector abierto, usa *Usar en macro* o doble clic sobre un icono. Luego confirma tú en la ventana de macros. Si no se puede aplicar automáticamente, el addon explica qué hacer y puedes copiar el ID o la ruta.

### Estado de las funciones

| Función | Estado |
|---|---|
| Interface 16001 y Lua 5.1 | CONFIRMADA |
| Catálogo de 27 714 iconos (`GetMacroIcons` + `GetMacroItemIcons`) | CONFIRMADA |
| Búsqueda bilingüe, categorías, favoritos, historial, pestañas y deslizador de tamaño | CONFIRMADA (probado en el cliente) |
| Fijar el icono en el selector de macros de Blizzard | CONFIRMADA (probado en el cliente) |
| Asignar un icono a una macro con la API (`C_Macro`) | NO DISPONIBLE (solo tiene `RunMacroText`, `GetMacroName`, `GetSelectedMacroIcon`) |

Detalles técnicos: [docs/INFORME-FASE1.md](docs/INFORME-FASE1.md), [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) y [docs/COBERTURA-IDIOMAS.md](docs/COBERTURA-IDIOMAS.md).

### Desarrollo

```
pip install lupa
python tests/run_tests.py          # lógica: búsqueda, alias, favoritos, macros (simulado)
python tests/run_ui_smoke.py       # interfaz con un cliente simulado; admite esES como argumento
```

El desarrollo usa una junction `AddOns\BestIconDev` hacia esta carpeta, con su propio `BestIconDev.toc` (ignorado por git), para convivir con la versión publicada; activa solo una de las dos a la vez. Las herramientas de datos están en `tools/` (volcado en el juego, generación del catálogo y del vocabulario).

### Créditos y licencia

**Best Icon** está desarrollado y mantenido por **WarCrafted**.
Copyright (C) 2026 WarCrafted.

Licencia [WNCL-TP-1.0](LICENSE): puedes usarlo, estudiarlo, modificarlo y compartirlo gratis con fines no comerciales. Venderlo o cualquier uso comercial requiere permiso por escrito. Solo cubre el material propio; los componentes de terceros conservan su licencia.

Las copias y los forks deben conservar esta atribución y enlazar a https://github.com/warcrafted-server/besticon.

#### Material de terceros

| Componente | Autor | Licencia | Enlace |
| --- | --- | --- | --- |
| Nombres de iconos (`Data/Icons_*.lua`), de la lista de archivos comunitaria | Comunidad wowdev | No declarada por el origen | https://github.com/wowdev/wow-listfile |

Los iconos son de Blizzard Entertainment y no se distribuyen: se leen del cliente del juego.

Créditos completos: [CREDITS.md](CREDITS.md).
