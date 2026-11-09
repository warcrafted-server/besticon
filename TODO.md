# Pendiente

## Alta
- Probar en el cliente la interfaz completa (cuadrícula, pestañas, deslizador, panel) y corregir lo que falle; los avisos de API ausente salen una vez en el chat.
- Probar la integración con el selector de macros (`/macro`, Nuevo, Usar en macro) y reclasificarla en el README.
- Decidir la licencia del proyecto (con la Skill `licencias`) antes del primer push.
- Autorizar el push a `warcrafted-server/besticon` y, tras las pruebas, el tag `v0.1.0`.

## Media
- Resolver la licencia del listfile comunitario (wow-listfile, sin licencia visible) antes de distribuir los nombres de iconos.
- Revisar con una muestra humana los alias en español y traducir las palabras con 1 o 2 iconos (unas 3 100).
- Comprobar el rendimiento real: tiempo de indexado y memoria con 27 714 iconos en el cliente.
- Alias en inglés (sinónimos) si hace falta.

## Baja
- Enriquecer nombres con los localizados de objetos y hechizos del cliente esES (experimental).
- Botón de acceso desde la ventana de macros principal, además del selector.

## Descartado
- Asignar iconos con `C_Macro`: la API no lo permite (solo `RunMacroText`, `GetMacroName`, `GetSelectedMacroIcon`).
