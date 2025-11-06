# Script para ejecutar optimización completa de imágenes
Write-Host "=== OPTIMIZACIÓN COMPLETA DE IMÁGENES UWEB ===" -ForegroundColor Green

# Ruta de ImageMagick
$imageMagickPath = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"

# Verificar que ImageMagick existe
if (-not (Test-Path $imageMagickPath)) {
    Write-Host "Error: No se encontró ImageMagick en $imageMagickPath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ ImageMagick encontrado" -ForegroundColor Green

# Función para obtener tamaño de archivo
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Directorio del portafolio
$portfolioDir = "assets/images/portfolio"
Write-Host "Procesando imágenes en: $portfolioDir" -ForegroundColor Cyan

# Obtener archivos de imagen
$imageFiles = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png" -ErrorAction SilentlyContinue
Write-Host "Encontrados $($imageFiles.Count) archivos para procesar" -ForegroundColor White

$filesProcessed = 0
$webpCreated = 0
$jpgCreated = 0
$totalOriginalSize = 0
$totalOptimizedSize = 0

foreach ($file in $imageFiles) {
    Write-Host "`nProcesando: $($file.Name)" -ForegroundColor White
    
    $originalSize = Get-FileSizeKB $file.FullName
    $totalOriginalSize += $originalSize
    Write-Host "  Tamaño original: $originalSize KB" -ForegroundColor Gray
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $webpPath = Join-Path $portfolioDir "$baseName.webp"
    $jpgPath = Join-Path $portfolioDir "$baseName.jpg"
    
    try {
        # Crear WebP si no existe
        if (-not (Test-Path $webpPath)) {
            if ($file.Extension -eq ".svg") {
                & $imageMagickPath $file.FullName -background white -flatten -resize "800x600>" -quality 85 -strip $webpPath
            } else {
                & $imageMagickPath $file.FullName -resize "800x600>" -quality 85 -strip $webpPath
            }
            
            if (Test-Path $webpPath) {
                $webpSize = Get-FileSizeKB $webpPath
                Write-Host "  ✓ WebP creado: $webpSize KB" -ForegroundColor Green
                $totalOptimizedSize += $webpSize
                $webpCreated++
            }
        } else {
            Write-Host "  - WebP ya existe" -ForegroundColor Yellow
        }
        
        # Crear JPG si no existe
        if (-not (Test-Path $jpgPath)) {
            if ($file.Extension -eq ".svg") {
                & $imageMagickPath $file.FullName -background white -flatten -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
            } else {
                & $imageMagickPath $file.FullName -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
            }
            
            if (Test-Path $jpgPath) {
                $jpgSize = Get-FileSizeKB $jpgPath
                Write-Host "  ✓ JPG creado: $jpgSize KB" -ForegroundColor Green
                $totalOptimizedSize += $jpgSize
                $jpgCreated++
            }
        } else {
            Write-Host "  - JPG ya existe" -ForegroundColor Yellow
        }
        
        $filesProcessed++
    } catch {
        Write-Host "  ✗ Error procesando: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== RESUMEN DE OPTIMIZACIÓN ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $filesProcessed" -ForegroundColor White
Write-Host "Archivos WebP creados: $webpCreated" -ForegroundColor White
Write-Host "Archivos JPG creados: $jpgCreated" -ForegroundColor White
Write-Host "Tamaño original total: $totalOriginalSize KB" -ForegroundColor White
Write-Host "Tamaño optimizado total: $totalOptimizedSize KB" -ForegroundColor White

if ($totalOriginalSize -gt 0 -and $totalOptimizedSize -gt 0) {
    $compressionRatio = [math]::Round((1 - ($totalOptimizedSize / $totalOriginalSize)) * 100, 1)
    Write-Host "Compresión lograda: $compressionRatio%" -ForegroundColor Green
}

Write-Host "`n✅ OPTIMIZACIÓN COMPLETA FINALIZADA" -ForegroundColor Green
Write-Host "Las imágenes están listas para usar en el sitio web" -ForegroundColor White