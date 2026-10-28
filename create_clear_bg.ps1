Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path "assets\reference_poster.jpg"))
$w = $src.Width   # 682
$h = $src.Height  # 1024

# =========================================================================
# 1. CREATE MASTER MOBILE BACKGROUND (682 x 1024) - 100% CRYSTAL CLEAR
# =========================================================================
$mobileBg = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gM = [System.Drawing.Graphics]::FromImage($mobileBg)
$gM.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gM.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# Draw the exact reference poster in full crystal-clear fidelity
$gM.DrawImage($src, 0, 0, $w, $h)

# Clear the center wheel area (cx=338, cy=421, radius=210) with smooth midnight blue so our HTML wheel sits cleanly
$cx = 338.0
$cy = 421.0
$rad = 212.0

$discPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$discPath.AddEllipse([float]($cx - $rad), [float]($cy - $rad), [float]($rad * 2), [float]($rad * 2))

# Fill with smooth royal midnight navy gradient matching the starry sky
$discBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($discPath)
$discBrush.CenterColor = [System.Drawing.Color]::FromArgb(255, 6, 12, 28)
$discBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 6, 12, 28))
$gM.FillPath($discBrush, $discPath)
$discBrush.Dispose()
$discPath.Dispose()

# Softly blend the reflective floor across the old button (y: 685 to 760) and old card (y: 810 to 950)
# Notice between y: 640 and 1000, x from 125 to 555 is the center stage.
# We clone vertical floor reflections across the center so the floor remains glossy, reflective, and crystal clear!
for ($y = 675; $y -lt 960; $y++) {
    for ($x = 135; $x -lt 545; $x++) {
        $t = [float]($x - 135) / (545.0 - 135.0)
        
        # Sample left and right floor columns
        $cL = $src.GetPixel(125, $y)
        $cR = $src.GetPixel(555, $y)
        
        # Golden reflection streak down center reflecting the wheel
        $distFromCenter = [Math]::Abs($x - 338)
        $centerGlow = 0
        if ($distFromCenter -lt 90) {
            $centerGlow = [int]((1.0 - ($distFromCenter / 90.0)) * 26)
        }
        
        $r = [Math]::Min(255, [int]((1.0 - $t) * $cL.R + $t * $cR.R + $centerGlow * 1.3))
        $gCol = [Math]::Min(255, [int]((1.0 - $t) * $cL.G + $t * $cR.G + $centerGlow * 0.85))
        $b = [Math]::Min(255, [int]((1.0 - $t) * $cL.B + $t * $cR.B + $centerGlow * 0.35))
        
        $edgeDist = [Math]::Min(($x - 135), (545 - $x))
        if ($edgeDist -lt 20) {
            $alpha = $edgeDist / 20.0
            $orig = $src.GetPixel($x, $y)
            $r = [int]($orig.R * (1.0 - $alpha) + $r * $alpha)
            $gCol = [int]($orig.G * (1.0 - $alpha) + $gCol * $alpha)
            $b = [int]($orig.B * (1.0 - $alpha) + $b * $alpha)
        }
        
        $mobileBg.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $r, $gCol, $b))
    }
}

$gM.Dispose()
$outMobile = "assets\clear_diwali_mobile_bg.jpg"
$mobileBg.Save($outMobile, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$mobileBg.Dispose()
Write-Output "Generated $outMobile"

# =========================================================================
# 2. CREATE WIDESCREEN AMBIENT BACKDROP (1920 x 1080)
# =========================================================================
$outW = 1920
$outH = 1080
$wideBg = New-Object System.Drawing.Bitmap($outW, $outH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gW = [System.Drawing.Graphics]::FromImage($wideBg)
$gW.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gW.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# Deep royal midnight sky gradient
$skyBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(0, $outH)),
    [System.Drawing.Color]::FromArgb(255, 3, 6, 20),
    [System.Drawing.Color]::FromArgb(255, 6, 1, 12)
)
$gW.FillRectangle($skyBrush, 0, 0, $outW, $outH)
$skyBrush.Dispose()

# Draw left fireworks panel from reference_poster (x: 0 to 220) scaled to full height
$leftW = [int](225 * ($outH / 1024.0) * 1.2)
$gW.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $leftW, $outH)), (New-Object System.Drawing.Rectangle(0, 0, 225, 1024)), [System.Drawing.GraphicsUnit]::Pixel)

# Draw right fireworks panel from reference_poster (x: 457 to 682) scaled to full height
$rightW = [int](225 * ($outH / 1024.0) * 1.2)
$gW.DrawImage($src, (New-Object System.Drawing.Rectangle(($outW - $rightW), 0, $rightW, $outH)), (New-Object System.Drawing.Rectangle((682 - 225), 0, 225, 1024)), [System.Drawing.GraphicsUnit]::Pixel)

# Soft feather blend over left/right inner edges
$featherW = 80
$pL1 = New-Object System.Drawing.Point(($leftW - $featherW), 0)
$pL2 = New-Object System.Drawing.Point($leftW, 0)
$bL = New-Object System.Drawing.Drawing2D.LinearGradientBrush($pL1, $pL2, [System.Drawing.Color]::FromArgb(0, 3, 6, 20), [System.Drawing.Color]::FromArgb(255, 3, 6, 20))
$gW.FillRectangle($bL, ($leftW - $featherW), 0, $featherW, $outH)
$bL.Dispose()

$pR1 = New-Object System.Drawing.Point(($outW - $rightW), 0)
$pR2 = New-Object System.Drawing.Point(($outW - $rightW + $featherW), 0)
$bR = New-Object System.Drawing.Drawing2D.LinearGradientBrush($pR1, $pR2, [System.Drawing.Color]::FromArgb(255, 3, 6, 20), [System.Drawing.Color]::FromArgb(0, 3, 6, 20))
$gW.FillRectangle($bR, ($outW - $rightW), 0, $featherW, $outH)
$bR.Dispose()

$gW.Dispose()
$outWide = "assets\clear_diwali_wide_bg.jpg"
$wideBg.Save($outWide, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$wideBg.Dispose()
$src.Dispose()

Write-Output "Generated $outWide"
