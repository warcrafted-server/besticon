# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/), versionado SemVer.

## [Sin publicar]

## [0.2.0] - 2026-11-13

Novedad: búsqueda por intención.

### Añadido
- Búsqueda por intención: palabras como «gracias», «saludo», «bienvenida», «ayuda», «fiesta», «amor», «brindis», «victoria», «peligro», «muerte», «paz», «música» o «carta» (y sus equivalentes en inglés) llevan a los iconos que las representan, aunque ningún nombre de icono las contenga. Los conceptos están en `Data/Concepts.lua` y se pueden ampliar sin tocar la lógica.

## [0.1.1] - 2026-11-12

Ajustes visuales (parche: solo cambia el aspecto).

### Cambiado
- Los iconos de la cuadrícula llevan el marco de los botones del juego y la selección usa el resplandor clásico en lugar de un cuadro plano.
- El botón «Best Icon» pasa a la barra inferior del selector de iconos de macros, dentro de la ventana, en lugar de quedar suelto debajo, con capa de dibujo propia para que la barra del selector no lo tape.
- El botón del selector copia la altura y la fila de Aceptar/Cancelar y se recoloca al abrir el selector.
- Tamaño de icono por defecto 40 (antes 36).
- El icono seleccionado se marca con el marco dorado y el resplandor del juego.

### Documentación
- README en inglés y español, con el estado real de las funciones, y notas de versión y descripción de CurseForge (`docs/RELEASE_NOTES.md`, `docs/CURSEFORGE.md`) en inglés y español.

### Corregido
- Rutas de textura del marco y del resplandor mal escapadas, que dejaban la selección invisible.

### Añadido
- `/bi debug`: imprime el estado del botón del selector de macros (visible, capa, posición) para diagnosticar.

## [0.1.0] - 2026-11-10

Primera versión. Probada en el cliente.

### Añadido
- Addon `BestIcon` para WoW Forever (Interface 16001): comandos `/besticon` y `/bi`.
- Catálogo de 27 714 iconos volcado del cliente (build 1.60.1.70862), separado de la lógica y generado con `tools/build_catalog.py`.
- Búsqueda instantánea bilingüe (español e inglés), sin tildes, con plurales, por ID y por ruta; alias en español para el 99 % de los iconos.
- Categorías ampliables (Campamentos, Comida y bebida, Armas, etc.).
- Interfaz con aspecto nativo: marco con retrato, caja de búsqueda, cuadrícula virtualizada propia (marcos y deslizador estándar), panel de información con ID y ruta copiables, ventana movible y redimensionable.
- Favoritos, historial (40), pestañas Todos/Favoritos/Historial y tamaño de icono ajustable, con persistencia.
- Integración con el selector de iconos de macros de Blizzard con instrucciones de respaldo.
- Localización esES/enUS con respaldo.
- Herramientas de desarrollo: `tools/BestIconDump` (volcado en el juego), `tools/build_catalog.py`, `tools/build_vocab.py`.
- Tests fuera del cliente (`tests/run_tests.py`, `tests/run_ui_smoke.py`).
- Licencia WNCL-TP-1.0 (titular WarCrafted) y `CREDITS.md` con el material de terceros (nombres de iconos del listfile comunitario, sin licencia declarada).
- Material de publicación en CurseForge (`docs/curseforge/`) y `tools/package.py` para generar el zip.
- Documentación: README, informe de investigación, arquitectura y cobertura de idiomas.
