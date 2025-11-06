# Optimizacion final para produccion - UWEB
Write-Host "Iniciando optimizacion final para produccion..." -ForegroundColor Cyan

# Crear directorio de produccion
$prodDir = "dist"
if (Test-Path $prodDir) {
    Remove-Item $prodDir -Recurse -Force
}
New-Item -ItemType Directory -Path $prodDir | Out-Null

Write-Host "Creando version de produccion en directorio: $prodDir" -ForegroundColor Green

# Copiar archivos HTML
$htmlFiles = @("index.html", "contacto.html", "servicios.html", "portafolio.html", "precios.html")
foreach ($file in $htmlFiles) {
    Copy-Item $file "$prodDir/$file"
    Write-Host "Copiado: $file" -ForegroundColor Green
}

# Copiar directorio politicas
Copy-Item "politicas" "$prodDir/politicas" -Recurse
Write-Host "Copiado: directorio politicas" -ForegroundColor Green

# Copiar assets
Copy-Item "assets" "$prodDir/assets" -Recurse
Write-Host "Copiado: directorio assets" -ForegroundColor Green

# Copiar archivos de configuracion
$configFiles = @("manifest.json", "sitemap.xml", "robots.txt", "sw.js", "offline.html")
foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$prodDir/$file"
        Write-Host "Copiado: $file" -ForegroundColor Green
    }
}

# Minificar CSS manualmente (basico)
Write-Host "Minificando CSS..." -ForegroundColor Yellow
$cssContent = Get-Content "styles.css" -Raw
$cssMinified = $cssContent -replace '/\*.*?\*/', '' -replace '\s+', ' ' -replace ';\s*}', '}' -replace '{\s*', '{' -replace '}\s*', '}' -replace ':\s*', ':' -replace ';\s*', ';'
$cssMinified | Out-File "$prodDir/styles.css" -Encoding UTF8
Write-Host "CSS minificado guardado" -ForegroundColor Green

# Copiar JS (ya esta optimizado)
Copy-Item "script.js" "$prodDir/script.js"
Write-Host "JavaScript copiado" -ForegroundColor Green

# Verificar archivos criticos
Write-Host "`nVerificando archivos criticos..." -ForegroundColor Cyan
$criticalFiles = @(
    "$prodDir/index.html",
    "$prodDir/styles.css", 
    "$prodDir/script.js",
    "$prodDir/sitemap.xml",
    "$prodDir/assets/data/projects.json"
)

$allGood = $true
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "OK: $file" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $file no encontrado" -ForegroundColor Red
        $allGood = $false
    }
}

if ($allGood) {
    Write-Host "`nOptimizacion completada exitosamente!" -ForegroundColor Green
    Write-Host "Archivos de produccion listos en: $prodDir" -ForegroundColor Cyan
} else {
    Write-Host "`nSe encontraron errores en la optimizacion" -ForegroundColor Red
}