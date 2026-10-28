Add-Type -AssemblyName System.Drawing

$srcPath = Resolve-Path "assets\reference_poster.jpg"
$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$srcW = $src.Width   # 682
$srcH = $src.Height  # 1024

Write-Output "Source poster loaded: $srcW x $srcH"

# =========================================================================
# 1. CREATE MASTER MOBILE BACKGROUND (682 x 1024)
# =========================================================================
$mobileBg = New-Object System.Drawing.Bitmap($srcW, $srcH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gM = [System.Drawing.Graphics]::FromImage($mobileBg)
$gM.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gM.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# Draw the exact source reference poster
$gM.DrawImage($src, 0, 0, $srcW, $srcH)

# Smooth midnight blue circular backdrop in center stage (cx: 341, cy: 421, radius: 215)
# This clears the static wheel so our enlarged, interactive HTML wheel spins with no ghosting!
$cx = 341.0
$cy = 421.0
$rad = 216.0

$discPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$discPath.AddEllipse([float]($cx - $rad), [float]($cy - $rad), [float]($rad * 2), [float]($rad * 2))

$skyBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($discPath)
$skyBrush.CenterColor = [System.Drawing.Color]::FromArgb(255, 6, 12, 32)
$skyBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(255, 4, 8, 22))
$gM.FillPath($skyBrush, $discPath)
$skyBrush.Dispose()
$discPath.Dispose()

# Soften the edge of the wheel disc cutout into the background fireworks
for ($angle = 0; $angle -lt 360; $angle += 0.5) {
    $radAngle = $angle * [Math]::PI / 180.0
    for ($r = 205; $r -le 225; $r += 1) {
        $px = [int]($cx + $r * [Math]::Cos($radAngle))
        $py = [int]($cy + $r * [Math]::Sin($radAngle))
        if ($px -ge 0 -and $px -lt $srcW -and $py -ge 0 -and $py -lt 630) {
            $t = [float]($r - 205) / 20.0
            $orig = $src.GetPixel($px, $py)
            $fillR = 5
            $fillG = 9
            $fillB = 25
            $blendedR = [int]($fillR * (1.0 - $t) + $orig.R * $t)
            $blendedG = [int]($fillG * (1.0 - $t) + $orig.G * $t)
            $blendedB = [int]($fillB * (1.0 - $t) + $orig.B * $t)
            $mobileBg.SetPixel($px, $py, [System.Drawing.Color]::FromArgb(255, $blendedR, $blendedG, $blendedB))
        }
    }
}

# Add subtle starry night sparkles inside the center disc area
$rnd = New-Object System.Random(101)
$starBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 255, 240, 200))
for ($i = 0; $i -lt 120; $i++) {
    $dist = $rnd.NextDouble() * 190.0
    $ang = $rnd.NextDouble() * [Math]::PI * 2.0
    $sx = [int]($cx + $dist * [Math]::Cos($ang))
    $sy = [int]($cy + $dist * [Math]::Sin($ang))
    if ($sy -lt 610) {
        $s = 1
        if ($rnd.Next(0, 8) -eq 0) { $s = 2 }
        $gM.FillEllipse($starBrush, $sx, $sy, $s, $s)
    }
}
$starBrush.Dispose()

# Smooth the floor beneath the wheel (y: 625 to 765, x: 190 to 490)
# Preserving the golden wheel reflections and pink glow on the glossy wooden floor!
for ($y = 625; $y -lt 765; $y++) {
    for ($x = 190; $x -lt 495; $x++) {
        $t = [float]($x - 190) / (495.0 - 190.0)
        $cL = $src.GetPixel(160, $y)
        $cR = $src.GetPixel(525, $y)
        
        $distCenter = [Math]::Abs($x - 341)
        $centerGlow = 0
        if ($distCenter -lt 85) {
            $centerGlow = [int]((1.0 - ($distCenter / 85.0)) * 26)
        }
        
        $r = [Math]::Min(255, [int]((1.0 - $t) * $cL.R + $t * $cR.R + $centerGlow * 1.6))
        $gCol = [Math]::Min(255, [int]((1.0 - $t) * $cL.G + $t * $cR.G + $centerGlow * 0.9))
        $b = [Math]::Min(255, [int]((1.0 - $t) * $cL.B + $t * $cR.B + $centerGlow * 0.4))
        
        $edgeDist = [Math]::Min(($x - 190), (495 - $x))
        if ($edgeDist -lt 25) {
            $alpha = $edgeDist / 25.0
            $orig = $src.GetPixel($x, $y)
            $r = [int]($orig.R * (1.0 - $alpha) + $r * $alpha)
            $gCol = [int]($orig.G * (1.0 - $alpha) + $gCol * $alpha)
            $b = [int]($orig.B * (1.0 - $alpha) + $b * $alpha)
        }
        $mobileBg.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $r, $gCol, $b))
    }
}

