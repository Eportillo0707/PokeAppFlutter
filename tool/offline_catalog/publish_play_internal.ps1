param(
  [string]$CatalogDirectory = 'build/play-internal-1.1.1-10/catalog'
)

$ErrorActionPreference = 'Stop'
$gh = 'C:\Program Files\GitHub CLI\gh.exe'
$repo = 'Eportillo0707/PokeAppCatalog'
$tag = 'catalog-play-internal-2026.11.13.5'
$dir = (Resolve-Path -LiteralPath $CatalogDirectory).Path
$manifest = Get-Content (Join-Path $dir 'update-manifest.json') -Raw |
  ConvertFrom-Json
if ($manifest.catalogVersion -ne '2026.11.13.5' -or
    $manifest.baseCatalogVersion -ne '2026.11.05') {
  throw 'El catálogo no corresponde a la prueba interna.'
}
$files = @(Get-ChildItem -LiteralPath $dir -File)
if ($files.Count -ne $manifest.files.Count + 2) {
  throw 'Faltan archivos del catálogo.'
}
foreach ($entry in $manifest.files) {
  $path = Join-Path $dir $entry.asset
  if (-not (Test-Path -LiteralPath $path)) { throw "Falta $($entry.asset)" }
  $item = Get-Item -LiteralPath $path
  $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
  if ($item.Length -ne $entry.bytes -or
      $hash -ine $entry.sha256) { throw "Archivo inválido: $($entry.asset)" }
}
$existing = & $gh release view $tag --repo $repo --json assets,isDraft `
  2>$null | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
  & $gh release create $tag --repo $repo --draft --title $tag `
    --notes 'Catálogo firmado para la prueba interna de PokeApp 1.1.1 (10).'
  if ($LASTEXITCODE -ne 0) { throw 'No se creó el Release borrador.' }
  $uploaded = @()
} else {
  if (-not $existing.isDraft) { throw 'El Release ya está publicado.' }
  $uploaded = @($existing.assets | ForEach-Object name)
}
$pending = @($files | Where-Object Name -NotIn $uploaded)
for ($i = 0; $i -lt $pending.Count; $i += 25) {
  $batch = @($pending[$i..([Math]::Min($i + 24, $pending.Count - 1))] |
    ForEach-Object FullName)
  & $gh release upload $tag @batch --repo $repo
  if ($LASTEXITCODE -ne 0) { throw "Falló la subida desde $i." }
}
$release = & $gh release view $tag --repo $repo --json assets,isDraft |
  ConvertFrom-Json
$local = @($files | ForEach-Object Name | Sort-Object)
$remote = @($release.assets | ForEach-Object name | Sort-Object)
if (-not $release.isDraft -or @(Compare-Object $local $remote).Count -ne 0) {
  throw 'El Release no coincide con el catálogo local.'
}
& $gh release edit $tag --repo $repo --draft=false --latest=false
if ($LASTEXITCODE -ne 0) { throw 'El Release sigue en borrador.' }
Write-Output "Publicado $tag con $($files.Count) archivos."
