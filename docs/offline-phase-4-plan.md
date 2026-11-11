# Fase 4: actualizaciones del catálogo, solo offlinetest

Plan adoptado: `Pasted text.txt` adjunto por el usuario el 11 de noviembre de 2026.
Este documento registra la auditoría inicial del repositorio y las decisiones
necesarias antes de implementar el sistema. No autoriza publicar un release.

## Estado comprobado

- `AppDependencies.create()` abre `OfflineCatalogDatabase` y entrega un
  `OfflinePokemonRepository`. `OfflineCatalogDatabase.open()` descomprime el
  asset `catalog.sqlite.gz` en `catalog-v1.sqlite` solo si no existe, lo abre
  con `sqflite` y comprueba `schema_version = 1`.
- Los modelos y widgets construyen rutas `assets/offline_catalog/...` para
  arte normal, shiny y objetos. El grito local usa `AssetSource`. No hay un
  resolvedor de medios descargados ni una referencia activa versionada.
- Favoritos (`favorite_pokemon`) y equipos (`pokemon_teams_v1`) viven en
  `SharedPreferences`, separados de SQLite. Sus referencias usan ID Pokémon.
- `AppShell` tiene Pokédex, favoritos y equipos, cada uno con su navegador.
  No existe pantalla de Configuración que se pueda ampliar directamente.
- El generador de `tool/offline_catalog/` produce SQLite, medios y un manifiesto
  con hashes de bytes. `check_upstream.cjs` compara los nueve grupos de recursos
  por hashes de JSON bruto y guarda un snapshot. Todavía no calcula hashes
  semánticos ni genera paquetes de distribución.
- Android usa `com.emerson.pokeapp` para release y añade `.offlinetest` a debug
  y profile. El código Flutter es compartido: cualquier cambio de Dart debe
  quedar desactivado en release hasta una decisión explícita de producción.

## Riesgos que condicionan el diseño

1. El catálogo y los medios deben cambiar juntos. Una ruta directa de asset
   impediría mostrar archivos nuevos descargados.
2. Hay conexiones SQLite abiertas. No se puede reemplazar el archivo activo
   mientras una pantalla lo consulta; la activación requerirá cerrar/reabrir
   o aplicarse al siguiente inicio, con una referencia de versión atómica.
3. El snapshot de PokéAPI y sprites no es atómico. Antes de publicar habrá que
   verificar integridad de referencias y medios de un paquete completo.
4. Un SHA-256 público comprueba integridad, no autoría. El manifiesto de
   distribución necesitará una firma verificable con clave pública en la app.
5. La primera actualización puede necesitar el SQLite completo (18,14 MiB
   comprimido) más medios modificados. Habrá que medir espacio temporal y final.
6. No existe todavía una ubicación HTTPS ni un release de pruebas publicado.
   Las pruebas de red deben usar un servidor o artefactos locales hasta que el
   usuario apruebe una publicación externa.

## Orden de implementación

1. **Generador:** normalizar datos relevantes, comparar cambios semánticos,
   construir un snapshot nuevo e independiente y validar SQLite y medios.
2. **Paquete:** definir versión de catálogo/canal `offlinetest`, manifestar
   archivos y hashes, producir medios incrementales y firmar el manifiesto.
   La clave privada permanecerá fuera del repositorio y del APK.
3. **Detección:** integrar en Flutter un cliente de manifiesto firmado, con
   timeout, comprobación silenciosa cada 15 días desde la última exitosa y
   búsqueda manual. El inicio seguirá usando SQLite local de inmediato.
4. **Interfaz:** añadir acceso a Configuración sin alterar las tres pestañas
   actuales, estado de actualización y aviso aplazable no intrusivo.
5. **Instalación:** descargar en temporal, verificar tamaño/hash/firma,
   descomprimir con límites, validar SQLite y medios, activar una versión
   completa y conservar la anterior para recuperación. El resolvedor de medios
   elegirá archivos instalados y usará assets incluidos como respaldo.
6. **Pruebas:** cubrir el flujo con paquetes controlados y fallos inducidos;
   después validar en Android `offlinetest`, incluida conservación de datos.
7. **Evaluación:** documentar resultados y riesgos antes de considerar
   cualquier cambio para la variante de producción.

## Criterios de avance

- Ninguna fase publica releases ni modifica producción por sí sola.
- Cada archivo de código nuevo o modificado debe tener como máximo 100 líneas.
- No se avanza a detección real sin paquete versionado, firma y URL de prueba.
- No se activa una actualización si falta un medio o falla SQLite o su firma.
- Se registran por separado pruebas automáticas ejecutadas y pruebas manuales
  pendientes; favoritos y equipos deben sobrevivir a éxito y recuperación.

## Avance actual

