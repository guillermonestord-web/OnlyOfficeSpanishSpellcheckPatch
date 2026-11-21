# ONLYOFFICE Desktop Editors: Autocorrector ortográfico automático para Español (en todas sus variantes)

Parche para que el Autocorrector ortográfico automático de **ONLYOFFICE Desktop Editors (Windows)** funcione con el idioma **Español (en todas sus variantes)**.

Sin este parche, por ejemplo al elegir «Español (Argentina)» o «Español (Uruguay)» o cualquier variante, el idioma aparece sin la marca **A** (corrector no disponible) y no se subraya ninguna palabra incorrecta, mientras que con «Español (España)» sí funciona. Y tambien existe el problema de que en caso de marcar todo el texto con un nuevo idioma al escribir nuevo texto se cambia y no respeta el idioma elegido.

Al usar el diccionario de Autocorrección Español (España) para todas las variantes se soluciona el problema y se pueden agregar manualmente palabras en sus respectivas variantes locales.

> Probado en ONLYOFFICE Desktop Editors **10.0.0.169** sobre Windows. En otras versiones puede funcionar o no: el script se detiene sin modificar nada si no reconoce el código que espera.

## Contenido

| Archivo | Qué hace |
|---|---|
| `onlyoffice_es_v4.bat` | Aplica el parche. |
| `onlyoffice_es_AR_revertir.bat` | Deshace el parche y restaura los archivos originales. |

## Uso

1. **Cerrá ONLYOFFICE.** El script también intenta cerrarlo.
2. Ejecutá `onlyoffice_es_v4.bat` con doble clic. Pide permisos de administrador porque modifica archivos dentro de `Program Files`.
3. Abrí ONLYOFFICE, elegí por ejemplo «Español (Argentina)» u otra variante como idioma del texto y escribí una palabra mal para comprobarlo.
4. Si hace falta, activá el corrector en *Archivo → Configuración avanzada*.

Si ONLYOFFICE no está en una ruta habitual (`Program Files`, `Program Files (x86)` o `%LOCALAPPDATA%\Programs`), pasá la carpeta como argumento:

```bat
onlyoffice_es_v4.bat "D:\Apps\ONLYOFFICE\DesktopEditors"
```

### Revertir

Ejecutá `onlyoffice_es_AR_revertir.bat`. Restaura cada `sdk-all-min.js` desde su copia `.bak_esAR` y no borra las copias.

### Después de actualizar ONLYOFFICE

Las actualizaciones reemplazan los archivos del SDK y el parche se pierde. Volvé a ejecutar `onlyoffice_es_v4.bat`.

## Código fuente relacionado: 

- [`desktop-sdk/ChromiumBasedEditors/lib/src/spellchecker.cpp`](https://github.com/ONLYOFFICE/desktop-sdk/blob/master/ChromiumBasedEditors/lib/src/spellchecker.cpp): `SetLanguage()` y `Init()`.
- [`core/Common/3dParty/hunspell/autogen/`](https://github.com/ONLYOFFICE/core/tree/master/Common/3dParty/hunspell/autogen): `generate.py` y `records.h`.

## Qué modifica el parche

No toca ningún `.exe` ni `.dll`. Modifica únicamente los archivos `editors/sdkjs/*/sdk-all-min.js` (word, cell, slide y los demás que encuentre) en dos puntos:

1. **Tabla de idiomas con corrector.** Por ejemplo agrega `11274 y :{hyphen:!0,name:"es_ES"}` a `spellcheckGetLanguages()`, para que «Español (Argentina)» figure con corrector (la **A**). Lo hace para todas las variantes de español y sus respectivos códigos. 
2. **Pedido al motor nativo.** En la llamada `AscDesktopEditor.SpellCheck(JSON.stringify(...))`, por ejemplo reemplaza `11274` por `3082` solo dentro de la lista `"usrLang"`. El motor corrige entonces con el diccionario `es_ES` que ya viene instalado. Lo hace para todas las variantes de español y sus respectivos códigos. 

Detalles de seguridad del script:

- Valida **todos** los archivos antes de escribir. Si alguno no se reconoce, cancela sin modificar nada.
- Guarda una copia `.bak_esAR` de cada archivo y **no la pisa** si ya existe, así que conserva el original aunque lo ejecutes varias veces.
- Relee cada archivo tras escribirlo y, si algo falla, restaura lo escrito en esa ejecución.
- Es idempotente: ejecutarlo dos veces no duplica el cambio.

## Requisitos

- Windows con ONLYOFFICE Desktop Editors instalado.
- Permisos de administrador (si ONLYOFFICE está en `Program Files`).
- PowerShell, que viene con Windows. Se usa solo para reemplazar texto dentro de los archivos minificados.
- El diccionario `dictionaries\es_ES` instalado de serie.

## Limitaciones

- El corrector usa el diccionario de **español de España**.
- Es una modificación de archivos de la instalación, no una función oficial de ONLYOFFICE.
- Si una versión futura trae el soporte de para las variantes en español de serie, este parche deja de ser necesario. En ese caso, ejecutá el BAT de revertir.
- Si ONLYOFFICE cambia el texto de su SDK, el script lo avisa y no modifica nada. Abrí un *issue* con el mensaje que muestra.

## Aviso

Este proyecto no está afiliado a ONLYOFFICE ni a Ascensio System SIA. Se entrega tal cual, sin garantías. Los parches modifican archivos de tu instalación: leé los scripts antes de ejecutarlos. Los diccionarios que usa vienen con ONLYOFFICE y conservan sus propias licencias.

## Licencia

MIT
