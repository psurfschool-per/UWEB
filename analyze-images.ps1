# Análisis Simple de Imágenes UWEB
Write-Host "Análisis de Imágenes UWEB" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Función para obtener tamaño en KB
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Verificar ImageMagick
Write-Host "`nVerificando herramientas..." -ForegroundColor Cyan
try {
    $null = magick -version 2>$null
    Write-Host "✓ ImageMagick disponible" -ForegroundColor Green
    $imageMagickAvailable = $true
} catch {
    Write-Host "✗ ImageMagick no disponible" -ForegroundColor Red
    $imageMagickAvailable = $false
}

# Analizar portafolio
Write-Host "`nAnalizando portafolio..." -ForegroundColor Cyan
$portfolioDir = "assets/images/portfolio"

if (Test-Path $portfolioDir) {
    $images = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png"
    $totalSize = 0
    
    Write-Host "Imágenes encontradas: $($images.Count)" -ForegroundColor White
    
    foreach ($img in $images) {
        $size = Get-FileSizeKB $img.FullName
        $totalSize += $size
        Write-Host "  $($img.Name): $size KB" -ForegroundColor White
    }
    
    Write-Host "`nResumen portafolio:" -ForegroundColor Yellow
    Write-Host "  Total: $($images.Count) imágenes" -ForegroundColor White
    Write-Host "  Tamaño total: $totalSize KB" -ForegroundColor White
    
    if ($images.Count -gt 0) {
        $average = [math]::Round($totalSize / $images.Count, 2)
        Write-Host "  Promedio: $average KB" -ForegroundColor White
    }
} else {
    Write-Host "Directorio no encontrado: $portfolioDir" -ForegroundColor Red
}

# Analizar Open Graph
Write-Host "`nAnalizando imágenes Open Graph..." -ForegroundColor Cyan
$ogImages = Get-ChildItem -Path "assets/images" -Filter "og-*.jpg"
$ogTotalSize = 0

foreach ($img in $ogImages) {
    $size = Get-FileSizeKB $img.FullName
    $ogTotalSize += $size
    Write-Host "  $($img.Name): $size KB" -ForegroundColor White
}

Write-Host "`nResumen Open Graph:" -ForegroundColor Yellow
Write-Host "  Total: $($ogImages.Count) imágenes" -ForegroundColor White
Write-Host "  Tamaño total: $ogTotalSize KB" -ForegroundColor White

# Estado de optimización
Write-Host "`nEstado de optimización:" -ForegroundColor Cyan

# Verificar sitemap
if (Test-Path "sitemap.xml") {
    $sitemapDate = (Get-Item "sitemap.xml").LastWriteTime.ToString("yyyy-MM-dd")
    Write-Host "✓ Sitemap actualizado: $sitemapDate" -ForegroundColor Green
} else {
    Write-Host "✗ Sitemap no encontrado" -ForegroundColor Red
}

# Verificar .htaccess
if (Test-Path "assets/images/.htaccess") {
    Write-Host "✓ .htaccess configurado para WebP" -ForegroundColor Green
} else {
    Write-Host "✗ .htaccess no configurado" -ForegroundColor Red
}

# Verificar lazy loading
if (Test-Path "assets/images/lazy-load.js") {
    Write-Host "✓ Lazy loading configurado" -ForegroundColor Green
} else {
    Write-Host "✗ Lazy loading no configurado" -ForegroundColor Red
}

Write-Host "`nRecomendaciones:" -ForegroundColor Yellow
if (-not $imageMagickAvailable) {
    Write-Host "1. Instalar ImageMagick para optimización automática" -ForegroundColor White
    Write-Host "   https://imagemagick.org/script/download.php#windows" -ForegroundColor Gray
}
Write-Host "2. Ejecutar optimize-portfolio-images.ps1 para crear versiones WebP" -ForegroundColor White
Write-Host "3. Verificar carga de imágenes en el navegador" -ForegroundColor White

Write-Host "`n✓ Análisis completado" -ForegroundColor Green