- La rama local `codex/offlinetest-phase4` separa el trabajo de `main`.
  Todavía no se ha identificado con certeza el commit del AAB de Play Store;
  por tanto no se creó una rama de producción basada en una suposición.
- La comparación usa hashes canónicos de JSON para distinguir cambios de
  contenido frente a cambios de espacios u orden de claves. Los hashes de
  bytes del manifiesto anterior se verifican contra el snapshot base.
- `package_release.cjs` prepara un SQLite comprimido y solo medios cuyos
  archivos no están en el manifiesto base. Verifica SHA-256, exige cambios
  semánticos y firma el manifiesto con una clave Ed25519 externa. No se ha
  creado una clave real ni un paquete público.
- Se ejecutaron tres pruebas locales: hash semántico, clasificación de cambios
  y paquete firmado. Las tres pasaron. Los archivos de código modificados
  tienen 100 líneas o menos.
- **Fase 2 incompleta:** falta enlazar el snapshot nuevo con una adquisición
  de medios consistente, generar un catálogo SQLite nuevo, validar medios
  incrementales frente al catálogo instalado y definir la clave pública de
  pruebas. No hay aún GitHub Actions.

## Detección en Flutter iniciada

- `CatalogManifestClient` descarga manifiesto y firma con timeout, verifica
  Ed25519 y después valida canal, esquema, versiones y rutas de archivos.
  La clave pública se inyecta en la compilación de pruebas; no hay una clave
  privada ni un token dentro de Flutter.
- `CatalogUpdateChecker` registra la última comprobación exitosa y limita la
  automática a una cada 15 días. Tras un fallo, espera una hora antes de otro
  intento automático; la búsqueda manual puede ejecutarse en cualquier momento.
- `AppShell` inicia una comprobación no bloqueante solo en debug/profile y solo
  si se compila con `POKEAPP_CATALOG_MANIFEST_URL` y
  `POKEAPP_CATALOG_PUBLIC_KEY` (32 bytes Ed25519 codificados en base64).
  En release no se crea el servicio. Sin esos valores tampoco hay solicitudes.
- La detección inicial se completó con un aviso en Ajustes. La instalación
  posterior lee la versión activa del almacenamiento local y limita la
  descarga a paquetes de solo SQLite. No se debe presentar esta etapa como
  actualización funcional completa para catálogos con medios nuevos.
- `flutter analyze --no-pub` no encontró problemas y `flutter test --no-pub`
  pasó 58 pruebas, incluidas firma válida, firma alterada, intervalo, búsqueda
  manual y recuperación tras una consulta fallida. Falta validar en teléfono
  con un manifiesto firmado de prueba y comprobar el flujo de interfaz.
- En debug/profile, `AppShell` muestra una pestaña Ajustes/Settings con la
  versión base, la última comprobación, el estado y búsqueda manual. La pestaña
  no existe en release. Con URL o clave de pruebas ausentes, el botón queda
  deshabilitado y no hay solicitudes. La descarga se añadió después solo para
  actualizaciones de SQLite sin cambios de medios.

## Instalación local de SQLite iniciada

- Los assets del paquete tienen nombres planos compatibles con GitHub Releases;
  el manifiesto firmado conserva rutas lógicas seguras. Los archivos se
  descargan por streaming, se limitan por tamaño y se verifican con SHA-256.
  Los archivos válidos se reutilizan y los `.part` se borran tras un fallo.
- El instalador descomprime en un directorio de versión independiente, valida
  integridad SQLite, claves foráneas, esquema y asignación de medios, y solo
  después escribe la referencia activa. La base abierta no se reemplaza; la
  nueva versión se usa al siguiente inicio. El seed y la versión anterior
  siguen disponibles para recuperación.
- Por ahora se acepta **solo una actualización de SQLite sin cambios de
  medios**. Si el paquete añade imágenes, gritos o íconos, el botón no aparece
  y el instalador rechaza el paquete. Falta el resolvedor de medios descargados.
- Una prueba local de extremo a extremo verificó firma, descarga, instalación,
  reapertura y conservación de las claves de favoritos y equipos. También se
  probó rechazo de SQLite incompatible, hash erróneo y medios no instalados.
- No se ha probado en teléfono: ADB no detectó dispositivos conectados.
  Tampoco se ha creado un Release ni una clave de firma persistente.
- La compilación profile sin URL ni clave de pruebas no consulta la red. Para
  probar el flujo en un dispositivo harán falta un manifiesto de test firmado,
  su clave pública en la compilación y un servidor accesible al teléfono.
- `flutter build apk --profile --no-pub` generó una APK de 197,7 MB; `aapt`
  confirmó el identificador `com.emerson.pokeapp.offlinetest`. No se instaló.
