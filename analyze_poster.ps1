Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path "assets\reference_poster.jpg"))
Write-Output "Size: $($src.Width) x $($src.Height)"

# Sample background color in the sky between fireworks
$c1 = $src.GetPixel(338, 200)
Write-Output "Sky at (338, 200): R=$($c1.R), G=$($c1.G), B=$($c1.B)"

# Plaque inner color at (341, 890)
$c2 = $src.GetPixel(341, 890)
Write-Output "Plaque inner at (341, 890): R=$($c2.R), G=$($c2.G), B=$($c2.B)"

$src.Dispose()
