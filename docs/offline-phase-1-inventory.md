# Fase 1: inventario y medición offline

Fecha: 2026-11-05. Alcance: estado actual del código; sin cambios de comportamiento ni dependencias.

## Línea base verificada

| Elemento | Estado actual |
|---|---|
| Paquete Android release existente | 54,126,134 bytes (51.62 MiB), generado el 2026-10-31 |
| Recursos en `assets/` | 27 archivos, 1,442,636 bytes (1.38 MiB) |
| Fuentes / iconos / splash | 0.95 / 0.24 / 0.19 MiB |
| Catálogo Pokémon incluido | Ninguno |
| Imágenes de Pokémon incluidas | Ninguna |
| Base de datos local | Ninguna |
| Persistencia de usuario | `SharedPreferences`: `favorite_pokemon`, `pokemon_teams_v1` |

El tamaño del AAB no es el tamaño de descarga por dispositivo ni el espacio instalado. Esta línea base sirve para comparar futuras compilaciones con el mismo método.

## Inventario funcional y datos necesarios

| Función | Origen actual | Datos necesarios para funcionar offline |
|---|---|---|
| Pokédex paginada | `/pokemon`, luego `/pokemon/{name}` por fila | ID, nombre, tipos, orden y formas mostradas |
| Búsqueda parcial | `/pokemon/{query}` y `/pokemon?limit=1302` como respaldo | Índice completo de nombres y alias; tipos y miniaturas |
| Filtro por tipo | `/type/{type}`, luego detalles individuales | Relación Pokémon–tipo, incluyendo formas |
| Filtro por generación | Rangos fijos 1–1025 y detalles individuales | Relación especie–generación; starters |
| Detalle | Pokémon, especie, cadena evolutiva, habilidades y formas | Estadísticas, tamaño/peso, descripción localizada, habilidades, evoluciones, métodos, mega/regional/Gigamax |
| Movimientos | Learnsets dentro de `/pokemon/{name}` | Pokémon–movimiento–juego–método–nivel |
| Ficha de ataque | `/move/{name}` y `/version-group/{game}` | Nombre y efecto localizados, categoría, tipo, potencia, precisión, PP, generación y valores históricos |
| MT/MO/DT | URLs de máquinas referidas por movimientos | Relación movimiento–juego–máquina–objeto/código |
| Favoritos | JSON local | Mantener clave, formato e IDs actuales |
| Equipos y balance | JSON local y tabla de efectividad en código | Mantener clave, formato, miembros, tipos y tabla de efectividad |
| Grito | URL de `cries` de PokéAPI | Audio local de cada Pokémon/forma donde exista |

`PokemonRepositoryImpl` y `MoveMachineSource` son los puntos principales que convierten consultas de UI en peticiones de red. `AppDependencies` solo construye el repositorio remoto. La caché de `MoveMachineSource` vive en memoria y se pierde al cerrar la app.

## Inventario de medios remotos

| Recurso | Dónde se usa | Origen |
|---|---|---|
| Arte oficial normal | Lista, búsqueda, favoritos, equipos, detalle, evoluciones y starters | GitHub `PokeAPI/sprites/.../official-artwork/{id}.png` |
| Arte shiny | Detalle | `sprites.other.official-artwork.front_shiny` de PokéAPI |
| Imágenes de objetos evolutivos | Métodos de evolución | GitHub `PokeAPI/sprites/.../items/{name}.png` |
| Gritos | Detalle | URL `cries.latest` o `cries.legacy` de PokéAPI |

Hay usos directos de `Image.network`, `NetworkImage`, precarga de imágenes de red y `UrlSource`. Una capa de datos local por sí sola no elimina esas dependencias: todos los consumidores deberán resolver medios locales. Los iconos de tipos, categorías, splash y tipografías ya están incluidos.

## Límites y supuestos encontrados

