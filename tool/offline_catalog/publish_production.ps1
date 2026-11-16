param([Parameter(Mandatory = $true)][string]$CatalogDirectory)

$ErrorActionPreference = 'Stop'
$repo = 'Eportillo0707/PokeAppCatalog'
$dir = (Resolve-Path -LiteralPath $CatalogDirectory).Path
$summary = node tool/offline_catalog/verify_release.cjs $dir | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Falló la verificación del catálogo.' }
$tag = "catalog-production-$($summary.version)"
$files = @(Get-ChildItem -LiteralPath $dir -File)
$existing = gh release view $tag --repo $repo --json assets,isDraft `
  2>$null | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
  gh release create $tag --repo $repo --draft --title $tag `
    --notes 'Catálogo de producción firmado y aprobado manualmente.'
  if ($LASTEXITCODE -ne 0) { throw 'No se creó el borrador.' }
  $uploaded = @()
} else {
  if (-not $existing.isDraft) { throw 'El Release ya está publicado.' }
  $uploaded = @($existing.assets | ForEach-Object name)
}
$pending = @($files | Where-Object Name -NotIn $uploaded)
for ($i = 0; $i -lt $pending.Count; $i += 25) {
  $batch = @($pending[$i..([Math]::Min($i + 24, $pending.Count - 1))] |
    ForEach-Object FullName)
  gh release upload $tag @batch --repo $repo
  if ($LASTEXITCODE -ne 0) { throw "Falló la subida desde $i." }
}
$release = gh release view $tag --repo $repo --json assets,isDraft |
  ConvertFrom-Json
$localNames = @($files | ForEach-Object Name | Sort-Object)
$remoteNames = @($release.assets | ForEach-Object name | Sort-Object)
if (-not $release.isDraft -or
    @(Compare-Object $localNames $remoteNames).Count -ne 0) {
  throw 'Los archivos remotos no coinciden con el paquete verificado.'
}
foreach ($asset in $release.assets) {
  $path = Join-Path $dir $asset.name
  $digest = 'sha256:' + (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower()
  if ($asset.size -ne (Get-Item -LiteralPath $path).Length -or
      $asset.digest -ne $digest) {
    throw "El archivo remoto no coincide: $($asset.name)"
  }
}
gh release edit $tag --repo $repo --draft=false --latest
if ($LASTEXITCODE -ne 0) { throw 'No se publicó el Release.' }
Write-Output "Publicado $tag con $($files.Count) archivos."
