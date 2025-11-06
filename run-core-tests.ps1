# Script para ejecutar pruebas de funcionalidad core
Write-Host "🧪 Iniciando pruebas de funcionalidad core del sitio UWEB..." -ForegroundColor Cyan

# Verificar que los archivos necesarios existen
$requiredFiles = @(
    "test-core-functionality.html",
    "index.html", 
    "contacto.html",
    "servicios.html", 
    "portafolio.html",
    "precios.html",
    "script.js",
    "styles.css",
    "assets/data/projects.json"
)

Write-Host "`n📋 Verificando archivos requeridos..." -ForegroundColor Yellow
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "`n⚠️ Archivos faltantes encontrados:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    Write-Host "`nNo se pueden ejecutar todas las pruebas sin estos archivos." -ForegroundColor Yellow
}

# Abrir el archivo de pruebas
Write-Host "`n🚀 Abriendo archivo de pruebas..." -ForegroundColor Cyan

try {
    Start-Process "test-core-functionality.html"
    
    Write-Host "`n📝 Instrucciones para las pruebas:" -ForegroundColor Yellow
    Write-Host "1. Se abrirá la página de pruebas en tu navegador" -ForegroundColor White
    Write-Host "2. Las pruebas de navegación se ejecutarán automáticamente" -ForegroundColor White
    Write-Host "3. Haz clic en 'Ejecutar Pruebas de Validación' para probar el formulario" -ForegroundColor White
    Write-Host "4. Haz clic en 'Ejecutar Pruebas de Portafolio' para probar los filtros" -ForegroundColor White
    Write-Host "5. Revisa el resumen de resultados al final de la página" -ForegroundColor White
    
    Write-Host "`n🔍 Qué se está probando:" -ForegroundColor Cyan
    Write-Host "• Navegación entre todas las páginas del sitio" -ForegroundColor White
    Write-Host "• Funcionamiento del formulario de contacto y validaciones" -ForegroundColor White
    Write-Host "• Sistema de filtros del portafolio y modal de detalles" -ForegroundColor White
    Write-Host "• Elementos de UI y funcionalidades JavaScript" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error al abrir el archivo: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Pruebas iniciadas. Revisa los resultados en el navegador." -ForegroundColor Green