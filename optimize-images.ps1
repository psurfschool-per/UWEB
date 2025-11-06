# Script de Optimización de Imágenes para UWEB
# Este script optimiza imágenes para rendimiento web con conversión WebP y compresión

Write-Host "Script de Optimización de Imágenes UWEB" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Verificar si ImageMagick está disponible
$imageMagickAvailable = $false
try {
    $null = magick -version 2>$null
    $imageMagickAvailable = $true
    Write-Host "✓ ImageMagick detectado - Optimización avanzada disponible" -ForegroundColor Green
} catch {
    Write-Host "⚠ ImageMagick no encontrado - Solo optimización básica" -ForegroundColor Yellow
    Write-Host "  Instala ImageMagick para mejor optimización: https://imagemagick.org/" -ForegroundColor Yellow
}

# Función para obtener el tamaño de archivo en KB
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Definir directorios
$portfolioDir = "assets/images/portfolio"
$imagesDir = "assets/images"

# Contadores para estadísticas
$totalOriginalSize = 0
$totalOptimizedSize = 0
$filesProcessed = 0

Write-Host "`nOptimizando imágenes del portafolio..." -ForegroundColor Cyan

# Obtener todos los archivos de imagen en el directorio del portafolio
$imageFiles = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png" -ErrorAction SilentlyContinue

if ($imageFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos de imagen en $portfolioDir" -ForegroundColor Yellow
} else {
    Write-Host "Encontrados $($imageFiles.Count) archivos de imagen para procesar" -ForegroundColor Green
    
    foreach ($file in $imageFiles) {
        Write-Host "Procesando: $($file.Name)" -ForegroundColor White
        $originalSize = Get-FileSizeKB $file.FullName
        $totalOriginalSize += $originalSize
        
        if ($imageMagickAvailable) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $webpPath = Join-Path $portfolioDir "$baseName.webp"
            $jpgPath = Join-Path $portfolioDir "$baseName.jpg"
            
            try {
                # Convertir a WebP (formato moderno, mejor compresión)
                if (-not (Test-Path $webpPath) -or $file.LastWriteTime -gt (Get-Item $webpPath -ErrorAction SilentlyContinue).LastWriteTime) {
                    magick "$($file.FullName)" -resize "800x600>" -quality 85 -strip "$webpPath"
                    $webpSize = Get-FileSizeKB $webpPath
                    $totalOptimizedSize += $webpSize
                    Write-Host "  WebP creado: $baseName.webp ($webpSize KB)" -ForegroundColor Green
                }
                
                # Convertir a JPG (fallback para navegadores antiguos)
                if (-not (Test-Path $jpgPath) -or $file.LastWriteTime -gt (Get-Item $jpgPath -ErrorAction SilentlyContinue).LastWriteTime) {
                    if ($file.Extension -eq ".svg") {
                        magick "$($file.FullName)" -resize "800x600>" -quality 80 -strip "$jpgPath"
                    } else {
                        # Optimizar JPG existente
                        magick "$($file.FullName)" -resize "800x600>" -quality 80 -strip -interlace Plane "$jpgPath"
                    }
                    $jpgSize = Get-FileSizeKB $jpgPath
                    Write-Host "  JPG creado/optimizado: $baseName.jpg ($jpgSize KB)" -ForegroundColor Green
                }
                
                $filesProcessed++
            } catch {
                Write-Host "  Error convirtiendo $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
            }
            }
        } else {
            Write-Host "  → Archivo listo (instala ImageMagick para optimización)" -ForegroundColor Gray
        }
    }
}

Write-Host "`nOptimizando imágenes Open Graph..." -ForegroundColor Cyan

# Procesar imágenes Open Graph
$ogFiles = Get-ChildItem -Path $imagesDir -Filter "og-*.jpg" -ErrorAction SilentlyContinue

