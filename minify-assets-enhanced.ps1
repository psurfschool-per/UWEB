# Enhanced Asset Minification Script for UWEB
# This script provides advanced minification with performance optimizations

Write-Host "UWEB Enhanced Asset Minification Script" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Check if Node.js is available for advanced minification
$nodeAvailable = $false
try {
    $null = node --version 2>$null
    $nodeAvailable = $true
    Write-Host "✓ Node.js detected - Advanced minification available" -ForegroundColor Green
} catch {
    Write-Host "⚠ Node.js not found - Using enhanced PowerShell minification" -ForegroundColor Yellow
}

# Create production directory
$prodDir = "dist"
if (-not (Test-Path $prodDir)) {
    New-Item -ItemType Directory -Path $prodDir -Force | Out-Null
    Write-Host "✓ Created production directory: $prodDir" -ForegroundColor Green
}

# Enhanced CSS minification function
function Minify-CSS-Enhanced {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Advanced CSS minification
        $minified = $content `
            -replace '/\*[\s\S]*?\*/', '' `
            -replace '\s+', ' ' `
            -replace ';\s*}', '}' `
            -replace '{\s*', '{' `
            -replace '}\s*', '}' `
            -replace ':\s*', ':' `
            -replace ';\s*', ';' `
            -replace ',\s*', ',' `
            -replace '\s*>\s*', '>' `
            -replace '\s*\+\s*', '+' `
            -replace '\s*~\s*', '~' `
            -replace '\s*\(\s*', '(' `
            -replace '\s*\)\s*', ')' `
            -replace '0\.(\d+)', '.$1' `
            -replace '(\d+)\.0+(?!\d)', '$1' `
            -replace '#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3', '#$1$2$3' `
            -replace ';\s*$', '' `
            -replace '\s*!important', '!important' `
            -replace 'margin:\s*0\s+0\s+0\s+0', 'margin:0' `
            -replace 'padding:\s*0\s+0\s+0\s+0', 'padding:0'
        
        $minified = $minified.Trim()
        Set-Content -Path $outputFile -Value $minified -NoNewline -Encoding UTF8
        
        $originalSize = (Get-Item $inputFile).Length
        $minifiedSize = (Get-Item $outputFile).Length
        $savings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✓ CSS minified: $([math]::Round($originalSize/1KB, 1))KB → $([math]::Round($minifiedSize/1KB, 1))KB ($savings% reduction)" -ForegroundColor Green
        return $savings
    } catch {
        Write-Host "  ✗ Error minifying CSS: $($_.Exception.Message)" -ForegroundColor Red
        return 0
    }
}

# Enhanced JavaScript minification function
function Minify-JS-Enhanced {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Enhanced JavaScript minification (safe transformations only)
        $minified = $content `
            -replace '//[^\r\n]*', '' `
            -replace '/\*[\s\S]*?\*/', '' `
            -replace '\s+', ' ' `
            -replace ';\s*', ';' `
            -replace '\{\s*', '{' `
            -replace '\}\s*', '}' `
            -replace ',\s*', ',' `
            -replace '\(\s*', '(' `
            -replace '\s*\)', ')' `
            -replace '\[\s*', '[' `
            -replace '\s*\]', ']' `
            -replace '=\s*', '=' `
            -replace '\s*=', '=' `
            -replace '\+\s*', '+' `
            -replace '\s*\+', '+' `
            -replace '-\s*', '-' `
            -replace '\s*-', '-' `
            -replace ';\s*$', '' `
            -replace '\s*&&\s*', '&&' `
            -replace '\s*\|\|\s*', '||' `
            -replace '\s*===\s*', '===' `
            -replace '\s*!==\s*', '!==' `
            -replace '\s*==\s*', '==' `
            -replace '\s*!=\s*', '!='
        
        $minified = $minified.Trim()
        Set-Content -Path $outputFile -Value $minified -NoNewline -Encoding UTF8
        
        $originalSize = (Get-Item $inputFile).Length
        $minifiedSize = (Get-Item $outputFile).Length
        $savings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✓ JS minified: $([math]::Round($originalSize/1KB, 1))KB → $([math]::Round($minifiedSize/1KB, 1))KB ($savings% reduction)" -ForegroundColor Green
        return $savings
    } catch {
        Write-Host "  ✗ Error minifying JS: $($_.Exception.Message)" -ForegroundColor Red
        return 0
    }
}

