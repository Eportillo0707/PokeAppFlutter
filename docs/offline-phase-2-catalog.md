# Phase 2 catalog result

Snapshot source: PokéAPI and PokeAPI/sprites acquired on 2026-11-05. Build tooling
uses Node's built-in SQLite API and the already measured WebP quality 85 media.
No Flutter dependency or runtime code was changed.

## Generated package

| Component | Count or size |
|---|---:|
| Pokémon and forms | 1,351 |
| Species | 1,025 |
| Moves | 937 |
| Games/version groups | 32 |
| Machine mappings | 2,372 |
| Pokémon learning records | 638,321 |
| Copied unique media files | 3,957 |
| SQLite catalog | 63,320,064 bytes (60.39 MiB) |
| Gzip catalog | 19,017,371 bytes (18.14 MiB) |
| Copied media | 81,763,129 bytes (77.98 MiB) |

The compressed catalog plus media is 96.11 MiB. This is package content only:
it excludes Flutter/Android binaries and does not represent Play Store download
size. If the compressed seed and the expanded working database both remain on
device, both occupy storage; runtime packaging must decide how to avoid an
unnecessary duplicate after first installation.

The catalog has 6,661 source hashes and four explicit artwork fallbacks.
Unavailable translations and shiny art remain marked as absent, so they cannot
be confused with failed downloads.

## Validation

`node tool/offline_catalog/validate.cjs` verified 3,959 packaged files (media,
SQLite and gzip copy), their hashes and lengths, SQLite integrity, foreign keys,
counts, media references, partial name search, localized description and move
queries by game. The first run had zero broken media references. A second build
from the same cached corpus produced the identical manifest SHA-256
`429069ebbeb0273bf4260fa67698fb86bce9d55008de9d769773dbd9a5af9bb5`,
including identical hashes for the SQLite file and every media file.

The package and complete manifest are under ignored
`build/offline-catalog/catalog-2026-11-05-final/`. The generator and validation commands
are documented in `tool/offline_catalog/README.md`.

The next phase will integrate local reads and assets into the Flutter app, test
first launch in airplane mode, and preserve the existing `SharedPreferences`
keys for favorites and teams. The manifest is an initial distribution artifact;
incremental publishing and background scheduling remain future work.
