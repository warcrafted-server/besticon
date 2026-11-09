# Best Icon

Buscador visual de iconos para **WoW Forever** (build 1.60.1.70862, Interface 16001). Busca entre los 27 714 iconos del cliente por palabras en español o inglés y facilita usarlos en macros.

> Estado: versión 0.1.0 en desarrollo. La lógica (búsqueda, alias, favoritos, macros) está probada fuera del juego; la interfaz completa y la integración con macros **están pendientes de probar en el cliente** (ver [Estado de las funciones](#estado-de-las-funciones)). Sin licencia decidida todavía.

## Requisitos

- WoW Forever (cliente `_forever_`, build 1.60.1 o compatible con Interface 16001).

## Instalación

Copia la carpeta `BestIcon` de este repositorio a `World of Warcraft\_forever_\Interface\AddOns\` y reinicia el juego o escribe `/reload`.

En desarrollo se enlaza con una junction para que los cambios lleguen solos al cliente (PowerShell):

```powershell
New-Item -ItemType Junction -Path "C:\Wow\World of Warcraft\_forever_\Interface\AddOns\BestIcon" -Target "<ruta del repo>\BestIcon"
```

## Uso

Comandos: `/besticon` o `/bi` abren y cierran la ventana; `/besticon help` muestra la ayuda.

- **Buscar:** escribe en la caja de búsqueda, sin pulsar Enter. Funciona en español e inglés a la vez («hoguera», «campfire», «fogata»…), ignora mayúsculas y tildes y acepta plurales. También acepta un ID numérico o una ruta.
- **Categoría:** el botón junto a la búsqueda filtra por Campamentos, Comida y bebida, Armas, etc.
- **Seleccionar:** clic en un icono para ver su vista previa, nombre, ID, ruta, categorías y palabras clave. El ID y la ruta se pueden seleccionar y copiar con Ctrl+C.
- **Favoritos:** clic derecho en un icono (o el botón del panel). **Historial:** se guardan los últimos 40 seleccionados. Se consultan en las pestañas inferiores.
- **Tamaño de icono:** deslizador abajo a la derecha. La ventana se mueve y se redimensiona, y recuerda posición y tamaño.
- **Macros:** abre `/macro`, pulsa *Nuevo* o *Cambiar nombre/icono* y, con el selector abierto, usa *Usar en macro* o doble clic sobre un icono. Luego confirma tú en la ventana de macros. Si no se puede aplicar automáticamente, el addon explica qué hacer y puedes copiar el ID o la ruta.

## Estado de las funciones

Clasificación: CONFIRMADA (comprobada en el cliente), VERIFICADA (datos o tests fuera del cliente), EXPERIMENTAL (sin probar en el cliente), NO DISPONIBLE.

| Función | Estado |
|---|---|
| Versión, Interface 16001 y Lua 5.1 | CONFIRMADA |
| Carga del addon y ventana base nativa | CONFIRMADA |
| Catálogo de 27 714 iconos (`GetMacroIcons` + `GetMacroItemIcons`) | CONFIRMADA |
| Búsqueda bilingüe, categorías, favoritos e historial | VERIFICADA (tests) |
| Cuadrícula, pestañas, deslizador, panel de información | EXPERIMENTAL |
| Fijar el icono en el selector de macros de Blizzard | EXPERIMENTAL |
| Asignar un icono a una macro con la API (`C_Macro`) | NO DISPONIBLE (solo tiene `RunMacroText`, `GetMacroName`, `GetSelectedMacroIcon`) |

Detalles técnicos: [docs/INFORME-FASE1.md](docs/INFORME-FASE1.md), [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) y [docs/COBERTURA-IDIOMAS.md](docs/COBERTURA-IDIOMAS.md).

## Desarrollo

```
pip install lupa
python tests/run_tests.py          # lógica: búsqueda, alias, favoritos, macros (simulado)
python tests/run_ui_smoke.py       # interfaz con un cliente simulado; admite esES como argumento
```

Las herramientas de datos están en `tools/` (volcado en el juego, generación del catálogo y del vocabulario); ver la arquitectura.

## Licencia

Pendiente de decidir. Mientras tanto, todos los derechos reservados.
