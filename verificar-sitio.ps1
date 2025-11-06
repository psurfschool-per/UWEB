# Verificacion final del sitio UWEB
Write-Host "Verificando sitio web UWEB..." -ForegroundColor Cyan

# Verificar archivos principales
$archivos = @(
    "index.html",
    "contacto.html", 
    "servicios.html",
    "portafolio.html",
    "precios.html",
    "styles.css",
    "script.js"
)

$errores = 0

foreach ($archivo in $archivos) {
    if (Test-Path $archivo) {
        Write-Host "OK: $archivo" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $archivo no encontrado" -ForegroundColor Red
        $errores++
    }
}

# Verificar politicas
$politicas = @(
    "politicas/privacidad.html",
    "politicas/terminos.html",
    "politicas/devoluciones.html"
)

foreach ($politica in $politicas) {
    if (Test-Path $politica) {
        Write-Host "OK: $politica" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $politica no encontrado" -ForegroundColor Red
        $errores++
    }
}

# Verificar recursos
if (Test-Path "assets/data/projects.json") {
    Write-Host "OK: assets/data/projects.json" -ForegroundColor Green
} else {
    Write-Host "ERROR: projects.json no encontrado" -ForegroundColor Red
    $errores++
}

if (Test-Path "sitemap.xml") {
    Write-Host "OK: sitemap.xml" -ForegroundColor Green
} else {
    Write-Host "ERROR: sitemap.xml no encontrado" -ForegroundColor Red
    $errores++
}

Write-Host "`nResumen: $errores errores encontrados" -ForegroundColor Yellow

if ($errores -eq 0) {
    Write-Host "Sitio web verificado correctamente!" -ForegroundColor Green
}