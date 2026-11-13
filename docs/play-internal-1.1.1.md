# Prueba interna de actualización desde Play Store

## Archivos preparados

- AAB: `build/play-internal-1.1.1-10/PokeApp-internal-1.1.1-10.aab`.
  Identificador `com.emerson.pokeapp`, versión `1.1.1 (10)`, firmado con la
  clave de subida configurada en el proyecto. SHA-256:
  `30F051278328830E3DD6016B155D46A4248D32A9EA887445E7CDD87D55C1810A`.
- Catálogo: `build/play-internal-1.1.1-10/catalog/`, firmado y basado en
  `2026.11.05`, la versión inicial que incluye el AAB. El manifiesto contiene
  `catalogVersion: 2026.11.13.5`. La app usa la URL fija del Release
  `catalog-play-internal-2026.11.13.5`, independiente de `/releases/latest/`.

## Publicación que harás tú

1. Desde la raíz del proyecto, ejecuta en PowerShell
   `./tool/offline_catalog/publish_play_internal.ps1`. El script comprueba los
   archivos, crea un Release borrador en `Eportillo0707/PokeAppCatalog`, sube
   todos los assets, confirma que están completos y entonces lo publica. Usa
   GitHub CLI ya autenticado. Si PowerShell bloquea el script, ejecútalo con
   `powershell -ExecutionPolicy Bypass -File
   tool/offline_catalog/publish_play_internal.ps1`.
2. En Play Console abre **PokeApp → Pruebas → Pruebas internas**. Añade solo tu
   cuenta Google a la lista de testers y crea una versión nueva con el AAB de
   arriba. Publícala únicamente en el canal interno. Si Play Console indica
   que el código 10 ya está usado, detente: habrá que generar otro AAB con un
   código superior.
3. Mantén instalada la versión original de Play Store en el teléfono. Abre el
   enlace de invitación del canal interno con la misma cuenta Google, acepta
   la prueba y actualiza PokeApp desde Play Store. No desinstales la app: así
   validas la actualización encima de `1.1.0 (9)` y la conservación de datos.
4. Comprueba que siguen tus favoritos y equipos. En Ajustes de PokeApp usa
   **Check for updates**; debe ofrecer `2026.11.13.5`. Instálala, reinicia la
   app y comprueba la Pokédex. Envíame una captura o el resultado para revisar
   cualquier fallo antes de considerar el canal de producción.

El AAB interno activa el mecanismo del catálogo mediante una opción de
compilación. Una compilación release normal sin esa opción conserva el
comportamiento anterior. Ningún archivo de este paquete se ha subido a Play
Console ni se ha publicado en producción.
