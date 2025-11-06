# Script para verificar enlaces internos y externos
Write-Host "🔍 Verificando enlaces del sitio web UWEB..." -ForegroundColor Cyan

# Archivos HTML a verificar
$htmlFiles = @(
    "index.html",
    "contacto.html", 
    "servicios.html",
    "portafolio.html",
    "precios.html",
    "politicas/privacidad.html",
    "politicas/terminos.html", 
    "politicas/devoluciones.html"
)

$erroresEncontrados = 0

foreach ($archivo in $htmlFiles) {
    if (Test-Path $archivo) {
        Write-Host "✅ Verificando: $archivo" -ForegroundColor Green
        
        # Leer contenido del archivo
        $contenido = Get-Content $archivo -Raw
        
        # Verificar enlaces internos comunes
        $enlacesInternos = @(
            "index.html",
            "servicios.html", 
            "portafolio.html",
            "precios.html",
            "contacto.html",
            "politicas/privacidad.html",
            "politicas/terminos.html",
            "politicas/devoluciones.html",
            "styles.css",
            "script.js",
            "manifest.json"
        )
        
        foreach ($enlace in $enlacesInternos) {
            if ($contenido -match $enlace) {
                # Verificar si el archivo existe
                $rutaArchivo = $enlace
                if ($archivo.StartsWith("politicas/") -and -not $enlace.StartsWith("../") -and -not $enlace.StartsWith("politicas/")) {
                    $rutaArchivo = "../$enlace"
                }
                
                if ($enlace.StartsWith("politicas/") -and $archivo.StartsWith("politicas/")) {
                    $rutaArchivo = $enlace
                } elseif ($enlace.StartsWith("politicas/") -and -not $archivo.StartsWith("politicas/")) {
                    $rutaArchivo = $enlace
                } elseif (-not $enlace.StartsWith("politicas/") -and $archivo.StartsWith("politicas/")) {
                    $rutaArchivo = "../$enlace"
                } else {
                    $rutaArchivo = $enlace
                }
                
                # Verificar ruta real del archivo
                $rutaReal = $enlace
                if (-not (Test-Path $rutaReal)) {
                    Write-Host "⚠️  Enlace roto en $archivo : $enlace" -ForegroundColor Yellow
                    $erroresEncontrados++
                }
            }
        }
    } else {
        Write-Host "❌ Archivo no encontrado: $archivo" -ForegroundColor Red
        $erroresEncontrados++
    }
}

# Verificar archivos de recursos
$recursos = @(
    "styles.css",
    "script.js", 
    "manifest.json",
    "sitemap.xml",
    "robots.txt",
    "assets/data/projects.json"
)

Write-Host "`n🔧 Verificando archivos de recursos..." -ForegroundColor Cyan

foreach ($recurso in $recursos) {
    if (Test-Path $recurso) {
        Write-Host "✅ $recurso existe" -ForegroundColor Green
    } else {
        Write-Host "❌ $recurso no encontrado" -ForegroundColor Red
        $erroresEncontrados++
    }
}

# Resumen
Write-Host "`n📊 Resumen de verificación:" -ForegroundColor Cyan
if ($erroresEncontrados -eq 0) {
    Write-Host "🎉 ¡Todos los enlaces y recursos están correctos!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Se encontraron $erroresEncontrados errores que necesitan corrección" -ForegroundColor Yellow
}

Write-Host "`n✅ Verificación de enlaces completada" -ForegroundColor Green