- `getAllPokemonNames()` fija `limit=1302`. La consulta pública de PokéAPI devolvió `count=1351` el 2026-11-05: la búsqueda de respaldo ya puede omitir al menos 49 entradas. Debe sustituirse por paginación basada en `count`/`next` o por el catálogo local.
- `pokemonGenerations` termina en ID 1025 y usa rangos. Los nuevos Pokémon y formas requieren relaciones de generación, no ampliar un rango a mano.
- `PokemonItem`, `PokemonInfo` y `PokemonSpecies` construyen directamente URLs de imágenes. La transición necesita una referencia de medio independiente del transporte.
- El detalle reúne varias entidades y tolera fallos remotos devolviendo `null` o listas vacías. El generador del catálogo deberá distinguir dato legítimamente ausente de descarga fallida.
- Las traducciones disponibles en PokéAPI no son uniformes; el catálogo debe registrar el idioma de respaldo que se presenta.
- Las formas pueden compartir especie y diferir en ID de Pokémon, imagen, tipos o movimientos. El inventario debe cubrir ambas identidades.
- “Completamente offline” incluye sonido si el botón de grito sigue visible y activo.

## Medición completada: corpus del 2026-11-05

Se reunieron 6.661 registros mediante paginación completa, con cuatro trabajadores,
caché de descargas exitosas y reintentos. Se descargaron los recursos que utiliza
la UI, sin instalar dependencias de Flutter ni modificar la aplicación.

| Entidad | Registros |
|---|---:|
| Pokémon y formas | 1.351 |
| Especies | 1.025 |
| Movimientos | 937 |
| Habilidades | 374 |
| Cadenas evolutivas | 540 |
| Grupos de versiones/juegos | 32 |
| Generaciones | 9 |
| Tipos | 21 |
| Máquinas | 2.372 |
| Relaciones de aprendizaje en los Pokémon | 638.321 |

Los endpoints completos contienen entradas que podrían no ser utilizadas por la UI.
La fase 2 podrá eliminar contenido no requerido, manteniendo todas las dependencias.
Los JSON originales suman 221,90 MiB; agrupados por entidad y comprimidos con gzip,
11,62 MiB. No se ha convertido esta cifra en una promesa de tamaño instalado.

### Medios y compresión

| Recurso | Archivos descargados | Archivos únicos por contenido |
|---|---:|---:|
| Arte normal | 1.347 | 1.318 |
| Arte shiny | 1.340 | 1.327 |
| Iconos de objetos evolutivos | 50 | 50 |
| Gritos | 1.351 | 1.275 |

La comparación se ejecutó sobre las 2.695 imágenes únicas, sin reducir dimensiones,
con libwebp 1.6.0 oficial de Google. Se mantuvo el canal alfa. La variante sin
pérdida utilizó `-lossless -exact -m 4`; la variante con pérdida,
`-q 85 -alpha_q 100 -m 4`.

| Formato de imágenes únicas | Tamaño | Reducción frente a PNG |
|---|---:|---:|
| PNG original | 339,10 MiB | — |
| WebP sin pérdida | 218,56 MiB | 35,55 % |
| WebP calidad 85 | 59,69 MiB | 82,40 % |

Los audios únicos originales ocupan 18,58 MiB. No se recomprimieron.
Se inspeccionó visualmente una muestra de seis imágenes: Bulbasaur, Charizard shiny,
Mega Rayquaza, Charizard Gigamax, Bruxish y Gardevoir shiny, sobre fondo oscuro.
No se observaron diferencias importantes al tamaño de la muestra; esto no es una
verificación visual exhaustiva ni a todas las escalas/dispositivos.

### Contenedor SQLite de medición

Se creó únicamente en la carpeta de trabajo un contenedor SQLite de documentos
JSON completos: 6.661 filas, 225,21 MiB, o 12,38 MiB comprimido con gzip.
`PRAGMA integrity_check` devolvió `ok`. Este contenedor NO es el esquema relacional
de producción y NO está integrado en la aplicación.

