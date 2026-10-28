Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path "assets\reference_poster.jpg"))
$srcW = $src.Width   # 682
$srcH = $src.Height  # 1024

$outW = 1920
$outH = 1080
$bmp = New-Object System.Drawing.Bitmap($outW, $outH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# 1. Base Sky: Rich royal midnight blue from reference_poster (sample at x:338, y:120)
$skyColorTop = [System.Drawing.Color]::FromArgb(255, 3, 7, 24)
$skyColorBottom = [System.Drawing.Color]::FromArgb(255, 8, 14, 38)
$skyBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(0, [int]($outH * 0.65))),
    $skyColorTop,
    $skyColorBottom
)
$g.FillRectangle($skyBrush, 0, 0, $outW, [int]($outH * 0.65))
$skyBrush.Dispose()

# 2. Reflective Wooden Floor across bottom 42% of screen (y: 620 to 1080)
$floorY = [int]($outH * 0.58)
$floorH = $outH - $floorY
$floorBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, $floorY)),
    (New-Object System.Drawing.Point(0, $outH)),
    [System.Drawing.Color]::FromArgb(255, 14, 8, 26),
    [System.Drawing.Color]::FromArgb(255, 4, 1, 10)
)
$g.FillRectangle($floorBrush, 0, $floorY, $outW, $floorH)
$floorBrush.Dispose()

# Draw golden reflection pool in center floor reflecting the wheel
$poolPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$poolPath.AddEllipse([int]($outW * 0.25), [int]($floorY - 60), [int]($outW * 0.5), [int]($floorH + 120))
$poolGrad = New-Object System.Drawing.Drawing2D.PathGradientBrush($poolPath)
$poolGrad.CenterColor = [System.Drawing.Color]::FromArgb(110, 240, 150, 40)
$poolGrad.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 14, 8, 26))
$g.FillPath($poolGrad, $poolPath)
$poolGrad.Dispose()
$poolPath.Dispose()

# 3. Add starry sky sparkles across the sky (using random seed for reproducibility)
$rnd = New-Object System.Random(42)
$starBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 255, 245, 210))
for ($i = 0; $i -lt 350; $i++) {
    $sx = $rnd.Next(0, $outW)
    $sy = $rnd.Next(0, $floorY)
    $sSize = 1
    if ($rnd.Next(0, 10) -eq 0) { $sSize = 2 }
    $g.FillEllipse($starBrush, $sx, $sy, $sSize, $sSize)
}
$starBrush.Dispose()

# 4. Left Panel: Draw pristine full-height left side from reference_poster (x: 0 to 225)
# Contains golden firework, magenta firework, cyan firework, lantern, diya, floor, and corner bokeh
$leftSrcW = 225
$leftDestW = [int]($leftSrcW * ($outH / 1024.0) * 1.15)
$leftBmp = New-Object System.Drawing.Bitmap($leftDestW, $outH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gL = [System.Drawing.Graphics]::FromImage($leftBmp)
$gL.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gL.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $leftDestW, $outH)), (New-Object System.Drawing.Rectangle(0, 0, $leftSrcW, 1024)), [System.Drawing.GraphicsUnit]::Pixel)
$gL.Dispose()

# Feather the inner edge (rightmost 90px) into the center
for ($y = 0; $y -lt $outH; $y++) {
    for ($x = 0; $x -lt $leftDestW; $x++) {
        $distFromRight = $leftDestW - $x
        if ($distFromRight -lt 90) {
            $alpha = [float]$distFromRight / 90.0
            $c = $leftBmp.GetPixel($x, $y)
            $leftBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb([int]($alpha * 255), $c.R, $c.G, $c.B))
        }
    }
}
$g.DrawImage($leftBmp, 0, 0)
$leftBmp.Dispose()

# 5. Right Panel: Draw pristine full-height right side from reference_poster (x: 457 to 682)
# Contains magenta firework, cyan firework, magenta firework, lantern, diya, floor, and corner bokeh
$rightSrcW = 225
$rightDestW = [int]($rightSrcW * ($outH / 1024.0) * 1.15)
$rightDestX = $outW - $rightDestW
$rightBmp = New-Object System.Drawing.Bitmap($rightDestW, $outH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gR = [System.Drawing.Graphics]::FromImage($rightBmp)
$gR.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gR.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $rightDestW, $outH)), (New-Object System.Drawing.Rectangle((682 - $rightSrcW), 0, $rightSrcW, 1024)), [System.Drawing.GraphicsUnit]::Pixel)
$gR.Dispose()

# Feather the inner edge (leftmost 90px) into the center
for ($y = 0; $y -lt $outH; $y++) {
    for ($x = 0; $x -lt $rightDestW; $x++) {
        if ($x -lt 90) {
            $alpha = [float]$x / 90.0
            $c = $rightBmp.GetPixel($x, $y)
            $rightBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb([int]($alpha * 255), $c.R, $c.G, $c.B))
        }
    }
}
$g.DrawImage($rightBmp, $rightDestX, 0)
$rightBmp.Dispose()

# 6. Top Center: Draw top fireworks burst from reference_poster (y: 0 to 220, x: 180 to 500)
# Feather around edges so it sits naturally in the upper sky
$topBurstW = [int](320 * ($outH / 1024.0))
$topBurstH = [int](200 * ($outH / 1024.0))
$topBurstX = [int](($outW - $topBurstW) / 2)
$topBurstBmp = New-Object System.Drawing.Bitmap($topBurstW, $topBurstH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gT = [System.Drawing.Graphics]::FromImage($topBurstBmp)
$gT.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gT.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $topBurstW, $topBurstH)), (New-Object System.Drawing.Rectangle(180, 0, 320, 200)), [System.Drawing.GraphicsUnit]::Pixel)
$gT.Dispose()

for ($y = 0; $y -lt $topBurstH; $y++) {
    for ($x = 0; $x -lt $topBurstW; $x++) {
        $distX = [Math]::Min($x, ($topBurstW - $x))
        $distY = [Math]::Min($y, ($topBurstH - $y))
        $edgeDist = [Math]::Min($distX, $distY)
        if ($edgeDist -lt 50) {
            $alpha = [float]$edgeDist / 50.0
            $c = $topBurstBmp.GetPixel($x, $y)
            $topBurstBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb([int]($alpha * 255), $c.R, $c.G, $c.B))
        }
    }
}
$g.DrawImage($topBurstBmp, $topBurstX, 0)
$topBurstBmp.Dispose()

# Save crystal-clear background at high quality
$outPath = "assets\diwali_crystal_clear_bg.jpg"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

$g.Dispose()
$bmp.Dispose()
$src.Dispose()

Write-Output "Successfully generated: $outPath"
