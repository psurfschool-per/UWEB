# 🚀 Guía para Subir UWEB a GitHub

## Paso 1: Preparar el Repositorio Local

El proyecto ya está configurado con todos los archivos necesarios:
- ✅ `README.md` - Documentación completa
- ✅ `.gitignore` - Excluye archivos innecesarios
- ✅ `package.json` - Configuración del proyecto
- ✅ `.github/workflows/deploy.yml` - Deploy automático

## Paso 2: Crear Repositorio en GitHub

1. **Ve a GitHub.com** y haz login
2. **Clic en "New repository"** (botón verde)
3. **Configuración del repositorio:**
   - **Repository name:** `uweb-sitio`
   - **Description:** `Sitio web corporativo para UWEB - Desarrollo web en Barranca, Lima, Perú`
   - **Visibility:** Public (para GitHub Pages gratuito)
   - **NO marques** "Add a README file" (ya tenemos uno)
   - **NO marques** "Add .gitignore" (ya tenemos uno)
   - **License:** MIT (opcional)

4. **Clic en "Create repository"**

## Paso 3: Conectar Repositorio Local con GitHub

Ejecuta estos comandos en PowerShell desde la carpeta del proyecto:

```powershell
# 1. Ejecutar el script de configuración
powershell -ExecutionPolicy Bypass -File setup-git.ps1

# 2. Agregar el repositorio remoto (reemplaza TU-USUARIO)
git remote add origin https://github.com/TU-USUARIO/uweb-sitio.git

# 3. Subir el código
git push -u origin main
```

## Paso 4: Configurar GitHub Pages

1. **Ve a tu repositorio** en GitHub
2. **Clic en "Settings"** (pestaña superior)
3. **Scroll down hasta "Pages"** (menú lateral izquierdo)
4. **En "Source"** selecciona:
   - **Deploy from a branch**
   - **Branch:** `main`
   - **Folder:** `/ (root)`
5. **Clic en "Save"**

## Paso 5: Verificar Deployment

- **GitHub Pages URL:** `https://tu-usuario.github.io/uweb-sitio/`
- **Tiempo de deploy:** 2-5 minutos
- **Status:** Verifica en Actions tab

## 🎯 URLs Importantes

Una vez configurado, tendrás:

- **Repositorio:** `https://github.com/tu-usuario/uweb-sitio`
- **Sitio web:** `https://tu-usuario.github.io/uweb-sitio/`
- **Actions:** `https://github.com/tu-usuario/uweb-sitio/actions`

## 📋 Comandos Útiles para el Futuro

```powershell
# Ver estado del repositorio
git status

# Agregar cambios
git add .

# Crear commit
git commit -m "Descripción de los cambios"

# Subir cambios
git push origin main

# Ver historial
git log --oneline

# Ver ramas
git branch -a
```

## 🔧 Configuración Adicional (Opcional)

### Dominio Personalizado
Si tienes un dominio propio:
1. Ve a Settings > Pages
2. En "Custom domain" ingresa tu dominio
3. Crea un archivo `CNAME` con tu dominio

### Configurar Git Globalmente
```powershell
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@ejemplo.com"
```

## 🚨 Solución de Problemas

### Error: "Repository not found"
- Verifica que la URL del repositorio sea correcta
- Asegúrate de tener permisos en el repositorio

### Error: "Permission denied"
- Configura SSH keys o usa HTTPS con token
- Verifica tus credenciales de GitHub

### GitHub Pages no funciona
- Verifica que el repositorio sea público
- Revisa la configuración en Settings > Pages
- Espera 5-10 minutos para el primer deploy

## 📞 Soporte

Si necesitas ayuda:
- **GitHub Docs:** https://docs.github.com/pages
- **Git Tutorial:** https://git-scm.com/docs/gittutorial
- **Contacto UWEB:** info@uweb.com

---

¡Listo! Tu sitio web estará disponible públicamente en GitHub Pages. 🎉