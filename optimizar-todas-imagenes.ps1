# Optimización masiva de imágenes del portafolio UWEB
Write-Host "=== OPTIMIZACIÓN MASIVA DE IMÁGENES ===" -ForegroundColor Green

$magick = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"
$portfolioDir = "assets\images\portfolio"

# Obtener todos los archivos SVG y JPG
$files = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg" -Name

Write-Host "Procesando $($files.Count) archivos..." -ForegroundColor Cyan

$webpCreated = 0
$jpgCreated = 0

foreach ($file in $files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $extension = [System.IO.Path]::GetExtension($file)
    $fullPath = Join-Path $portfolioDir $file
    
    Write-Host "Procesando: $file" -ForegroundColor White
    
    # Crear WebP
    $webpPath = Join-Path $portfolioDir "$baseName.webp"
    if (-not (Test-Path $webpPath)) {
        try {
            if ($extension -eq ".svg") {
                & $magick $fullPath -background white -flatten -resize "800x600>" -quality 85 -strip $webpPath
            } else {
                & $magick $fullPath -resize "800x600>" -quality 85 -strip $webpPath
            }
            if (Test-Path $webpPath) {
                $webpSize = [math]::Round((Get-Item $webpPath).Length / 1KB, 2)
                Write-Host "  ✓ WebP: $webpSize KB" -ForegroundColor Green
                $webpCreated++
            }
        } catch {
            Write-Host "  ✗ Error WebP: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Crear JPG
    $jpgPath = Join-Path $portfolioDir "$baseName.jpg"
    if (-not (Test-Path $jpgPath)) {
        try {
            if ($extension -eq ".svg") {
                & $magick $fullPath -background white -flatten -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
            } else {
                & $magick $fullPath -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
            }
            if (Test-Path $jpgPath) {
                $jpgSize = [math]::Round((Get-Item $jpgPath).Length / 1KB, 2)
                Write-Host "  ✓ JPG: $jpgSize KB" -ForegroundColor Green
                $jpgCreated++
            }
        } catch {
            Write-Host "  ✗ Error JPG: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== RESUMEN FINAL ===" -ForegroundColor Cyan
Write-Host "Archivos WebP creados: $webpCreated" -ForegroundColor Green
Write-Host "Archivos JPG creados: $jpgCreated" -ForegroundColor Green
Write-Host "Total archivos optimizados: $($webpCreated + $jpgCreated)" -ForegroundColor Green

Write-Host "`n✅ OPTIMIZACIÓN COMPLETA FINALIZADA" -ForegroundColor Green