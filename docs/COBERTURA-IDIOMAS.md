# Cobertura de idiomas del buscador

Medido con `tools/build_vocab.py` sobre el catálogo de 27 714 iconos (build 1.60.1.70862).

- Palabras distintas en las rutas: 5 222. Con 3 o más iconos: 2 092.
- Español (`Data/Aliases/esES_*.lua`): 1 755 palabras traducidas por ejecutor (≈84 % de las 2 092 más frecuentes) más un archivo manual (`esES_00_manual.lua`) con términos de camping y Forever.
- **Iconos con al menos una palabra traducida: 99,0 %** (27 424 de 27 714) antes del archivo manual.
- Sin traducir a propósito: nombres propios (zonas, personajes), palabras iguales en español (`color`, `racial`) y las que el traductor dudó.
- Inglés: sin alias; se busca por las propias palabras de la ruta.
- Pendiente: palabras con 1 o 2 iconos (≈3 100) y revisión humana de una muestra (TODO.md).
