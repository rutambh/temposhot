#Requires -Version 5.1
param(
    [Parameter(Mandatory=$true)][string]$ProjectRoot,
    [Parameter(Mandatory=$true)][string]$LiteSrc,
    [Parameter(Mandatory=$true)][string]$ProSrc,
    [string]$LiteBg = "#CAB3E1",
    [string]$ProBg = "#030511"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$densities = [ordered]@{
    'mdpi'    = 48
    'hdpi'    = 72
    'xhdpi'   = 96
    'xxhdpi'  = 144
    'xxxhdpi' = 192
}

function New-RoundedRectPath {
    param([float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $R * 2
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $W - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $W - $diameter, $Y + $H - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $H - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Export-LegacyIcon {
    param([System.Drawing.Bitmap]$Src, [int]$Size, [string]$OutPath)
    $bmp = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $radius = [float]($Size * 0.20)
    $path = New-RoundedRectPath -X 0 -Y 0 -W $Size -H $Size -R $radius
    $g.SetClip($path)
    $g.DrawImage($Src, 0, 0, $Size, $Size)
    $g.ResetClip()

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $path.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

function Export-AdaptiveForeground {
    param([System.Drawing.Bitmap]$Src, [int]$Size, [string]$OutPath)
    # Size is 108dp * density scale (e.g. 108, 162, 216, 324, 432)
    # Safe zone is central 66-72dp. We scale inner artwork to 62% of canvas.
    $bmp = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $innerW = [int]($Size * 0.62)
    $innerH = $innerW
    $offsetX = [int](($Size - $innerW) / 2)
    $offsetY = [int](($Size - $innerH) / 2)
    $radius = [float]($innerW * 0.20)

    $path = New-RoundedRectPath -X $offsetX -Y $offsetY -W $innerW -H $innerH -R $radius
    $g.SetClip($path)
    $g.DrawImage($Src, $offsetX, $offsetY, $innerW, $innerH)
    $g.ResetClip()

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $path.Dispose()
    $g.Dispose()
    $bmp.Dispose()
}

function Export-WebIcon {
    param([System.Drawing.Bitmap]$Src, [int]$Size, [string]$OutPath, [bool]$Maskable = $false)
    $bmp = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    if ($Maskable) {
        $innerW = [int]($Size * 0.70)
        $offsetX = [int](($Size - $innerW) / 2)
        $radius = [float]($innerW * 0.20)
        $path = New-RoundedRectPath -X $offsetX -Y $offsetX -W $innerW -H $innerW -R $radius
        $g.SetClip($path)
        $g.DrawImage($Src, $offsetX, $offsetX, $innerW, $innerW)
        $g.ResetClip()
        $path.Dispose()
    } else {
        $radius = [float]($Size * 0.20)
        $path = New-RoundedRectPath -X 0 -Y 0 -W $Size -H $Size -R $radius
        $g.SetClip($path)
        $g.DrawImage($Src, 0, 0, $Size, $Size)
        $g.ResetClip()
        $path.Dispose()
    }

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$editions = @{
    'lite' = @{
        Src = [System.Drawing.Bitmap]::FromFile((Resolve-Path $LiteSrc).Path)
        Bg  = $LiteBg
    }
    'pro' = @{
        Src = [System.Drawing.Bitmap]::FromFile((Resolve-Path $ProSrc).Path)
        Bg  = $ProBg
    }
}

foreach ($ed in $editions.Keys) {
    $info = $editions[$ed]
    $resRoot = Join-Path $ProjectRoot "android/app/src/$ed/res"
    New-Item -ItemType Directory -Force -Path $resRoot | Out-Null

    # Adaptive XML
    $anydpiDir = Join-Path $resRoot 'mipmap-anydpi-v26'
    New-Item -ItemType Directory -Force -Path $anydpiDir | Out-Null
    $adaptiveXml = @"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"@
    Set-Content -Path (Join-Path $anydpiDir 'ic_launcher.xml') -Value $adaptiveXml -Encoding UTF8

    # Colors XML
    $valuesDir = Join-Path $resRoot 'values'
    New-Item -ItemType Directory -Force -Path $valuesDir | Out-Null
    $colorsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">$($info.Bg)</color>
</resources>
"@
    Set-Content -Path (Join-Path $valuesDir 'colors.xml') -Value $colorsXml -Encoding UTF8

    # Mipmap densities
    foreach ($d in $densities.Keys) {
        $legacySize = [int]$densities[$d]
        $fgSize = [int]($legacySize * 2.25)
        $dDir = Join-Path $resRoot "mipmap-$d"
        New-Item -ItemType Directory -Force -Path $dDir | Out-Null

        Export-LegacyIcon -Src $info.Src -Size $legacySize -OutPath (Join-Path $dDir 'ic_launcher.png')
        Export-AdaptiveForeground -Src $info.Src -Size $fgSize -OutPath (Join-Path $dDir 'ic_launcher_foreground.png')
        Write-Host "  $ed/$d : legacy ${legacySize}x${legacySize}, foreground ${fgSize}x${fgSize}"
    }
}

# Update main/res as fallback
$mainRes = Join-Path $ProjectRoot "android/app/src/main/res"
if (Test-Path $mainRes) {
    foreach ($d in $densities.Keys) {
        $legacySize = [int]$densities[$d]
        $dDir = Join-Path $mainRes "mipmap-$d"
        if (Test-Path $dDir) {
            Export-LegacyIcon -Src $editions['lite'].Src -Size $legacySize -OutPath (Join-Path $dDir 'ic_launcher.png')
        }
    }
}

# Update web icons
$webDir = Join-Path $ProjectRoot "web"
if (Test-Path $webDir) {
    Export-LegacyIcon -Src $editions['lite'].Src -Size 32 -OutPath (Join-Path $webDir 'favicon.png')
    $webIconsDir = Join-Path $webDir "icons"
    if (Test-Path $webIconsDir) {
        Export-WebIcon -Src $editions['lite'].Src -Size 192 -OutPath (Join-Path $webIconsDir 'Icon-192.png')
        Export-WebIcon -Src $editions['lite'].Src -Size 512 -OutPath (Join-Path $webIconsDir 'Icon-512.png')
        Export-WebIcon -Src $editions['lite'].Src -Size 192 -OutPath (Join-Path $webIconsDir 'Icon-maskable-192.png') -Maskable $true
        Export-WebIcon -Src $editions['lite'].Src -Size 512 -OutPath (Join-Path $webIconsDir 'Icon-maskable-512.png') -Maskable $true
    }
    Write-Host "  web icons updated"
}

$editions['lite'].Src.Dispose()
$editions['pro'].Src.Dispose()
Write-Host "Done generating icons for $ProjectRoot"
