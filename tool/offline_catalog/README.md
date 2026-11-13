# Phase 2: build the offline catalog

Run after [phase 1 acquisition](../offline_audit/README.md). Node 22 or later is
required. This is build tooling only; the Flutter app has no new dependencies yet.

```powershell
node tool/offline_catalog/build.cjs
node tool/offline_catalog/validate.cjs
```

The default output is `build/offline-catalog/catalog-2026-11-05-final/`. Pass another
output directory as the first argument to either command. The generator refuses
to overwrite an existing directory. Output remains ignored by Git. Its `media/`
directory contains content-addressed WebP quality 85 artwork and deduplicated
original audio. `catalog.sqlite` is the relational catalog; `catalog.sqlite.gz`
is a compressed copy. `manifest.json` lists file sizes, SHA-256 digests, source
record hashes and the dated source snapshot. `manifest.sha256` covers the manifest.

The database contains species, Pokémon and forms, types, stats, abilities,
evolution edges and conditions, moves, names and descriptions in English and
Spanish, historical move values, game groups, methods/levels, machine mappings,
media references and source hashes. Missing localized text remains absent, so a
reader can apply the requested-language → English fallback and retain the real
source language. Four upstream artwork 404s use the default art of their species
with `normal_fallback=1`. Missing shiny art remains null and should use normal art
when requested, as the current UI does.

The source hashes are SHA-256 digests of the acquired JSON bytes. They are useful
for detecting changed resources in a later synchronization design, but can also
flag harmless upstream formatting changes. The incremental publisher will need
normalized, schema-aware hashes before distributing deltas. The catalog snapshot
is not atomic across PokéAPI and GitHub; the validation command checks all copied
files, database integrity, foreign keys, row counts and sample queries.

The generator does not modify app code, user preferences, teams or favorites.
The compressed file and media are bundled into the app. `offlinetest` can also
install signed updates and resolve downloaded media after restart. The SQLite
schema is version 1; future migrations and package changes need versioning.

## Check PokéAPI for changes

Run `node tool/offline_catalog/check_upstream.cjs` to compare all nine source
resource groups with the manifest of the bundled catalog. It makes at most four
concurrent requests, retries transient failures, writes a complete fresh JSON
snapshot under `build/offline-catalog/upstream-snapshot/json/`, and writes
`build/offline-catalog/upstream-check.json` with added, changed, removed and
reformatted IDs. Canonical JSON hashes ignore whitespace and object key order.
The check fails rather than reporting “no changes” when a request fails.
Run `node --test tool/offline_catalog/check_upstream.test.cjs` for its local test.

This is a developer-side validation step. Do not run this full scan on phones.
The app still needs a published HTTPS catalog manifest and media package for
remote updates. `package_release.cjs` can prepare a signed test package
from a separately built and validated new catalog. It requires an external
Ed25519 private key path in `POKEAPP_SIGNING_KEY`, a changed report, a base
manifest, a new catalog directory, output directory and two catalog versions.
It refuses to overwrite an output directory or package unchanged data. Never
commit the private key to this repository.
Release media files use flat `media-<sha256>.<extension>` asset names; their
logical `media/<sha256>.<extension>` paths remain in the signed manifest.

## Local device test

`node tool/offline_catalog/make_test_release.cjs` creates an ignored, SQLite-only
fixture under `build/offline-test-release/`. It changes only a test metadata row
in a copy of the catalog. The signing key is ephemeral; only its public key is
written. `node tool/offline_catalog/serve_test_release.cjs` serves the three
fixture assets on localhost port 8765. Use `adb reverse tcp:8765 tcp:8765` and
compile the **profile** variant with `POKEAPP_CATALOG_MANIFEST_URL` pointing to
`http://127.0.0.1:8765/update-manifest.json` and
`POKEAPP_CATALOG_PUBLIC_KEY` set to the fixture's base64 public key. Cleartext
traffic is enabled only in the profile manifest for this USB test. The server
and reverse tunnel must be running for manual update checks to work.

`node tool/offline_catalog/make_test_media_release.cjs` creates a second,
ignored fixture based on the SQLite-only USB test. It adds a content-addressed
WebP with unchanged visible artwork and signs a `2026.11.13.2` manifest whose
base is `2026.11.11.1`. Pass `build/offline-test-media-release` to the local
server to test an update containing media. The app verifies every referenced
media file before activation and uses its downloaded copy after restart.

The prepared GitHub Actions workflow is in `.github/workflows/`. It requires a
verified baseline archive with `manifest.json` and `json/` at its root, plus
repository variables `CATALOG_BASELINE_URL` and `CATALOG_BASELINE_SHA256`.
Manual signed packaging also needs the `CATALOG_SIGNING_KEY_PEM` secret and
`base_version` / `version` inputs. The workflow uploads an Actions artifact;
it does not publish a release. The baseline archive currently exists only at
`build/offline-catalog/baseline-2026-11-05.tar.gz` and is ignored by Git.
