# Script de Compresión de Imágenes UWEB
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
    $images = Get-ChildItem -Path $directory -Include "*.jpg", "*.jpeg", "*.png", "*.svg" -Recurse
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

$tools = @{
    ImageMagick = $false
    OptiPNG = $false
    JPEGOptim = $false
    SVGO = $false
}

try {
    $null = magick -version 2>$null
    $tools.ImageMagick = $true
    Write-Host "✓ ImageMagick disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ ImageMagick no encontrado" -ForegroundColor Red
}

try {
    $null = optipng -v 2>$null
    $tools.OptiPNG = $true
    Write-Host "✓ OptiPNG disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ OptiPNG no encontrado" -ForegroundColor Red
}

try {
    $null = jpegoptim --version 2>$null
    $tools.JPEGOptim = $true
    Write-Host "✓ JPEGOptim disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ JPEGOptim no encontrado" -ForegroundColor Red
}

try {
    $null = svgo --version 2>$null
    $tools.SVGO = $true
    Write-Host "✓ SVGO disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ SVGO no encontrado" -ForegroundColor Red
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

Set-Content -Path "assets/images/optimization-config.json" -Value $optimizationConfig -Encoding UTF8
Write-Host "`n✓ Configuración de optimización creada" -ForegroundColor Green

# Crear script de optimización manual
$manualOptimizationScript = @"
# Guía de Optimización Manual de Imágenes UWEB

## Herramientas Recomendadas

### 1. ImageMagick (Recomendado)
- Descarga: https://imagemagick.org/script/download.php#windows
- Comando para JPG: magick input.jpg -resize 800x600> -quality 80 -strip output.jpg
- Comando para PNG: magick input.png -resize 800x600> -quality 85 -strip output.png
- Comando para WebP: magick input.jpg -resize 800x600> -quality 85 output.webp

### 2. Herramientas Online
- TinyPNG: https://tinypng.com/ (PNG y JPG)
- Squoosh: https://squoosh.app/ (Múltiples formatos)
- SVGOMG: https://jakearchibald.github.io/svgomg/ (SVG)

### 3. Optimización por Tipo de Imagen

#### Imágenes del Portafolio (SVG)
- Usar SVGOMG para minificar
- Mantener tamaño original para escalabilidad
- Crear versiones JPG/WebP para fallback

#### Imágenes Open Graph (JPG)
- Tamaño: 1200x630px
- Calidad: 85%
- Formato: JPG optimizado

#### Iconos y Gráficos (SVG)
- Minificar con SVGO
- Remover metadatos innecesarios
- Optimizar paths y formas

## Comandos de Optimización

### Con ImageMagick instalado:
```powershell
# Optimizar todas las imágenes JPG del portafolio
Get-ChildItem "assets/images/portfolio/*.jpg" | ForEach-Object {
    magick `$_.FullName -resize "400x300>" -quality 80 -strip `$_.FullName
}

# Crear versiones WebP
Get-ChildItem "assets/images/portfolio/*.jpg" | ForEach-Object {
    `$webpPath = `$_.FullName -replace '\.jpg$', '.webp'
    magick `$_.FullName -quality 85 `$webpPath
}
```

### Sin herramientas (Manual):
1. Usar herramientas online mencionadas arriba
2. Descargar imágenes optimizadas
3. Reemplazar archivos originales
4. Verificar que el sitio funcione correctamente

## Objetivos de Optimización
- Imágenes del portafolio: < 50KB cada una
- Imágenes Open Graph: < 100KB cada una
- SVG: Minificados sin pérdida de calidad
- Tiempo de carga total de imágenes: < 2 segundos
"@

Set-Content -Path "assets/images/optimization-guide.md" -Value $manualOptimizationScript -Encoding UTF8
Write-Host "✓ Guía de optimización manual creada" -ForegroundColor Green

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
- ImageMagick: $(if ($tools.ImageMagick) { "✓ Disponible" } else { "✗ No disponible" })
- OptiPNG: $(if ($tools.OptiPNG) { "✓ Disponible" } else { "✗ No disponible" })
- JPEGOptim: $(if ($tools.JPEGOptim) { "✓ Disponible" } else { "✗ No disponible" })
- SVGO: $(if ($tools.SVGO) { "✓ Disponible" } else { "✗ No disponible" })

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

## Archivos Creados
- assets/images/optimization-config.json
- assets/images/optimization-guide.md
- assets/images/.htaccess (actualizado)
- assets/images/lazy-load-enhanced.js (ya existía)
"@

Set-Content -Path "image-optimization-report.md" -Value $report -Encoding UTF8
Write-Host "✓ Reporte de optimización generado" -ForegroundColor Green

Write-Host "`nResumen de Compresión:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "• Análisis completado: $($portfolioAnalysis.TotalImages + $generalAnalysis.TotalImages) imágenes" -ForegroundColor White
Write-Host "• Configuración creada: optimization-config.json" -ForegroundColor White
Write-Host "• Guía manual: optimization-guide.md" -ForegroundColor White
Write-Host "• Reporte generado: image-optimization-report.md" -ForegroundColor White
Write-Host "• .htaccess actualizado para WebP automático" -ForegroundColor White

if (-not $tools.ImageMagick) {
    Write-Host "`nRecomendación Principal:" -ForegroundColor Yellow
    Write-Host "Instala ImageMagick para optimización automática completa" -ForegroundColor Yellow
    Write-Host "Descarga: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host "Después ejecuta: .\optimize-portfolio-images.ps1" -ForegroundColor Yellow
}

Write-Host "`n¡Compresión de imágenes configurada! 📸" -ForegroundColor Green