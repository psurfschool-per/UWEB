# Script para configurar Git y subir a GitHub
# Ejecutar este script después de crear el repositorio en GitHub

Write-Host "🚀 Configurando repositorio Git para UWEB..." -ForegroundColor Green

# Inicializar repositorio Git
if (-not (Test-Path ".git")) {
    Write-Host "📁 Inicializando repositorio Git..." -ForegroundColor Yellow
    git init
} else {
    Write-Host "✅ Repositorio Git ya existe" -ForegroundColor Green
}

# Agregar archivos al staging
Write-Host "📋 Agregando archivos al staging..." -ForegroundColor Yellow
git add .

# Crear commit inicial
Write-Host "💾 Creando commit inicial..." -ForegroundColor Yellow
git commit -m "🎉 Initial commit: UWEB Corporate Website

✨ Features:
- 4-stage development methodology (Study, Design, Build, Deploy)
- Responsive design for all devices
- Real-time USD/PEN currency conversion
- Advanced contact forms with validation
- Interactive process timeline
- Professional service pages

🛠️ Tech Stack:
- HTML5, CSS3, JavaScript (Vanilla)
- CSS Grid & Flexbox
- SVG icons
- ExchangeRate API integration

📍 Company Info:
- Location: Barranca, Lima, Peru
- Timezone: UTC-5 (PET)
- Contact: +51 987 654 321"

# Configurar rama principal
Write-Host "🌿 Configurando rama principal..." -ForegroundColor Yellow
git branch -M main

# Instrucciones para el usuario
Write-Host ""
Write-Host "🎯 SIGUIENTE PASO:" -ForegroundColor Cyan
Write-Host "1. Ve a GitHub.com y crea un nuevo repositorio llamado 'uweb-sitio'" -ForegroundColor White
Write-Host "2. Copia la URL del repositorio (ej: https://github.com/tu-usuario/uweb-sitio.git)" -ForegroundColor White
Write-Host "3. Ejecuta estos comandos:" -ForegroundColor White
Write-Host ""
Write-Host "   git remote add origin https://github.com/TU-USUARIO/uweb-sitio.git" -ForegroundColor Yellow
Write-Host "   git push -u origin main" -ForegroundColor Yellow
Write-Host ""
Write-Host "🌐 Para GitHub Pages:" -ForegroundColor Cyan
Write-Host "1. Ve a Settings > Pages en tu repositorio" -ForegroundColor White
Write-Host "2. Selecciona 'Deploy from a branch'" -ForegroundColor White
Write-Host "3. Elige 'main' branch y '/ (root)'" -ForegroundColor White
Write-Host "4. Tu sitio estará disponible en: https://tu-usuario.github.io/uweb-sitio/" -ForegroundColor White
Write-Host ""
Write-Host "✅ Repositorio configurado correctamente!" -ForegroundColor Green