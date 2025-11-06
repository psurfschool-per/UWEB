# Performance Minification Script for UWEB
Write-Host "UWEB Performance Minification Script" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Create production directory
$prodDir = "dist"
if (-not (Test-Path $prodDir)) {
    New-Item -ItemType Directory -Path $prodDir -Force | Out-Null
    Write-Host "Created production directory: $prodDir" -ForegroundColor Green
}

Write-Host "`nMinifying CSS files..." -ForegroundColor Cyan
if (Test-Path "styles.css") {
    $cssContent = Get-Content "styles.css" -Raw
    $cssMinified = $cssContent -replace '/\*[\s\S]*?\*/', ''
    $cssMinified = $cssMinified -replace '\s+', ' '
    $cssMinified = $cssMinified -replace ';\s*}', '}'
    $cssMinified = $cssMinified -replace '{\s*', '{'
    $cssMinified = $cssMinified -replace '}\s*', '}'
    $cssMinified = $cssMinified -replace ':\s*', ':'
    $cssMinified = $cssMinified -replace ';\s*', ';'
    $cssMinified = $cssMinified -replace ',\s*', ','
    $cssMinified = $cssMinified.Trim()
    
    Set-Content -Path "$prodDir/styles.min.css" -Value $cssMinified -NoNewline -Encoding UTF8
    
    $originalSize = (Get-Item "styles.css").Length
    $minifiedSize = (Get-Item "$prodDir/styles.min.css").Length
    $cssSavings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
    
    Write-Host "CSS minified: $([math]::Round($originalSize/1KB, 1))KB -> $([math]::Round($minifiedSize/1KB, 1))KB ($cssSavings% reduction)" -ForegroundColor Green
} else {
    Write-Host "styles.css not found" -ForegroundColor Yellow
    $cssSavings = 0
}

Write-Host "`nMinifying JavaScript files..." -ForegroundColor Cyan
if (Test-Path "script.js") {
    $jsContent = Get-Content "script.js" -Raw
    $jsMinified = $jsContent -replace '//.*$', ''
    $jsMinified = $jsMinified -replace '/\*[\s\S]*?\*/', ''
    $jsMinified = $jsMinified -replace '\s+', ' '
    $jsMinified = $jsMinified -replace ';\s*', ';'
    $jsMinified = $jsMinified -replace ',\s*', ','
    $jsMinified = $jsMinified.Trim()
    
    Set-Content -Path "$prodDir/script.min.js" -Value $jsMinified -NoNewline -Encoding UTF8
    
    $originalSize = (Get-Item "script.js").Length
    $minifiedSize = (Get-Item "$prodDir/script.min.js").Length
    $jsSavings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
    
    Write-Host "JS minified: $([math]::Round($originalSize/1KB, 1))KB -> $([math]::Round($minifiedSize/1KB, 1))KB ($jsSavings% reduction)" -ForegroundColor Green
} else {
    Write-Host "script.js not found" -ForegroundColor Yellow
    $jsSavings = 0
}

Write-Host "`nProcessing HTML files..." -ForegroundColor Cyan
$htmlFiles = @("index.html", "contacto.html", "servicios.html", "portafolio.html", "precios.html")
$htmlSavings = @()

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $htmlContent = Get-Content $file -Raw
        $htmlProcessed = $htmlContent -replace 'styles\.css', 'styles.min.css'
        $htmlProcessed = $htmlProcessed -replace 'script\.js', 'script.min.js'
        $htmlMinified = $htmlProcessed -replace '<!--[\s\S]*?-->', ''
        $htmlMinified = $htmlMinified -replace '\s+', ' '
        $htmlMinified = $htmlMinified -replace '>\s+<', '><'
        $htmlMinified = $htmlMinified.Trim()
        
        Set-Content -Path "$prodDir/$file" -Value $htmlMinified -NoNewline -Encoding UTF8
        
        $originalSize = (Get-Item $file).Length
        $minifiedSize = (Get-Item "$prodDir/$file").Length
        $savings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
        $htmlSavings += $savings
        
        Write-Host "HTML processed: $file ($savings% reduction)" -ForegroundColor Green
    } else {
        Write-Host "$file not found" -ForegroundColor Yellow
    }
}

Write-Host "`nCopying additional files..." -ForegroundColor Cyan
$filesToCopy = @("manifest.json", "sw.js", "sitemap.xml", "robots.txt")
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file "$prodDir/$file" -Force
        Write-Host "Copied: $file" -ForegroundColor Green
    }
}

if (Test-Path "assets") {
    Copy-Item "assets" "$prodDir/assets" -Recurse -Force
    Write-Host "Copied: assets directory" -ForegroundColor Green
}

if (Test-Path "politicas") {
    Copy-Item "politicas" "$prodDir/politicas" -Recurse -Force
    Write-Host "Copied: politicas directory" -ForegroundColor Green
}

# Create performance .htaccess
$htaccessContent = @"
# Performance Optimized .htaccess for UWEB

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/json
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>

# Cache headers
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/webp "access plus 1 month"
    ExpiresByType text/html "access plus 1 hour"
</IfModule>

# Performance headers
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header set Connection keep-alive
</IfModule>
"@

Set-Content -Path "$prodDir/.htaccess" -Value $htaccessContent -Encoding UTF8
Write-Host "Performance .htaccess created" -ForegroundColor Green

Write-Host "`nMinification Summary:" -ForegroundColor Cyan
Write-Host "CSS minification: $cssSavings% size reduction" -ForegroundColor White
Write-Host "JavaScript minification: $jsSavings% size reduction" -ForegroundColor White
if ($htmlSavings.Count -gt 0) {
    $avgHtmlSavings = ($htmlSavings | Measure-Object -Average).Average
    Write-Host "HTML optimization: $([math]::Round($avgHtmlSavings, 1))% average reduction" -ForegroundColor White
}
Write-Host "`nMinification complete!" -ForegroundColor Green