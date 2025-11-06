# Script Mejorado de Optimización de Imágenes UWEB
# Optimiza imágenes del portafolio para mejor rendimiento web

Write-Host "=== OPTIMIZACIÓN DE IMÁGENES UWEB ===" -ForegroundColor Green
Write-Host "Procesando imágenes del portafolio..." -ForegroundColor Cyan

# Función para obtener tamaño de archivo en KB
function Get-FileSizeKB($filePath) {
    if (Test-Path $filePath) {
        return [math]::Round((Get-Item $filePath).Length / 1KB, 2)
    }
    return 0
}

# Función para crear versiones optimizadas manualmente
function Create-OptimizedVersions($sourceFile, $targetDir) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile.Name)
    $extension = $sourceFile.Extension.ToLower()
    
    # Rutas de destino
    $webpPath = Join-Path $targetDir "$baseName.webp"
    $jpgPath = Join-Path $targetDir "$baseName.jpg"
    
    $results = @{
        WebP = $false
        JPG = $false
        OriginalSize = Get-FileSizeKB $sourceFile.FullName
    }
    
    # Verificar ImageMagick
    $imageMagickAvailable = $false
    try {
        $null = magick -version 2>$null
        $imageMagickAvailable = $true
    } catch {
        # ImageMagick no disponible
    }
    
    if ($imageMagickAvailable) {
        try {
            # Crear WebP optimizado
            if (-not (Test-Path $webpPath)) {
                if ($extension -eq ".svg") {
                    magick $sourceFile.FullName -background white -flatten -resize "800x600>" -quality 85 -strip $webpPath
                } else {
                    magick $sourceFile.FullName -resize "800x600>" -quality 85 -strip $webpPath
                }
                $results.WebP = $true
            }
            
            # Crear JPG optimizado
            if (-not (Test-Path $jpgPath)) {
                if ($extension -eq ".svg") {
                    magick $sourceFile.FullName -background white -flatten -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
                } else {
                    magick $sourceFile.FullName -resize "800x600>" -quality 80 -strip -interlace Plane $jpgPath
                }
                $results.JPG = $true
            }
        } catch {
            Write-Host "    Error con ImageMagick: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        # Método alternativo: copiar archivos existentes como base
        if ($extension -eq ".jpg" -or $extension -eq ".jpeg") {
            if (-not (Test-Path $jpgPath)) {
                Copy-Item $sourceFile.FullName $jpgPath
                $results.JPG = $true
            }
        }
        
        Write-Host "    ImageMagick no disponible - usando método básico" -ForegroundColor Yellow
    }
    
    return $results
}

# Directorio del portafolio
$portfolioDir = "assets/images/portfolio"

if (-not (Test-Path $portfolioDir)) {
    Write-Host "Creando directorio del portafolio..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $portfolioDir -Force | Out-Null
}

# Obtener archivos de imagen
$imageFiles = Get-ChildItem -Path $portfolioDir -Include "*.svg", "*.jpg", "*.jpeg", "*.png" -ErrorAction SilentlyContinue

Write-Host "Encontrados $($imageFiles.Count) archivos para procesar" -ForegroundColor White
Write-Host ""

$stats = @{
    TotalFiles = $imageFiles.Count
    WebPCreated = 0
    JPGCreated = 0
    TotalOriginalSize = 0
    TotalOptimizedSize = 0
}

foreach ($file in $imageFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    $originalSize = Get-FileSizeKB $file.FullName
    $stats.TotalOriginalSize += $originalSize
    
    $result = Create-OptimizedVersions $file $portfolioDir
    
    if ($result.WebP) {
        $webpSize = Get-FileSizeKB (Join-Path $portfolioDir "$([System.IO.Path]::GetFileNameWithoutExtension($file.Name)).webp")
        Write-Host "  ✓ WebP creado: $webpSize KB" -ForegroundColor Green
        $stats.WebPCreated++
        $stats.TotalOptimizedSize += $webpSize
    }
    
    if ($result.JPG) {
        $jpgSize = Get-FileSizeKB (Join-Path $portfolioDir "$([System.IO.Path]::GetFileNameWithoutExtension($file.Name)).jpg")
        Write-Host "  ✓ JPG optimizado: $jpgSize KB" -ForegroundColor Green
        $stats.JPGCreated++
        $stats.TotalOptimizedSize += $jpgSize
    }
    
    if (-not $result.WebP -and -not $result.JPG) {
        Write-Host "  - Sin cambios (archivos ya optimizados)" -ForegroundColor Gray
    }
}

Write-Host ""

# Crear/actualizar .htaccess para servir WebP automáticamente
$htaccessContent = @'
# Optimización de Imágenes UWEB - Configuración Apache
# Sirve automáticamente WebP cuando está disponible y es soportado

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
    
    # Servir WebP automáticamente si el navegador lo soporta
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{REQUEST_FILENAME} \.(jpe?g|png)$
    RewriteCond %{REQUEST_FILENAME}.webp -f
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.$2.webp [T=image/webp,E=accept:1,L]
</IfModule>