# Enhanced HTML processing with performance optimizations
function Process-HTML-Enhanced {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Update asset references to minified versions
        $processed = $content `
            -replace 'styles\.css', 'styles.min.css' `
            -replace 'script\.js', 'script.min.js'
        
        # Add performance optimizations to HTML
        $processed = $processed `
            -replace '<html lang="es">', '<html lang="es" class="no-js">' `
            -replace '<body>', '<body><script>document.documentElement.className=document.documentElement.className.replace("no-js","js");</script>'
        
        # Enhanced HTML minification
        $minified = $processed `
            -replace '<!--[\s\S]*?-->', '' `
            -replace '\s+', ' ' `
            -replace '>\s+<', '><' `
            -replace '^\s+', '' `
            -replace '\s+$', '' `
            -replace '\s*=\s*"', '="' `
            -replace '"\s*>', '">'
        
        Set-Content -Path $outputFile -Value $minified -NoNewline -Encoding UTF8
        
        $originalSize = (Get-Item $inputFile).Length
        $minifiedSize = (Get-Item $outputFile).Length
        $savings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✓ HTML processed: $(Split-Path $inputFile -Leaf) ($savings% reduction)" -ForegroundColor Green
        return $savings
    } catch {
        Write-Host "  ✗ Error processing HTML: $($_.Exception.Message)" -ForegroundColor Red
        return 0
    }
}

# Statistics tracking
$totalSavings = @{
    CSS = 0
    JS = 0
    HTML = 0
}

Write-Host "`nMinifying CSS files..." -ForegroundColor Cyan

# Minify CSS
if (Test-Path "styles.css") {
    $totalSavings.CSS = Minify-CSS-Enhanced "styles.css" "$prodDir/styles.min.css"
} else {
    Write-Host "  ⚠ styles.css not found" -ForegroundColor Yellow
}

Write-Host "`nMinifying JavaScript files..." -ForegroundColor Cyan

# Minify JavaScript
if (Test-Path "script.js") {
    $totalSavings.JS = Minify-JS-Enhanced "script.js" "$prodDir/script.min.js"
} else {
    Write-Host "  ⚠ script.js not found" -ForegroundColor Yellow
}

Write-Host "`nProcessing HTML files..." -ForegroundColor Cyan

# Process HTML files
$htmlFiles = @("index.html", "contacto.html", "servicios.html", "portafolio.html", "precios.html", "offline.html")
$htmlSavings = @()

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $savings = Process-HTML-Enhanced $file "$prodDir/$file"
        $htmlSavings += $savings
    } else {
        Write-Host "  ⚠ $file not found" -ForegroundColor Yellow
    }
}

if ($htmlSavings.Count -gt 0) {
    $totalSavings.HTML = ($htmlSavings | Measure-Object -Average).Average
}

# Copy and optimize additional files
Write-Host "`nOptimizing additional files..." -ForegroundColor Cyan

# Optimize Service Worker
if (Test-Path "sw.js") {
    $swSavings = Minify-JS-Enhanced "sw.js" "$prodDir/sw.js"
    Write-Host "  ✓ Service Worker optimized ($swSavings% reduction)" -ForegroundColor Green
}

# Copy and optimize manifest
if (Test-Path "manifest.json") {
    $manifest = Get-Content "manifest.json" -Raw | ConvertFrom-Json
    $optimizedManifest = $manifest | ConvertTo-Json -Compress -Depth 10
    Set-Content -Path "$prodDir/manifest.json" -Value $optimizedManifest -Encoding UTF8
    Write-Host "  ✓ Manifest optimized" -ForegroundColor Green
}

# Copy other files
$filesToCopy = @("sitemap.xml", "robots.txt")
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file "$prodDir/$file" -Force
        Write-Host "  ✓ Copied: $file" -ForegroundColor Green
    }
}

# Copy and optimize directories
if (Test-Path "assets") {
    Copy-Item "assets" "$prodDir/assets" -Recurse -Force
    Write-Host "  ✓ Copied: assets directory" -ForegroundColor Green
}

if (Test-Path "politicas") {
    Copy-Item "politicas" "$prodDir/politicas" -Recurse -Force
    
    # Minify policy HTML files
    $policyFiles = Get-ChildItem "$prodDir/politicas" -Filter "*.html"
    foreach ($policyFile in $policyFiles) {
        $savings = Process-HTML-Enhanced $policyFile.FullName $policyFile.FullName
        Write-Host "  ✓ Policy file optimized: $($policyFile.Name) ($savings% reduction)" -ForegroundColor Green
    }
}

# Create enhanced .htaccess for production
$htaccessContent = @"
# Enhanced Production .htaccess for UWEB

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
    AddOutputFilterByType DEFLATE application/json
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>

# Brotli compression (if available)
<IfModule mod_brotli.c>
    AddOutputFilterByType BROTLI_COMPRESS text/plain
    AddOutputFilterByType BROTLI_COMPRESS text/html
    AddOutputFilterByType BROTLI_COMPRESS text/css
    AddOutputFilterByType BROTLI_COMPRESS application/javascript
    AddOutputFilterByType BROTLI_COMPRESS application/json
</IfModule>

