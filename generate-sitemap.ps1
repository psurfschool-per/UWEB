# Script para generar sitemap.xml automaticamente
# Escanea el sitio web UWEB y crea un sitemap actualizado

Write-Host "Generador de Sitemap UWEB" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Obtener fecha actual en formato ISO
$currentDate = Get-Date -Format "yyyy-MM-dd"

# Definir la URL base del sitio
$baseUrl = "https://uweb.com"

# Definir las páginas y sus prioridades (todas las páginas del sitio expandido)
$pages = @(
    @{ url = "/"; priority = "1.0"; changefreq = "weekly" },
    @{ url = "/servicios.html"; priority = "0.9"; changefreq = "monthly" },
    @{ url = "/portafolio.html"; priority = "0.9"; changefreq = "weekly" },
    @{ url = "/precios.html"; priority = "0.8"; changefreq = "monthly" },
    @{ url = "/contacto.html"; priority = "0.8"; changefreq = "monthly" },
    @{ url = "/politicas/privacidad.html"; priority = "0.3"; changefreq = "yearly" },
    @{ url = "/politicas/terminos.html"; priority = "0.3"; changefreq = "yearly" },
    @{ url = "/politicas/devoluciones.html"; priority = "0.3"; changefreq = "yearly" }
)

# Crear contenido del sitemap
$sitemapContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">

"@

# Agregar cada página al sitemap
foreach ($page in $pages) {
    $sitemapContent += @"
    <url>
        <loc>$baseUrl$($page.url)</loc>
        <lastmod>$currentDate</lastmod>
        <changefreq>$($page.changefreq)</changefreq>
        <priority>$($page.priority)</priority>
    </url>

"@
}

$sitemapContent += "</urlset>"

# Escribir el sitemap al archivo
Set-Content -Path "sitemap.xml" -Value $sitemapContent -Encoding UTF8

Write-Host "Sitemap generado exitosamente:" -ForegroundColor Green
Write-Host "- Archivo: sitemap.xml" -ForegroundColor White
Write-Host "- Páginas incluidas: $($pages.Count)" -ForegroundColor White
Write-Host "- Fecha de actualización: $currentDate" -ForegroundColor White

# Verificar que el archivo se haya creado
if (Test-Path "sitemap.xml") {
    $fileSize = [math]::Round((Get-Item "sitemap.xml").Length / 1KB, 2)
    Write-Host "- Tamaño del archivo: $fileSize KB" -ForegroundColor White
    Write-Host "`nSitemap listo para enviar a Google Search Console!" -ForegroundColor Green
} else {
    Write-Host "Error: No se pudo crear el archivo sitemap.xml" -ForegroundColor Red
}