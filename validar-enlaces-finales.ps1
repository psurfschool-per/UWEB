# Validacion final de enlaces - UWEB
Write-Host "Validando enlaces internos y externos..." -ForegroundColor Cyan

$errores = 0

# Verificar enlaces en index.html
Write-Host "`nVerificando index.html..." -ForegroundColor Yellow
$indexContent = Get-Content "index.html" -Raw

# Enlaces internos esperados en index.html
$enlacesIndex = @(
    'href="servicios.html"',
    'href="portafolio.html"', 
    'href="precios.html"',
    'href="contacto.html"',
    'href="politicas/privacidad.html"',
    'href="politicas/terminos.html"',
    'href="politicas/devoluciones.html"'
)

foreach ($enlace in $enlacesIndex) {
    if ($indexContent -match [regex]::Escape($enlace)) {
        Write-Host "OK: $enlace encontrado" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $enlace no encontrado" -ForegroundColor Red
        $errores++
    }
}

# Verificar enlaces en contacto.html
Write-Host "`nVerificando contacto.html..." -ForegroundColor Yellow
$contactoContent = Get-Content "contacto.html" -Raw

$enlacesContacto = @(
    'href="index.html"',
    'href="servicios.html"',
    'href="portafolio.html"',
    'href="precios.html"'
)

foreach ($enlace in $enlacesContacto) {
    if ($contactoContent -match [regex]::Escape($enlace)) {
        Write-Host "OK: $enlace encontrado en contacto" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $enlace no encontrado en contacto" -ForegroundColor Red
        $errores++
    }
}

# Verificar enlaces en politicas
Write-Host "`nVerificando politicas..." -ForegroundColor Yellow
$politicaContent = Get-Content "politicas/privacidad.html" -Raw

$enlacesPoliticas = @(
    'href="../index.html"',
    'href="../servicios.html"',
    'href="../contacto.html"'
)

foreach ($enlace in $enlacesPoliticas) {
    if ($politicaContent -match [regex]::Escape($enlace)) {
        Write-Host "OK: $enlace encontrado en politicas" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $enlace no encontrado en politicas" -ForegroundColor Red
        $errores++
    }
}

# Verificar recursos CSS y JS
Write-Host "`nVerificando recursos..." -ForegroundColor Yellow
$recursos = @(
    @{archivo="index.html"; recurso="styles.css"},
    @{archivo="index.html"; recurso="script.js"},
    @{archivo="contacto.html"; recurso="styles.css"},
    @{archivo="servicios.html"; recurso="script.js"}
)

foreach ($item in $recursos) {
    $content = Get-Content $item.archivo -Raw
    if ($content -match $item.recurso) {
        Write-Host "OK: $($item.recurso) referenciado en $($item.archivo)" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $($item.recurso) no referenciado en $($item.archivo)" -ForegroundColor Red
        $errores++
    }
}

# Resumen final
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "RESUMEN DE VALIDACION" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan

if ($errores -eq 0) {
    Write-Host "EXITO: Todos los enlaces estan correctos!" -ForegroundColor Green
    Write-Host "El sitio web esta listo para produccion" -ForegroundColor Green
} else {
    Write-Host "ATENCION: Se encontraron $errores errores" -ForegroundColor Yellow
    Write-Host "Revisar los enlaces marcados como ERROR" -ForegroundColor Yellow
}

Write-Host "`nValidacion completada" -ForegroundColor Cyan