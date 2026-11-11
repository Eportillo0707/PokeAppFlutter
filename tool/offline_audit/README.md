# Offline inventory measurements

These tools measure public PokéAPI data and media. They do not modify the app,
its preferences, its bundled assets, or its runtime dependencies.

Outputs are stored under ignored `build/offline-audit/`. Node 22 is used;
`measure.cjs` uses Node's experimental built-in SQLite API only for measurement.

1. Run `node tool/offline_audit/collect.cjs` with network access. Requests are
   limited to four concurrent workers. Successful resources are cached and reused.
2. Run `node tool/offline_audit/coverage.cjs` after collection completes.
3. Obtain Google's portable libwebp 1.6.0 Windows x64 tools from
   https://developers.google.com/speed/webp/docs/precompiled and extract under
   `build/offline-audit/tools/`.
4. Run `node tool/offline_audit/measure.cjs` to encode unique images without
   resizing in lossless/exact mode and lossy quality 85 with full-quality alpha.
5. Run `tool/offline_audit/preview.ps1` in PowerShell to create the visual sample.

Re-running collection reuses the existing snapshot; it is not a freshness check.
Use a separate copy/workspace for a new acquisition. The source can change during
collection; the report is a dated observational snapshot, not an atomic upstream
release. Repeated entries across URLs are deduplicated by SHA-256 for size results.

`raw-documents.sqlite` deliberately holds untrimmed JSON documents. Its size is a
measured conservative baseline, NOT the production schema or a proposed way to
query learnsets. Production database, indexes, installation footprint and startup
performance must be measured when implemented. Gzip figures are not Play Store
download sizes. Reports include missing upstream assets and failed requests
separately. Coverage checks only reference types included in this inventory.

The preview is a six-image visual sample, not exhaustive approval of lossy quality.
Lossless WebP is the conservative recommendation when preserving artwork exactly.
