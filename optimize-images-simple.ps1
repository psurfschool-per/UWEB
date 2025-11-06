# Script Simple de Optimización de Imágenes UWEB
Write-Host "=== OPTIMIZACIÓN DE IMÁGENES UWEB ===" -ForegroundColor Green

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

# Verificar ImageMagick
$imageMagickAvailable = $false
try {
    $null = magick -version 2>$null
    $imageMagickAvailable = $true
    Write-Host "✓ ImageMagick disponible" -ForegroundColor Green
} catch {
    Write-Host "⚠ ImageMagick no encontrado - usando método básico" -ForegroundColor Yellow
}

# Obtener archivos de imagen
$imageFiles = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png" -ErrorAction SilentlyContinue
Write-Host "Encontrados $($imageFiles.Count) archivos para procesar" -ForegroundColor White

$filesProcessed = 0
$totalOriginalSize = 0
$totalOptimizedSize = 0

foreach ($file in $imageFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    $originalSize = Get-FileSizeKB $file.FullName
    $totalOriginalSize += $originalSize
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $webpPath = Join-Path $portfolioDir "$baseName.webp"
    $jpgPath = Join-Path $portfolioDir "$baseName.jpg"
    
    if ($imageMagickAvailable) {
        try {
            # Crear WebP si no existe
            if (-not (Test-Path $webpPath)) {
                if ($file.Extension -eq ".svg") {
                    magick $file.FullName -background white -flatten -resize "800x600>" -quality 85 -strip $webpPath
                } else {
                    magick $file.FullName -resize "800x600>" -quality 85 -strip $webpPath
                }
                $webpSize = Get-FileSizeKB $webpPath
                Write-Host "  ✓ WebP creado: $webpSize KB" -ForegroundColor Green
                $totalOptimizedSize += $webpSize
            }
            
            # Crear JPG si no existe
            if (-not (Test-Path $jpgPath)) {
                if ($file.Extension -eq ".svg") {
                    magick $file.FullName -background white -flatten -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
                } else {
                    magick $file.FullName -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
                }
                $jpgSize = Get-FileSizeKB $jpgPath
                Write-Host "  ✓ JPG optimizado: $jpgSize KB" -ForegroundColor Green
                $totalOptimizedSize += $jpgSize
            }
            
            $filesProcessed++
        } catch {
            Write-Host "  ✗ Error procesando: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        # Método básico sin ImageMagick
        if ($file.Extension -eq ".jpg" -or $file.Extension -eq ".jpeg") {
            if (-not (Test-Path $jpgPath)) {
                Copy-Item $file.FullName $jpgPath
                Write-Host "  ✓ JPG copiado como base" -ForegroundColor Yellow
            }
        }
        Write-Host "  - Instala ImageMagick para optimización completa" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== CONFIGURANDO SERVIDOR ===" -ForegroundColor Cyan

# Crear .htaccess optimizado
$htaccessContent = @'
# Optimización de Imágenes UWEB
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/webp "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
</IfModule>

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{REQUEST_FILENAME} \.(jpe?g|png)$
    RewriteCond %{REQUEST_FILENAME}.webp -f
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.$2.webp [T=image/webp,E=accept:1,L]
</IfModule>

<IfModule mod_headers.c>
    Header append Vary Accept env=REDIRECT_accept
</IfModule>

<IfModule mod_mime.c>
    AddType image/webp .webp
</IfModule>

<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>
'@

Set-Content -Path "assets/images/.htaccess" -Value $htaccessContent -Encoding UTF8
Write-Host "✓ .htaccess actualizado" -ForegroundColor Green

# Crear JavaScript de lazy loading
$lazyLoadJS = @'
// Lazy Loading para Imágenes UWEB
class UWEBImageOptimizer {
    constructor() {
        this.supportsWebP = false;
        this.checkWebPSupport();
        this.initLazyLoading();
    }
    
    checkWebPSupport() {
        const webP = new Image();
        webP.onload = webP.onerror = () => {
            this.supportsWebP = (webP.height === 2);
        };
        webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
    }
    
    initLazyLoading() {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        this.loadOptimizedImage(img);
                        observer.unobserve(img);
                    }
                });
            }, { rootMargin: '50px 0px' });
            
            document.querySelectorAll('img[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        } else {
            this.loadAllImages();
        }
    }
    
    loadOptimizedImage(img) {
        const src = img.dataset.src;
        if (!src) return;
        
        if (this.supportsWebP && src.match(/\.(jpe?g|png)$/i)) {
            const webpSrc = src.replace(/\.(jpe?g|png)$/i, '.webp');
            const webpImg = new Image();
            webpImg.onload = () => {
                img.src = webpSrc;
                img.classList.add('loaded');
            };
            webpImg.onerror = () => {
                img.src = src;
                img.classList.add('loaded');
            };
            webpImg.src = webpSrc;
        } else {
            img.src = src;
            img.classList.add('loaded');
        }
    }
    
    loadAllImages() {
        document.querySelectorAll('img[data-src]').forEach(img => {
            this.loadOptimizedImage(img);
        });
    }
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => new UWEBImageOptimizer());
} else {
    new UWEBImageOptimizer();
}
'@

Set-Content -Path "assets/images/lazy-load-enhanced.js" -Value $lazyLoadJS -Encoding UTF8
Write-Host "✓ Sistema de lazy loading creado" -ForegroundColor Green

# Crear CSS para imágenes
$imageCSS = @'
img[data-src] {
    opacity: 0;
    transition: opacity 0.3s ease;
}

img.loaded {
    opacity: 1;
}

.portfolio-image {
    background-color: #f5f5f5;
    background-size: 20px 20px;
}

.portfolio-image.loaded {
    background-image: none;
}
'@

Set-Content -Path "assets/images/portfolio-images.css" -Value $imageCSS -Encoding UTF8
Write-Host "✓ CSS para imágenes creado" -ForegroundColor Green

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $filesProcessed" -ForegroundColor White
Write-Host "Tamaño original total: $totalOriginalSize KB" -ForegroundColor White

if ($totalOptimizedSize -gt 0) {
    $compressionRatio = [math]::Round((1 - ($totalOptimizedSize / $totalOriginalSize)) * 100, 1)
    Write-Host "Tamaño optimizado: $totalOptimizedSize KB" -ForegroundColor White
    Write-Host "Compresión: $compressionRatio%" -ForegroundColor Green
}

Write-Host ""
Write-Host "✓ Optimización completada" -ForegroundColor Green
Write-Host "✓ Configuración del servidor lista" -ForegroundColor Green
Write-Host "✓ Sistema de lazy loading implementado" -ForegroundColor Green

if (-not $imageMagickAvailable) {
    Write-Host ""
    Write-Host "Para optimización completa, instala ImageMagick:" -ForegroundColor Yellow
    Write-Host "https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 Optimización de imágenes completada!" -ForegroundColor Green