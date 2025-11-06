# Verificacion de Optimizacion de Imagenes UWEB
Write-Host "Verificacion de Optimizacion UWEB" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Funcion para obtener tamano en KB
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Verificar ImageMagick
Write-Host "`nVerificando herramientas..." -ForegroundColor Cyan
$imageMagickAvailable = $false
$magickOutput = ""
try {
    $magickOutput = magick -version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ImageMagick disponible" -ForegroundColor Green
        $imageMagickAvailable = $true
    } else {
        Write-Host "ImageMagick no disponible" -ForegroundColor Red
    }
} catch {
    Write-Host "ImageMagick no encontrado" -ForegroundColor Red
}

# Analizar imagenes del portafolio
Write-Host "`nAnalizando portafolio..." -ForegroundColor Cyan
$portfolioDir = "assets/images/portfolio"

if (Test-Path $portfolioDir) {
    $images = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png"
    $totalSize = 0
    
    Write-Host "Imagenes encontradas: $($images.Count)" -ForegroundColor White
    
    foreach ($img in $images) {
        $size = Get-FileSizeKB $img.FullName
        $totalSize += $size
        Write-Host "  $($img.Name): $size KB" -ForegroundColor White
    }
    
    Write-Host "`nResumen portafolio:" -ForegroundColor Yellow
    Write-Host "  Total: $($images.Count) imagenes" -ForegroundColor White
    Write-Host "  Tamano total: $totalSize KB" -ForegroundColor White
    
    if ($images.Count -gt 0) {
        $average = [math]::Round($totalSize / $images.Count, 2)
        Write-Host "  Promedio: $average KB" -ForegroundColor White
    }
}

# Analizar imagenes Open Graph
Write-Host "`nAnalizando imagenes Open Graph..." -ForegroundColor Cyan
$ogImages = Get-ChildItem -Path "assets/images" -Filter "og-*.jpg"
$ogTotalSize = 0

foreach ($img in $ogImages) {
    $size = Get-FileSizeKB $img.FullName
    $ogTotalSize += $size
    Write-Host "  $($img.Name): $size KB" -ForegroundColor White
}

Write-Host "`nResumen Open Graph:" -ForegroundColor Yellow
Write-Host "  Total: $($ogImages.Count) imagenes" -ForegroundColor White
Write-Host "  Tamano total: $ogTotalSize KB" -ForegroundColor White

# Verificar archivos de optimizacion
Write-Host "`nEstado de optimizacion:" -ForegroundColor Cyan

if (Test-Path "sitemap.xml") {
    $sitemapDate = (Get-Item "sitemap.xml").LastWriteTime.ToString("yyyy-MM-dd")
    Write-Host "Sitemap actualizado: $sitemapDate" -ForegroundColor Green
} else {
    Write-Host "Sitemap no encontrado" -ForegroundColor Red
}

if (Test-Path "assets/images/.htaccess") {
    Write-Host ".htaccess configurado para WebP" -ForegroundColor Green
} else {
    Write-Host ".htaccess no configurado" -ForegroundColor Red
}

if (Test-Path "assets/images/lazy-load.js") {
    Write-Host "Lazy loading configurado" -ForegroundColor Green
} else {
    Write-Host "Lazy loading no configurado" -ForegroundColor Red
}

Write-Host "`nRecomendaciones:" -ForegroundColor Yellow
if (-not $imageMagickAvailable) {
    Write-Host "1. Instalar ImageMagick para optimizacion automatica" -ForegroundColor White
}
Write-Host "2. Ejecutar optimize-portfolio-images.ps1 para crear versiones WebP" -ForegroundColor White
Write-Host "3. Verificar carga de imagenes en el navegador" -ForegroundColor White

Write-Host "`nVerificacion completada" -ForegroundColor Green