foreach ($file in $ogFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    $originalSize = Get-FileSizeKB $file.FullName
    
    if ($imageMagickAvailable) {
        try {
            # Optimizar imágenes OG existentes con compresión mejorada
            $tempPath = "$($file.FullName).tmp"
            magick "$($file.FullName)" -resize "1200x630!" -quality 85 -strip -interlace Plane "$tempPath"
            
            $optimizedSize = Get-FileSizeKB $tempPath
            if ($optimizedSize -lt $originalSize) {
                Move-Item "$tempPath" "$($file.FullName)" -Force
                $savings = $originalSize - $optimizedSize
                Write-Host "  Optimizado: $($file.Name) (ahorrado: $savings KB)" -ForegroundColor Green
                $totalOptimizedSize += $optimizedSize
            } else {
                Remove-Item "$tempPath" -Force
                Write-Host "  → Ya optimizado: $($file.Name)" -ForegroundColor Gray
                $totalOptimizedSize += $originalSize
            }
        } catch {
            Write-Host "  Error optimizando $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  → Archivo listo (instala ImageMagick para optimización)" -ForegroundColor Gray
        $totalOptimizedSize += $originalSize
    }
}
# Crea
r .htaccess mejorado para optimización de imágenes (servidores Apache)
$htaccessContent = @"
# Reglas de Optimización de Imágenes UWEB
# Configuración para mejor rendimiento y soporte WebP

<IfModule mod_expires.c>
    ExpiresActive on
    # Cache de imágenes por 1 mes
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType image/webp "access plus 1 month"
    ExpiresByType image/avif "access plus 1 month"
</IfModule>

# Compresión para imágenes
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>

# Soporte WebP automático con fallback
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Verificar si el navegador soporta WebP
    RewriteCond %{HTTP_ACCEPT} image/webp
    # Verificar si existe el reemplazo WebP
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI}.webp -f
    # Servir WebP en lugar del original
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.$2.webp [T=image/webp,L]
    
    # Para archivos sin extensión duplicada
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{DOCUMENT_ROOT}/$1.webp -f
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.webp [T=image/webp,L]
</IfModule>

# Configurar tipos MIME correctos
<IfModule mod_mime.c>
    AddType image/webp .webp
    AddType image/avif .avif
</IfModule>

# Headers de optimización
<IfModule mod_headers.c>
    # Vary header para WebP
    <FilesMatch "\.(jpe?g|png|webp)$">
        Header append Vary Accept
    </FilesMatch>
</IfModule>
"@

$htaccessPath = Join-Path $imagesDir ".htaccess"
Set-Content -Path $htaccessPath -Value $htaccessContent -Encoding UTF8
Write-Host "`n.htaccess actualizado para optimización de imágenes" -ForegroundColor Green

# Crear archivo de configuración para lazy loading
$lazyLoadJS = @'
// Lazy Loading para imágenes del portafolio
document.addEventListener("DOMContentLoaded", function() {
    // Verificar soporte para WebP
    function supportsWebP() {
        return new Promise(resolve => {
            const webP = new Image();
            webP.onload = webP.onerror = () => resolve(webP.height === 2);
            webP.src = "data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA";
        });
    }

    // Configurar lazy loading con soporte WebP
    if ("IntersectionObserver" in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    const src = img.dataset.src;
                    
                    // Usar WebP si está disponible
                    supportsWebP().then(hasWebP => {
                        if (hasWebP && src.includes(".jpg")) {
                            img.src = src.replace(".jpg", ".webp");
                        } else {
                            img.src = src;
                        }
                        img.classList.remove("lazy");
                        imageObserver.unobserve(img);
                    });
                }
            });
        });

        document.querySelectorAll("img[data-src]").forEach(img => {
            imageObserver.observe(img);
        });
    }
});
'@

$lazyLoadPath = Join-Path $imagesDir "lazy-load.js"
Set-Content -Path $lazyLoadPath -Value $lazyLoadJS -Encoding UTF8
Write-Host "Script de lazy loading creado" -ForegroundColor Green

Write-Host "`nResumen de Optimización de Imágenes:" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

if ($imageMagickAvailable -and $filesProcessed -gt 0) {
    $totalSavings = $totalOriginalSize - $totalOptimizedSize
    $percentSaved = if ($totalOriginalSize -gt 0) { [math]::Round(($totalSavings / $totalOriginalSize) * 100, 1) } else { 0 }
    
    Write-Host "• Archivos procesados: $filesProcessed" -ForegroundColor White
    Write-Host "• Tamaño original total: $totalOriginalSize KB" -ForegroundColor White
    Write-Host "• Tamaño optimizado total: $totalOptimizedSize KB" -ForegroundColor White
    Write-Host "• Espacio ahorrado: $totalSavings KB ($percentSaved%)" -ForegroundColor Green
} else {
    Write-Host "• Imágenes del portafolio: Listas para optimización" -ForegroundColor White
}

Write-Host "• Imágenes Open Graph: Optimizadas para redes sociales" -ForegroundColor White
Write-Host "• .htaccess: Configurado para servir WebP automáticamente" -ForegroundColor White
Write-Host "• Lazy loading: Script creado para carga diferida" -ForegroundColor White

if (-not $imageMagickAvailable) {
    Write-Host "`nRecomendación:" -ForegroundColor Yellow
    Write-Host "Instala ImageMagick para conversión automática a WebP y mejor optimización" -ForegroundColor Yellow
    Write-Host "Descarga: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
}

Write-Host "`n¡Optimización completada! 🚀" -ForegroundColor Green
Write-Host "Las imágenes ahora se cargan más rápido y usan menos ancho de banda." -ForegroundColor Green