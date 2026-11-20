# Pendiente

## Media
- Memoria del índice: unos 50 MB medidos con `/bi debug`, pero esa cifra incluye basura aún sin recolectar. Medir primero lo retenido y reducir solo si es alto (plan A en `.agents/plans/futuro/futuro.PLAN.md`).
- Revisar con una muestra humana los alias en español y traducir las palabras con 1 o 2 iconos (unas 3 100), por tandas de 100 y empezando por las búsquedas reales que fallen (plan B).
- Mantener el catálogo al día: que el addon añada en tiempo de ejecución los IDs que lista el cliente y no estén en el catálogo (nombre `Icon_<ID>`), y un script de mantenimiento que detecte builds nuevas (plan C).
- Alias en inglés (sinónimos) si hace falta.
- Más conceptos de búsqueda por función (interrumpir, curar, provocar, huir, montura, mascota, comida, veneno, defensa, buff…): solo con búsquedas reales que fallen y probados en el juego, para no meter ruido.

## Baja
- Enriquecer nombres con los localizados de objetos y hechizos del cliente esES (experimental).
- Formato de copia `|Tid:0|t` para chat y macros: preguntar antes si alguien lo necesita.

## Descartado
- Asignar iconos con `C_Macro`: la API no lo permite (solo `RunMacroText`, `GetMacroName`, `GetSelectedMacroIcon`).
