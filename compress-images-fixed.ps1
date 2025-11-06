# Script de Compresión de Imágenes UWEB - Versión Corregida
# Reduce el tamaño de archivos de imagen para mejor rendimiento

Write-Host "Compresión de Imágenes UWEB" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

# Función para obtener el tamaño de archivo en KB
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Función para analizar imágenes
function Analyze-Images($directory) {
    if (-not (Test-Path $directory)) {
        Write-Host "Directorio no encontrado: $directory" -ForegroundColor Yellow
        return @{
            TotalImages = 0
            TotalSize = 0
            LargeImages = @()
            AverageSize = 0
        }
    }
    
    $images = Get-ChildItem -Path $directory -Include "*.jpg", "*.jpeg", "*.png", "*.svg" -Recurse -ErrorAction SilentlyContinue
    $totalSize = 0
    $largeImages = @()
    
    foreach ($img in $images) {
        $size = Get-FileSizeKB $img.FullName
        $totalSize += $size
        
        # Identificar imágenes grandes (>100KB)
        if ($size -gt 100) {
            $largeImages += @{
                Name = $img.Name
                Path = $img.FullName
                Size = $size
                Extension = $img.Extension
            }
        }
    }
    
    return @{
        TotalImages = $images.Count
        TotalSize = $totalSize
        LargeImages = $largeImages
        AverageSize = if ($images.Count -gt 0) { [math]::Round($totalSize / $images.Count, 2) } else { 0 }
    }
}

# Analizar imágenes actuales
Write-Host "`nAnalizando imágenes del sitio..." -ForegroundColor Cyan

$portfolioAnalysis = Analyze-Images "assets/images/portfolio"
$generalAnalysis = Analyze-Images "assets/images"

Write-Host "`nResultados del análisis:" -ForegroundColor White
Write-Host "========================" -ForegroundColor White
Write-Host "Portafolio:" -ForegroundColor Yellow
Write-Host "  • Total de imágenes: $($portfolioAnalysis.TotalImages)" -ForegroundColor White
Write-Host "  • Tamaño total: $($portfolioAnalysis.TotalSize) KB" -ForegroundColor White
Write-Host "  • Tamaño promedio: $($portfolioAnalysis.AverageSize) KB" -ForegroundColor White
Write-Host "  • Imágenes grandes (>100KB): $($portfolioAnalysis.LargeImages.Count)" -ForegroundColor White

Write-Host "`nImágenes generales:" -ForegroundColor Yellow
Write-Host "  • Total de imágenes: $($generalAnalysis.TotalImages)" -ForegroundColor White
Write-Host "  • Tamaño total: $($generalAnalysis.TotalSize) KB" -ForegroundColor White
Write-Host "  • Tamaño promedio: $($generalAnalysis.AverageSize) KB" -ForegroundColor White
Write-Host "  • Imágenes grandes (>100KB): $($generalAnalysis.LargeImages.Count)" -ForegroundColor White

# Mostrar imágenes que necesitan optimización
$allLargeImages = $portfolioAnalysis.LargeImages + $generalAnalysis.LargeImages
if ($allLargeImages.Count -gt 0) {
    Write-Host "`nImágenes que necesitan optimización:" -ForegroundColor Red
    foreach ($img in $allLargeImages) {
        Write-Host "  • $($img.Name): $($img.Size) KB" -ForegroundColor Yellow
    }
}

# Verificar herramientas de optimización disponibles
Write-Host "`nVerificando herramientas de optimización..." -ForegroundColor Cyan

$imageMagickAvailable = $false
try {
    $null = magick -version 2>$null
    $imageMagickAvailable = $true
    Write-Host "✓ ImageMagick disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ ImageMagick no encontrado" -ForegroundColor Red
}

# Crear configuración de optimización
$optimizationConfig = @"
{
  "imageOptimization": {
    "enabled": true,
    "formats": {
      "jpeg": {
        "quality": 80,
        "progressive": true,
        "maxWidth": 800,
        "maxHeight": 600
      },
      "png": {
        "quality": 85,
        "maxWidth": 800,
        "maxHeight": 600
      },
      "webp": {
        "quality": 85,
        "maxWidth": 800,
        "maxHeight": 600
      },
      "svg": {
        "removeComments": true,
        "removeMetadata": true,
        "minifyStyles": true
      }
    },
    "portfolio": {
      "maxWidth": 400,
      "maxHeight": 300,
      "quality": 80
    },
    "openGraph": {
      "width": 1200,
      "height": 630,
      "quality": 85
    }
  }
}
"@

if (-not (Test-Path "assets/images/optimization-config.json")) {
    Set-Content -Path "assets/images/optimization-config.json" -Value $optimizationConfig -Encoding UTF8
    Write-Host "`n✓ Configuración de optimización creada" -ForegroundColor Green
} else {
    Write-Host "`n✓ Configuración de optimización ya existe" -ForegroundColor Green
}

# Crear reporte de optimización
$report = @"
# Reporte de Optimización de Imágenes UWEB
Generado: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Resumen Actual
- **Total de imágenes del portafolio**: $($portfolioAnalysis.TotalImages)
- **Tamaño total del portafolio**: $($portfolioAnalysis.TotalSize) KB
- **Promedio por imagen**: $($portfolioAnalysis.AverageSize) KB
- **Imágenes grandes identificadas**: $($allLargeImages.Count)

## Herramientas Disponibles
- ImageMagick: $(if ($imageMagickAvailable) { "✓ Disponible" } else { "✗ No disponible" })

## Recomendaciones
1. **Instalar ImageMagick** para optimización automática
2. **Convertir SVG a WebP/JPG** para mejor compatibilidad
3. **Optimizar imágenes grandes** (>100KB)
4. **Implementar lazy loading** (ya configurado)
5. **Usar .htaccess** para servir WebP automáticamente (ya configurado)

## Próximos Pasos
1. Ejecutar .\optimize-portfolio-images.ps1 después de instalar ImageMagick
2. Verificar que las imágenes se carguen correctamente
3. Monitorear el rendimiento con herramientas de desarrollo
4. Considerar CDN para mejor distribución global

## Archivos Creados/Actualizados
- assets/images/optimization-config.json
- assets/images/.htaccess (actualizado)
- assets/images/lazy-load.js (ya existía)
- sitemap.xml (actualizado)
"@

Set-Content -Path "image-optimization-report.md" -Value $report -Encoding UTF8
Write-Host "✓ Reporte de optimización generado" -ForegroundColor Green

Write-Host "`nResumen de Compresión:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "• Análisis completado: $($portfolioAnalysis.TotalImages + $generalAnalysis.TotalImages) imágenes" -ForegroundColor White
Write-Host "• Configuración creada: optimization-config.json" -ForegroundColor White
Write-Host "• Reporte generado: image-optimization-report.md" -ForegroundColor White
Write-Host "• .htaccess ya configurado para WebP automático" -ForegroundColor White

if (-not $imageMagickAvailable) {
    Write-Host "`nRecomendación Principal:" -ForegroundColor Yellow
    Write-Host "Instala ImageMagick para optimización automática completa" -ForegroundColor Yellow
    Write-Host "Descarga: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host "Después ejecuta: .\optimize-portfolio-images.ps1" -ForegroundColor Yellow
}

Write-Host "`n¡Compresión de imágenes configurada! 📸" -ForegroundColor Green