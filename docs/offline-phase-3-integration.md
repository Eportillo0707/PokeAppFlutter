# Fase 3: catálogo local en la aplicación

La app abre `assets/offline_catalog/catalog.sqlite.gz` en la primera ejecución,
lo descomprime fuera del hilo de UI y conserva la copia editable como
`catalog-v1.sqlite` en el directorio privado de bases de datos. La pantalla
inicial permanece visible hasta que SQLite está listo. Las consultas de lista,
búsqueda, tipo, generación, detalle, evoluciones y movimientos usan esta copia.

Las imágenes normales y shiny, los gritos y los iconos de objetos evolutivos
están incluidos como assets. `tool/offline_catalog/package_assets.cjs` reproduce
el paquete a partir del catálogo validado de la fase 2. La app usa rutas por ID,
de modo que los Pokémon ya guardados en favoritos y equipos pueden mostrar sus
imágenes sin modificar el JSON de usuario. Las claves `favorite_pokemon` y
`pokemon_teams_v1` siguen en `SharedPreferences`.

Validación local: `flutter test` pasó, la prueba integral consultó el SQLite
incluido sin HTTP, `flutter analyze` pasó y `flutter build appbundle --release`
generó un AAB de 151,8 MB. También se inspeccionaron las entradas del AAB para
confirmar SQLite, arte normal, shiny, grito e icono de evolución.

Antes de publicar: instalar en un Android con red desactivada desde la primera
apertura y recorrer Pokédex, búsqueda, detalle, movimientos, favoritos y equipos;
repetir como actualización sobre una instalación que ya tenga favoritos y equipos.
La sincronización incremental de 7 y 30 días corresponde a la fase siguiente.

Correcciones tras la prueba en Android: el shiny se muestra al pulsar sin esperar
la medición de sus bordes, y los controles del encabezado reciben los toques por
encima del artwork. Las estadísticas recuperaron el orden de PokéAPI. Se detectó
que 92 gritos contenían MP3 aunque figuraban como `.ogg`; el empaquetado ahora
reconoce el formato por sus bytes y los publica con la extensión correcta. La
copia de prueba del teléfono reprodujo un grito OGG y uno MP3, mostró el shiny
de Charizard y conservó favoritos tras actualizarse.