Como escenario aritmético de referencia, la base de medición comprimida + los
audios únicos + las imágenes ocuparían 90,65 MiB con calidad 85 o 249,52 MiB sin
pérdida. No incluye binarios de la aplicación ni sobrecostes del paquete; no es
una medición de descarga de Play Store. La base descomprimida y su copia inicial
también consumen almacenamiento. El esquema final, índices, AAB por dispositivo,
espacio de instalación y primer arranque se medirán cuando exista la integración.

## Cobertura y ausencias verificadas

- Cero peticiones agotaron sus reintentos; los fallos de red registrados son cero.
- Cero referencias faltantes entre los nueve tipos de entidades descargadas.
  No se validaron recursos ajenos al alcance (p. ej., concursos o encuentros).
- Cuatro URL de arte normal devolvieron 404: `koraidon-limited-build`,
  `koraidon-swimming-build`, `miraidon-low-power-mode` y `miraidon-aquatic-mode`.
- Once entradas no proporcionan URL shiny. La lista completa está en el resumen JSON.
- 127 de 1.025 especies no tienen texto descriptivo en español; todas tienen inglés.
- 111 de 937 movimientos no tienen descripción/efecto en español; cinco tampoco
  tienen esos textos en inglés. Esta medición es global por idioma, no garantiza
  cobertura para cada juego individual.
- 107 de 374 habilidades no tienen esos textos en español y 60 no los tienen en
  inglés; el total incluye entradas del endpoint que podrían no usar los Pokémon
  que muestra la app. La selección final debe validar las habilidades referenciadas.

Las ausencias del origen requieren una regla de respaldo local. No se deben
considerar errores de conexión ni rellenarse con datos inventados. En las cuatro
formas sin imagen podrá usarse una imagen de especie claramente definida como
respaldo; no se debe presentar como arte propio de esa forma.

## Decisión y cierre de fase 1

Inventario y medición del corpus completados. Se recomienda WebP calidad 85 como
candidato de tamaño, sujeto a aprobación visual en la UI real; WebP sin pérdida
queda como alternativa si se exige preservación exacta. Mantener audios originales
deduplicados. Diseñar en fase 2 un catálogo relacional con solo datos necesarios y
textos español/inglés, evitando empaquetar el contenedor bruto de medición.

No hay todavía un paquete offline, una migración ni un sincronizador. Esas son
fases posteriores. Los datos de favoritos y equipos no se tocaron.

## Evidencia y reproducción

- Resumen persistente: `docs/offline-phase-1-measurements.json`.
- Herramientas y procedimiento: `tool/offline_audit/README.md`.
- Descargas: `build/offline-audit/json/` y `build/offline-audit/media/`.
- Comparación visual: `build/offline-audit/comparison.png`.
- Informes completos: `summary.json`, `coverage.json`, `compression.json`,
  `database-measurement.json` y `media-manifest.json`, dentro de `build/offline-audit/`.
- Fuentes: https://pokeapi.co/api/v2/ y https://developers.google.com/speed/webp/docs/precompiled

`build/` está excluido de Git y puede borrarse con una limpieza de Flutter. Los
resúmenes y herramientas se conservan fuera de esa carpeta para reproducir la
medición. El corpus es una observación fechada: PokéAPI y GitHub no ofrecen una
instantánea transaccional conjunta durante estas descargas.

## Prueba de aceptación offline propuesta

Instalar desde cero, activar modo avión antes de abrir, y recorrer: Pokédex, búsqueda parcial, tipo, generación, ficha, evolución, formas, shiny, habilidades, movimientos por juego y método, descripción y máquinas, audio, favoritos, creación/edición de varios equipos y balance defensivo. Repetir tras cerrar la app. Registrar cualquier petición remota, imagen vacía, error o bloqueo de UI. Esta prueba se ejecutará cuando exista un catálogo local; el código actual no la supera.
