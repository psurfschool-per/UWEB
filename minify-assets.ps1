# Asset Minification Script for UWEB
# This script minifies CSS and JavaScript files for production

Write-Host "UWEB Asset Minification Script" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Check if Node.js is available
$nodeAvailable = $false
try {
    $null = node --version 2>$null
    $nodeAvailable = $true
    Write-Host "✓ Node.js detected - Advanced minification available" -ForegroundColor Green
} catch {
    Write-Host "⚠ Node.js not found - Basic minification only" -ForegroundColor Yellow
    Write-Host "  Install Node.js for better minification: https://nodejs.org/" -ForegroundColor Yellow
}

# Create production directory
$prodDir = "dist"
if (-not (Test-Path $prodDir)) {
    New-Item -ItemType Directory -Path $prodDir -Force | Out-Null
    Write-Host "✓ Created production directory: $prodDir" -ForegroundColor Green
}

# Function to minify CSS (enhanced)
function Minify-CSS {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Enhanced CSS minification
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
            -replace ';\s*$', ''
        
        $minified = $minified.Trim()
        Set-Content -Path $outputFile -Value $minified -NoNewline
        
        $originalSize = (Get-Item $inputFile).Length
        $minifiedSize = (Get-Item $outputFile).Length
        $savings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✓ CSS minified: $([math]::Round($originalSize/1KB, 1))KB → $([math]::Round($minifiedSize/1KB, 1))KB ($savings% reduction)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error minifying CSS: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to minify JavaScript (basic)
function Minify-JS {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Basic JavaScript minification (very conservative)
        $minified = $content `
            -replace '//.*$', '' `
            -replace '/\*[\s\S]*?\*/', '' `
            -replace '\s+', ' ' `
            -replace ';\s*', ';' `
            -replace '{\s*', '{' `
            -replace '}\s*', '}' `
            -replace ',\s*', ',' `
            -replace '\(\s*', '(' `
            -replace '\s*\)', ')'
        
        $minified = $minified.Trim()
        Set-Content -Path $outputFile -Value $minified -NoNewline
        
        $originalSize = (Get-Item $inputFile).Length
        $minifiedSize = (Get-Item $outputFile).Length
        $savings = [math]::Round((($originalSize - $minifiedSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✓ JS minified: $([math]::Round($originalSize/1KB, 1))KB → $([math]::Round($minifiedSize/1KB, 1))KB ($savings% reduction)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error minifying JS: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to copy and process HTML files
function Process-HTML {
    param($inputFile, $outputFile)
    
    try {
        $content = Get-Content $inputFile -Raw
        
        # Update asset references to minified versions
        $processed = $content `
            -replace 'styles\.css', 'styles.min.css' `
            -replace 'script\.js', 'script.min.js'
        
        # Basic HTML minification
        $minified = $processed `
            -replace '<!--[\s\S]*?-->', '' `
            -replace '\s+', ' ' `
            -replace '>\s+<', '><' `
            -replace '^\s+', '' `
            -replace '\s+$', ''
        
        Set-Content -Path $outputFile -Value $minified -NoNewline
        Write-Host "  ✓ HTML processed: $(Split-Path $inputFile -Leaf)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error processing HTML: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nMinifying CSS files..." -ForegroundColor Cyan

# Minify CSS
if (Test-Path "styles.css") {
    Minify-CSS "styles.css" "$prodDir/styles.min.css"
} else {
    Write-Host "  ⚠ styles.css not found" -ForegroundColor Yellow
}

Write-Host "`nMinifying JavaScript files..." -ForegroundColor Cyan

# Minify JavaScript
if (Test-Path "script.js") {
    Minify-JS "script.js" "$prodDir/script.min.js"
} else {
    Write-Host "  ⚠ script.js not found" -ForegroundColor Yellow
}

Write-Host "`nProcessing HTML files..." -ForegroundColor Cyan

# Process HTML files
$htmlFiles = @("index.html", "contacto.html", "servicios.html", "portafolio.html", "precios.html", "offline.html")

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        Process-HTML $file "$prodDir/$file"
    } else {
        Write-Host "  ⚠ $file not found" -ForegroundColor Yellow
    }
}

# Copy other necessary files
Write-Host "`nCopying additional files..." -ForegroundColor Cyan

$filesToCopy = @(
    "manifest.json",
    "sw.js",
    "sitemap.xml",
    "robots.txt"
)

foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file "$prodDir/$file" -Force
        Write-Host "  ✓ Copied: $file" -ForegroundColor Green
    }
}

# Copy assets directory
if (Test-Path "assets") {
    Copy-Item "assets" "$prodDir/assets" -Recurse -Force
    Write-Host "  ✓ Copied: assets directory" -ForegroundColor Green
}

# Copy politicas directory
if (Test-Path "politicas") {
    Copy-Item "politicas" "$prodDir/politicas" -Recurse -Force
    Write-Host "  ✓ Copied: politicas directory" -ForegroundColor Green
}

# Create .htaccess for production
$htaccessContent = @"
# Production .htaccess for UWEB

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
    AddOutputFilterByType DEFLATE image/svg+xml
</IfModule>

# Set cache headers
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

# Security headers
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
</IfModule>

# Force HTTPS (uncomment for production)
# RewriteEngine On
# RewriteCond %{HTTPS} off
# RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Custom error pages
ErrorDocument 404 /404.html
ErrorDocument 500 /offline.html
"@

Set-Content -Path "$prodDir/.htaccess" -Value $htaccessContent
Write-Host "  ✓ Created production .htaccess" -ForegroundColor Green

# Generate build info
$buildInfo = @{
    "buildDate" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "version" = "1.0.0"
    "environment" = "production"
    "minified" = $true
} | ConvertTo-Json -Depth 2

Set-Content -Path "$prodDir/build-info.json" -Value $buildInfo
Write-Host "  ✓ Created build info" -ForegroundColor Green

Write-Host "`nMinification Summary:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "• Production files created in: $prodDir" -ForegroundColor White
Write-Host "• CSS and JS files minified" -ForegroundColor White
Write-Host "• HTML files processed and optimized" -ForegroundColor White
Write-Host "• Assets and additional files copied" -ForegroundColor White
Write-Host "• Production .htaccess created" -ForegroundColor White

if (-not $nodeAvailable) {
    Write-Host "`nRecommendation:" -ForegroundColor Yellow
    Write-Host "Install Node.js and tools like UglifyJS or Terser for better minification" -ForegroundColor Yellow
    Write-Host "npm install -g uglify-js clean-css-cli html-minifier" -ForegroundColor Yellow
}

Write-Host "`nMinification complete! 🚀" -ForegroundColor Green
Write-Host "Deploy the contents of the '$prodDir' directory to your web server." -ForegroundColor White