# Clean inside the bottom plaque (y: 815 to 950, x: 170 to 512) so our updated Thudiyalur address sits cleanly
$plaqueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 6, 11, 24))
$gM.FillRectangle($plaqueBrush, 170, 815, 342, 135)
$plaqueBrush.Dispose()

$outMobile = "assets\diwali_clear_mobile_bg.jpg"
$mobileBg.Save($outMobile, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$gM.Dispose()
$mobileBg.Dispose()
Write-Output "Saved: $outMobile"

# =========================================================================
# 2. CREATE WIDESCREEN AMBIENT DESKTOP BACKGROUND (1920 x 1080)
# =========================================================================
$outW = 1920
$outH = 1080
$wideBg = New-Object System.Drawing.Bitmap($outW, $outH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gW = [System.Drawing.Graphics]::FromImage($wideBg)
$gW.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gW.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# Sky gradient
$deskSky = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(0, $outH)),
    [System.Drawing.Color]::FromArgb(255, 2, 5, 18),
    [System.Drawing.Color]::FromArgb(255, 6, 2, 14)
)
$gW.FillRectangle($deskSky, 0, 0, $outW, $outH)
$deskSky.Dispose()

# Draw full-height left fireworks panel (x: 0 to 220) scaled smoothly
$panelW = [int](225 * ($outH / 1024.0) * 1.35)
$gW.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $panelW, $outH)), (New-Object System.Drawing.Rectangle(0, 0, 220, 1024)), [System.Drawing.GraphicsUnit]::Pixel)

# Draw full-height right fireworks panel (x: 462 to 682) scaled smoothly
$gW.DrawImage($src, (New-Object System.Drawing.Rectangle(($outW - $panelW), 0, $panelW, $outH)), (New-Object System.Drawing.Rectangle(462, 0, 220, 1024)), [System.Drawing.GraphicsUnit]::Pixel)

# Feather edges of left and right panels into center
$feather = 100
$fL1 = New-Object System.Drawing.Point(($panelW - $feather), 0)
$fL2 = New-Object System.Drawing.Point($panelW, 0)
$bFL = New-Object System.Drawing.Drawing2D.LinearGradientBrush($fL1, $fL2, [System.Drawing.Color]::FromArgb(0, 2, 5, 18), [System.Drawing.Color]::FromArgb(255, 2, 5, 18))
$gW.FillRectangle($bFL, ($panelW - $feather), 0, $feather, $outH)
$bFL.Dispose()

$fR1 = New-Object System.Drawing.Point(($outW - $panelW), 0)
$fR2 = New-Object System.Drawing.Point(($outW - $panelW + $feather), 0)
$bFR = New-Object System.Drawing.Drawing2D.LinearGradientBrush($fR1, $fR2, [System.Drawing.Color]::FromArgb(255, 2, 5, 18), [System.Drawing.Color]::FromArgb(0, 2, 5, 18))
$gW.FillRectangle($bFR, ($outW - $panelW), 0, $feather, $outH)
$bFR.Dispose()

# Ambient starry sky sparkles in center desktop space
$starBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 255, 240, 200))
for ($i = 0; $i -lt 250; $i++) {
    $sx = $rnd.Next($panelW, ($outW - $panelW))
    $sy = $rnd.Next(0, [int]($outH * 0.7))
    $s = 1
    if ($rnd.Next(0, 8) -eq 0) { $s = 2 }
    $gW.FillEllipse($starBrush2, $sx, $sy, $s, $s)
}
$starBrush2.Dispose()

$outWide = "assets\diwali_clear_wide_bg.jpg"
$wideBg.Save($outWide, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$gW.Dispose()
$wideBg.Dispose()
$src.Dispose()

Write-Output "Saved: $outWide"