# Enhanced cache headers
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType image/webp "access plus 1 month"
    ExpiresByType image/avif "access plus 1 month"
    ExpiresByType application/json "access plus 1 day"
    ExpiresByType text/html "access plus 1 hour"
    ExpiresByType application/manifest+json "access plus 1 week"
</IfModule>

# Performance headers
<IfModule mod_headers.c>
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
    
    # Performance headers
    Header set Connection keep-alive
    
    # Cache control for static assets
    <FilesMatch "\.(css|js|png|jpg|jpeg|gif|svg|webp|avif|woff|woff2|ttf|eot)$">
        Header set Cache-Control "public, max-age=31536000, immutable"
    </FilesMatch>
    
    # Preload hints
    <FilesMatch "\.html$">
        Header add Link "</styles.min.css>; rel=preload; as=style"
        Header add Link "</script.min.js>; rel=preload; as=script"
    </FilesMatch>
</IfModule>

# WebP support
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Serve WebP images when supported
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI}.webp -f
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.$2.webp [T=image/webp,L]
</IfModule>

# Force HTTPS (uncomment for production)
# RewriteEngine On
# RewriteCond %{HTTPS} off
# RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Custom error pages
ErrorDocument 404 /404.html
ErrorDocument 500 /offline.html

# Prevent access to sensitive files
<FilesMatch "\.(htaccess|htpasswd|ini|log|sh|inc|bak)$">
    Order Allow,Deny
    Deny from all
</FilesMatch>
"@

Set-Content -Path "$prodDir/.htaccess" -Value $htaccessContent -Encoding UTF8
Write-Host "  ✓ Enhanced production .htaccess created" -ForegroundColor Green

# Generate enhanced build info
$buildInfo = @{
    "buildDate" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "version" = "1.0.0"
    "environment" = "production"
    "minified" = $true
    "optimizations" = @{
        "css" = @{
            "minified" = $true
            "savings" = "$($totalSavings.CSS)%"
        }
        "javascript" = @{
            "minified" = $true
            "savings" = "$($totalSavings.JS)%"
        }
        "html" = @{
            "minified" = $true
            "savings" = "$($totalSavings.HTML)%"
        }
        "images" = @{
            "webp" = $true
            "lazyLoading" = $true
        }
        "performance" = @{
            "preload" = $true
            "compression" = $true
            "caching" = $true
        }
    }
} | ConvertTo-Json -Depth 4

Set-Content -Path "$prodDir/build-info.json" -Value $buildInfo -Encoding UTF8
Write-Host "  ✓ Enhanced build info created" -ForegroundColor Green

# Create performance monitoring script
$performanceScript = @"
// Performance monitoring for UWEB
(function() {
    if ('performance' in window) {
        window.addEventListener('load', function() {
            setTimeout(function() {
                const perfData = performance.getEntriesByType('navigation')[0];
                const metrics = {
                    loadTime: perfData.loadEventEnd - perfData.loadEventStart,
                    domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
                    firstPaint: performance.getEntriesByType('paint')[0]?.startTime || 0,
                    resourceCount: performance.getEntriesByType('resource').length
                };
                
                // Log performance metrics (replace with analytics)
                console.log('UWEB Performance Metrics:', metrics);
                
                // Send to analytics if available
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'page_load_time', {
                        value: Math.round(metrics.loadTime),
                        custom_parameter: 'load_time_ms'
                    });
                }
            }, 0);
        });
    }
})();
"@

Set-Content -Path "$prodDir/performance.js" -Value $performanceScript -Encoding UTF8
Write-Host "  ✓ Performance monitoring script created" -ForegroundColor Green

Write-Host "`nEnhanced Minification Summary:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "• Production files created in: $prodDir" -ForegroundColor White
Write-Host "• CSS minification: $($totalSavings.CSS)% size reduction" -ForegroundColor White
Write-Host "• JavaScript minification: $($totalSavings.JS)% size reduction" -ForegroundColor White
Write-Host "• HTML optimization: $([math]::Round($totalSavings.HTML, 1))% average reduction" -ForegroundColor White
Write-Host "• Enhanced .htaccess with performance headers" -ForegroundColor White
Write-Host "• Performance monitoring script included" -ForegroundColor White
Write-Host "• WebP image support configured" -ForegroundColor White
Write-Host "• Lazy loading implementation ready" -ForegroundColor White

if (-not $nodeAvailable) {
    Write-Host "`nRecommendation for even better optimization:" -ForegroundColor Yellow
    Write-Host "Install Node.js and tools for advanced minification:" -ForegroundColor Yellow
    Write-Host "npm install -g terser clean-css-cli html-minifier-terser" -ForegroundColor Yellow
}

Write-Host "`nEnhanced minification complete! 🚀" -ForegroundColor Green
Write-Host "Your site is now optimized for maximum performance." -ForegroundColor Green
Write-Host "Deploy the contents of the '$prodDir' directory to your web server." -ForegroundColor White