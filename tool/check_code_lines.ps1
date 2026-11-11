$ErrorActionPreference = 'Stop'
$paths = @(
    git diff --name-only --diff-filter=ACMR -- '*.dart'
    git diff --cached --name-only --diff-filter=ACMR -- '*.dart'
    git ls-files --others --exclude-standard -- '*.dart'
) | Sort-Object -Unique

$violations = @()
foreach ($path in $paths) {
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $count = [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $path)).Length
    if ($count -gt 100) {
        $violations += '{0}: {1} lines' -f $path, $count
    }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}
Write-Output 'All changed Dart files are at most 100 lines.'
