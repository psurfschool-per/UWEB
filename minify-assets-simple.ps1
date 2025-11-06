# Simple Enhanced Asset Minification Script for UWEB
Write-Host "UWEB Simple Enhanced Minification Script" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Create production directory
$prodDir = "dist"
if (-not (Test-Path $prodDir)) {
    New-Item -ItemType Directory -Path $prodDir -Force | Out-Null
    Write-Host "✓ Created production directory: $prodDir" -ForegroundColor Green
}

# Simple CSS minification
function Minify-CSS-Simple {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Basic CSS minification
        $minified = $content -replace '/\*[\s\S]*?\*/', ''
        $minified = $minified -replace '\s+', ' '
        $minified = $minified -replace ';\s*}', '}'
        $minified = $minified -replace '{\s*', '{'
        $minified = $minified -replace '}\s*', '}'
        $minified = $minified -replace ':\s*', ':'
        $minified = $minified -replace ';\s*', ';'
        $minified = $minified -replace ',\s*', ','
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

# Simple JavaScript minification
function Minify-JS-Simple {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Basic JavaScript minification
        $minified = $content -replace '//.*$', ''
        $minified = $minified -replace '/\*[\s\S]*?\*/', ''
        $minified = $minified -replace '\s+', ' '
        $minified = $minified -replace ';\s*', ';'
        $minified = $minified -replace ',\s*', ','
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

# Process HTML files
function Process-HTML-Simple {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Update asset references to minified versions
        $processed = $content -replace 'styles\.css', 'styles.min.css'
        $processed = $processed -replace 'script\.js', 'script.min.js'
        
        # Basic HTML minification
        $minified = $processed -replace '<!--[\s\S]*?-->', ''
        $minified = $minified -replace '\s+', ' '
        $minified = $minified -replace '>\s+<', '><'
        $minified = $minified.Trim()
        
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

Write-Host "`nMinifying CSS files..." -ForegroundColor Cyan
if (Test-Path "styles.css") {
    $cssSavings = Minify-CSS-Simple "styles.css" "$prodDir/styles.min.css"
} else {
    Write-Host "  ⚠ styles.css not found" -ForegroundColor Yellow
    $cssSavings = 0
}

Write-Host "`nMinifying JavaScript files..." -ForegroundColor Cyan
if (Test-Path "script.js") {
    $jsSavings = Minify-JS-Simple "script.js" "$prodDir/script.min.js"
} else {
    Write-Host "  ⚠ script.js not found" -ForegroundColor Yellow
    $jsSavings = 0
}

Write-Host "`nProcessing HTML files..." -ForegroundColor Cyan
$htmlFiles = @("index.html", "contacto.html", "servicios.html", "portafolio.html", "precios.html")
$htmlSavings = @()

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $savings = Process-HTML-Simple $file "$prodDir/$file"
        $htmlSavings += $savings
    } else {
        Write-Host "  ⚠ $file not found" -ForegroundColor Yellow
    }
}

# Copy additional files
Write-Host "`nCopying additional files..." -ForegroundColor Cyan

$filesToCopy = @("manifest.json", "sw.js", "sitemap.xml", "robots.txt")
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file "$prodDir/$file" -Force
        Write-Host "  ✓ Copied: $file" -ForegroundColor Green
    }
}

# Copy directories
if (Test-Path "assets") {
    Copy-Item "assets" "$prodDir/assets" -Recurse -Force
    Write-Host "  ✓ Copied: assets directory" -ForegroundColor Green
}

if (Test-Path "politicas") {
    Copy-Item "politicas" "$prodDir/politicas" -Recurse -Force
    Write-Host "  ✓ Copied: politicas directory" -ForegroundColor Green
}

# Create performance-optimized .htaccess
$htaccessContent = @"
# Performance Optimized .htaccess for UWEB

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

# Cache headers for performance
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
    ExpiresByType text/html "access plus 1 hour"
</IfModule>

# Performance headers
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header set Connection keep-alive
    
    <FilesMatch "\.(css|js|png|jpg|jpeg|gif|svg|webp)$">
        Header set Cache-Control "public, max-age=31536000, immutable"
    </FilesMatch>
</IfModule>

# WebP support
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_ACCEPT} image/webp
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI}.webp -f
    RewriteRule ^(.+)\.(jpe?g|png)$ $1.$2.webp [T=image/webp,L]
</IfModule>
"@

Set-Content -Path "$prodDir/.htaccess" -Value $htaccessContent -Encoding UTF8
Write-Host "  ✓ Performance .htaccess created" -ForegroundColor Green

# Summary
Write-Host "`nMinification Summary:" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host "• CSS minification: $cssSavings% size reduction" -ForegroundColor White
Write-Host "• JavaScript minification: $jsSavings% size reduction" -ForegroundColor White
if ($htmlSavings.Count -gt 0) {
    $avgHtmlSavings = ($htmlSavings | Measure-Object -Average).Average
    Write-Host "• HTML optimization: $([math]::Round($avgHtmlSavings, 1))% average reduction" -ForegroundColor White
}
Write-Host "• Performance .htaccess configured" -ForegroundColor White
Write-Host "• All assets copied to production directory" -ForegroundColor White

Write-Host "`nMinification complete! 🚀" -ForegroundColor Green
Write-Host "Deploy the contents of the '$prodDir' directory to your web server." -ForegroundColor White