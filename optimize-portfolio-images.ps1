# Script simplificado para optimizar imágenes del portafolio UWEB
Write-Host "Optimizando imágenes del portafolio UWEB..." -ForegroundColor Green

# Función para obtener tamaño de archivo
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Verificar ImageMagick
$imageMagickAvailable = $false
try {
    $null = magick -version 2>$null
    $imageMagickAvailable = $true
    Write-Host "ImageMagick detectado - Optimización completa disponible" -ForegroundColor Green
} catch {
    Write-Host "ImageMagick no encontrado - Creando estructura básica" -ForegroundColor Yellow
}

# Directorio del portafolio
$portfolioDir = "assets/images/portfolio"

# Obtener archivos de imagen
$imageFiles = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png" -ErrorAction SilentlyContinue

Write-Host "Encontrados $($imageFiles.Count) archivos para procesar" -ForegroundColor White

$filesProcessed = 0
foreach ($file in $imageFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    if ($imageMagickAvailable) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $webpPath = Join-Path $portfolioDir "$baseName.webp"
        $jpgPath = Join-Path $portfolioDir "$baseName.jpg"
        
        try {
            # Crear WebP si no existe
            if (-not (Test-Path $webpPath)) {
                magick $file.FullName -resize "800x600>" -quality 85 -strip $webpPath
                $webpSize = Get-FileSizeKB $webpPath
                Write-Host "  WebP creado: $baseName.webp ($webpSize KB)" -ForegroundColor Green
            }
            
            # Crear JPG optimizado si no existe
            if (-not (Test-Path $jpgPath)) {
                if ($file.Extension -eq ".svg") {
                    magick $file.FullName -resize "800x600>" -quality 80 -strip $jpgPath
                } else {
                    magick $file.FullName -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
                }
                $jpgSize = Get-FileSizeKB $jpgPath
                Write-Host "  JPG optimizado: $baseName.jpg ($jpgSize KB)" -ForegroundColor Green
            }
            
            $filesProcessed++
        } catch {
            Write-Host "  Error procesando $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Archivo listo (instala ImageMagick para optimización)" -ForegroundColor Gray
    }
}

# Crear .htaccess para optimización
$htaccessContent = @"
# Optimización de imágenes UWEB
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/webp "access plus 1 month"
</IfModule>

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI}.webp -f
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.$2.webp [T=image/webp,L]
</IfModule>

<IfModule mod_mime.c>
    AddType image/webp .webp
</IfModule>
"@

$htaccessPath = "assets/images/.htaccess"
Set-Content -Path $htaccessPath -Value $htaccessContent -Encoding UTF8
Write-Host ".htaccess actualizado para servir WebP automáticamente" -ForegroundColor Green

Write-Host "`nOptimización completada:" -ForegroundColor Cyan
Write-Host "- Archivos procesados: $filesProcessed" -ForegroundColor White
Write-Host "- Formatos creados: WebP (moderno) + JPG (fallback)" -ForegroundColor White
Write-Host "- Servidor configurado para servir WebP automáticamente" -ForegroundColor White

if (-not $imageMagickAvailable) {
    Write-Host "`nPara optimización completa, instala ImageMagick:" -ForegroundColor Yellow
    Write-Host "https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
}

Write-Host "`nOptimización de imágenes completada!" -ForegroundColor Green