<IfModule mod_headers.c>
    # Añadir cabecera Vary para cache correcto
    Header append Vary Accept env=REDIRECT_accept
</IfModule>

<IfModule mod_mime.c>
    # Definir tipo MIME para WebP
    AddType image/webp .webp
</IfModule>

# Compresión gzip para imágenes SVG
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>
'@

$htaccessPath = "assets/images/.htaccess"
Set-Content -Path $htaccessPath -Value $htaccessContent -Encoding UTF8
Write-Host "✓ .htaccess actualizado para optimización automática" -ForegroundColor Green

# Crear configuración de lazy loading mejorada
$lazyLoadJS = @'
// Lazy Loading Mejorado para Imágenes UWEB
// Carga diferida con soporte para WebP automático

class UWEBImageOptimizer {
    constructor() {
        this.supportsWebP = false;
        this.checkWebPSupport();
        this.initLazyLoading();
    }
    
    // Detectar soporte para WebP
    checkWebPSupport() {
        const webP = new Image();
        webP.onload = webP.onerror = () => {
            this.supportsWebP = (webP.height === 2);
        };
        webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
    }
    
    // Inicializar lazy loading
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
            }, {
                rootMargin: '50px 0px'
            });
            
            document.querySelectorAll('img[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        } else {
            // Fallback para navegadores antiguos
            this.loadAllImages();
        }
    }
    
    // Cargar imagen optimizada
    loadOptimizedImage(img) {
        const src = img.dataset.src;
        if (!src) return;
        
        // Intentar cargar WebP si es soportado
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
    
    // Cargar todas las imágenes (fallback)
    loadAllImages() {
        document.querySelectorAll('img[data-src]').forEach(img => {
            this.loadOptimizedImage(img);
        });
    }
}

// Inicializar cuando el DOM esté listo
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new UWEBImageOptimizer();
    });
} else {
    new UWEBImageOptimizer();
}
'@

Set-Content -Path "assets/images/lazy-load-enhanced.js" -Value $lazyLoadJS -Encoding UTF8
Write-Host "✓ Sistema de lazy loading mejorado creado" -ForegroundColor Green

# Crear CSS adicional para las imágenes optimizadas
$imageCSS = @'
/* Estilos para imágenes optimizadas del portafolio UWEB */
img[data-src] {
    opacity: 0;
    transition: opacity 0.3s ease;
}

img.loaded {
    opacity: 1;
}

.portfolio-image {
    background-color: #f5f5f5;
    background-image: linear-gradient(45deg, #f0f0f0 25%, transparent 25%), 
                      linear-gradient(-45deg, #f0f0f0 25%, transparent 25%), 
                      linear-gradient(45deg, transparent 75%, #f0f0f0 75%), 
                      linear-gradient(-45deg, transparent 75%, #f0f0f0 75%);
    background-size: 20px 20px;
    background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
}

.portfolio-image.loaded {
    background-image: none;
}
'@

Set-Content -Path "assets/images/portfolio-images.css" -Value $imageCSS -Encoding UTF8
Write-Host "✓ CSS para imágenes optimizadas creado" -ForegroundColor Green

# Generar reporte de optimización
$compressionRatio = if ($stats.TotalOriginalSize -gt 0) { 
    [math]::Round((1 - ($stats.TotalOptimizedSize / $stats.TotalOriginalSize)) * 100, 1) 
} else { 0 }

Write-Host ""
Write-Host "=== RESUMEN DE OPTIMIZACIÓN ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $($stats.TotalFiles)" -ForegroundColor White
Write-Host "Archivos WebP creados: $($stats.WebPCreated)" -ForegroundColor White
Write-Host "Archivos JPG optimizados: $($stats.JPGCreated)" -ForegroundColor White
Write-Host "Tamaño original total: $($stats.TotalOriginalSize) KB" -ForegroundColor White
Write-Host "Tamaño optimizado total: $($stats.TotalOptimizedSize) KB" -ForegroundColor White
Write-Host "Compresión estimada: $compressionRatio%" -ForegroundColor Green

Write-Host ""
Write-Host "✓ Optimización de imágenes completada" -ForegroundColor Green
Write-Host "✓ Configuración Apache (.htaccess) actualizada" -ForegroundColor Green
Write-Host "✓ Sistema de lazy loading mejorado implementado" -ForegroundColor Green

# Verificar ImageMagick para futuras optimizaciones
try {
    $null = magick -version 2>$null
    Write-Host ""
    Write-Host "✓ ImageMagick disponible para optimizaciones futuras" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "⚠ Para optimización completa, considera instalar ImageMagick:" -ForegroundColor Yellow
    Write-Host "  https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 Optimización de imágenes del portafolio completada!" -ForegroundColor Green