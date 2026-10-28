Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path "assets\reference_poster.jpg"))
$w = $src.Width   # 682
$h = $src.Height  # 1024

$bg = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bg)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# 1. Copy entire poster in full crystal clarity
$g.DrawImage($src, 0, 0, $w, $h)

# 2. Smoothly fill the center wheel area with the midnight navy sky
# Center of wheel is (341, 421), radius 220
$wheelPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$wheelPath.AddEllipse([float](341 - 225), [float](421 - 225), [float](450), [float](450))

$skyGrad = New-Object System.Drawing.Drawing2D.PathGradientBrush($wheelPath)
$skyGrad.CenterColor = [System.Drawing.Color]::FromArgb(255, 6, 12, 32)
$skyGrad.SurroundColors = @([System.Drawing.Color]::FromArgb(255, 4, 8, 22))
$g.FillPath($skyGrad, $wheelPath)
$skyGrad.Dispose()
$wheelPath.Dispose()

# Soften outer edge of wheel replacement circle (feather 35px into surrounding sky/fireworks)
for ($angle = 0; $angle -lt 360; $angle += 0.5) {
    $radAngle = $angle * [Math]::PI / 180.0
    for ($r = 210; $r -le 240; $r += 1) {
        $px = [int](341 + $r * [Math]::Cos($radAngle))
        $py = [int](421 + $r * [Math]::Sin($radAngle))
        if ($px -ge 0 -and $px -lt $w -and $py -ge 0 -and $py -lt 640) {
            $t = [float]($r - 210) / 30.0
            $orig = $src.GetPixel($px, $py)
            $fillR = 6
            $fillG = 10
            $fillB = 26
            $blendedR = [int]($fillR * (1.0 - $t) + $orig.R * $t)
            $blendedG = [int]($fillG * (1.0 - $t) + $orig.G * $t)
            $blendedB = [int]($fillB * (1.0 - $t) + $orig.B * $t)
            $bg.SetPixel($px, $py, [System.Drawing.Color]::FromArgb(255, $blendedR, $blendedG, $blendedB))
        }
    }
}

# 3. Blend the floor under the wheel (y: 620 to 770, x: 200 to 480) with glossy reflective wood
# Sample the glossy floor at y=650..770 from x=140..190 (left) and x=490..540 (right)
for ($y = 620; $y -lt 780; $y++) {
    for ($x = 180; $x -lt 500; $x++) {
        $t = [float]($x - 180) / (500.0 - 180.0)
        $cL = $src.GetPixel(150, $y)
        $cR = $src.GetPixel(530, $y)
        
        # Soft golden/pink reflection in center
        $distCenter = [Math]::Abs($x - 341)
        $glow = 0
        if ($distCenter -lt 90) {
            $glow = [int]((1.0 - ($distCenter / 90.0)) * 28)
        }
        
        $r = [Math]::Min(255, [int]((1.0 - $t) * $cL.R + $t * $cR.R + $glow * 1.5))
        $gCol = [Math]::Min(255, [int]((1.0 - $t) * $cL.G + $t * $cR.G + $glow * 0.8))
        $b = [Math]::Min(255, [int]((1.0 - $t) * $cL.B + $t * $cR.B + $glow * 0.4))
        
        # Edge feather
        $edgeDist = [Math]::Min(($x - 180), (500 - $x))
        if ($edgeDist -lt 25) {
            $alpha = $edgeDist / 25.0
            $orig = $src.GetPixel($x, $y)
            $r = [int]($orig.R * (1.0 - $alpha) + $r * $alpha)
            $gCol = [int]($orig.G * (1.0 - $alpha) + $gCol * $alpha)
            $b = [int]($orig.B * (1.0 - $alpha) + $b * $alpha)
        }
        $bg.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $r, $gCol, $b))
    }
}

# 4. Clean inside the bottom plaque (x: 180 to 500, y: 818 to 940) with smooth midnight plaque color
# Preserving the ornate gold border and corner flourishes!
$plaqueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 6, 11, 24))
$g.FillRectangle($plaqueBrush, 175, 818, 332, 122)
$plaqueBrush.Dispose()

$outMobile = "assets\diwali_mobile_clean_stage.jpg"
$bg.Save($outMobile, [System.Drawing.Imaging.ImageFormat]::Jpeg)

$g.Dispose()
$bg.Dispose()
$src.Dispose()

Write-Output "Generated $outMobile successfully"
