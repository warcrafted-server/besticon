# Changelog

Formato [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/), versionado SemVer.

## [Sin publicar]

Versión de trabajo 0.1.0 (la del TOC). Pendiente de probar la interfaz en el cliente antes de etiquetarla.

### Añadido
- Addon `BestIcon` para WoW Forever (Interface 16001): comandos `/besticon` y `/bi`.
- Catálogo de 27 714 iconos volcado del cliente (build 1.60.1.70862), separado de la lógica y generado con `tools/build_catalog.py`.
- Búsqueda instantánea bilingüe (español e inglés), sin tildes, con plurales, por ID y por ruta; alias en español para el 99 % de los iconos.
- Categorías ampliables (Campamentos, Comida y bebida, Armas, etc.).
- Interfaz con aspecto nativo: marco con retrato, caja de búsqueda, cuadrícula virtualizada propia (marcos y deslizador estándar), panel de información con ID y ruta copiables, ventana movible y redimensionable.
- Favoritos, historial (40), pestañas Todos/Favoritos/Historial y tamaño de icono ajustable, con persistencia.
- Integración con el selector de iconos de macros de Blizzard (experimental) con instrucciones de respaldo.
- Localización esES/enUS con respaldo.
- Herramientas de desarrollo: `tools/BestIconDump` (volcado en el juego), `tools/build_catalog.py`, `tools/build_vocab.py`.
- Tests fuera del cliente (`tests/run_tests.py`, `tests/run_ui_smoke.py`).
- Documentación: README, informe de investigación, arquitectura y cobertura de idiomas.
