Add-Type -AssemblyName System.Drawing
$root = Join-Path (Get-Location) 'build/offline-audit'
$manifest = Get-Content (Join-Path $root 'media-manifest.json') -Raw | ConvertFrom-Json
$decoder = Join-Path $root 'tools/libwebp-1.6.0-windows-x64/bin/dwebp.exe'
$samples = @(
  @{Name='bulbasaur';Kind='normal'},
  @{Name='charizard';Kind='shiny'},
  @{Name='rayquaza-mega';Kind='normal'},
  @{Name='charizard-gmax';Kind='normal'},
  @{Name='bruxish';Kind='normal'},
  @{Name='gardevoir';Kind='shiny'}
)
$canvas = New-Object System.Drawing.Bitmap 900,1500
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
$graphics.Clear([System.Drawing.Color]::FromArgb(18,20,34))
$font = New-Object System.Drawing.Font 'Arial',12
$brush = [System.Drawing.Brushes]::White
$modes = @('Original PNG','WebP lossless','WebP q85')
for($col=0;$col -lt 3;$col++) { $graphics.DrawString($modes[$col],$font,$brush,($col*300+25),10) }
for($row=0;$row -lt $samples.Count;$row++) {
  $s=$samples[$row]
  $m=$manifest | Where-Object {$_.kind -eq $s.Kind -and $_.owners -contains $s.Name} | Select-Object -First 1
  for($col=0;$col -lt 3;$col++) {
    if($col -eq 0) { $inputFile=Join-Path $root $m.file }
    else {
      $mode=if($col -eq 1){'lossless'}else{'q85'}
      $inputFile=Join-Path $root ('preview-'+$row+'-'+$mode+'.png')
      & $decoder '-quiet' (Join-Path $root ('webp/'+$mode+'/'+$m.hash+'.webp')) '-o' $inputFile
      if($LASTEXITCODE -ne 0) { throw 'WebP decode failed' }
    }
    $img=[System.Drawing.Image]::FromFile($inputFile)
    $scale=[math]::Min(260/$img.Width,200/$img.Height)
    $width=[int]($img.Width*$scale);$height=[int]($img.Height*$scale)
    $graphics.DrawImage($img,($col*300+(300-$width)/2),($row*240+45),$width,$height)
    $graphics.DrawString(($s.Name+' '+$s.Kind),$font,$brush,($col*300+15),($row*240+245))
    $img.Dispose()
  }
}
$canvas.Save((Join-Path $root 'comparison.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose();$canvas.Dispose();$font.Dispose()
