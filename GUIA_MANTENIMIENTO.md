# Guía de Mantenimiento - Sitio Web UWEB

## Introducción

Esta guía proporciona instrucciones detalladas para el mantenimiento y actualización del sitio web UWEB. Está diseñada para que el cliente pueda realizar tareas básicas de mantenimiento sin conocimientos técnicos avanzados.

## Índice

1. [Tareas de Mantenimiento Básico](#tareas-de-mantenimiento-básico)
2. [Actualización de Contenido](#actualización-de-contenido)
3. [Gestión del Portafolio](#gestión-del-portafolio)
4. [Monitoreo y Optimización](#monitoreo-y-optimización)
5. [Resolución de Problemas Comunes](#resolución-de-problemas-comunes)
6. [Contacto de Soporte](#contacto-de-soporte)

## Tareas de Mantenimiento Básico

### Frecuencia Semanal

#### ✅ Verificar Funcionamiento del Formulario de Contacto
1. Ir a la página de contacto: `https://tu-sitio.com/contacto.html`
2. Llenar el formulario con datos de prueba
3. Verificar que llegue el email de confirmación
4. **Si no funciona:** Contactar soporte técnico inmediatamente

#### ✅ Revisar Enlaces Rotos
1. Navegar por todas las páginas del sitio
2. Hacer clic en todos los enlaces principales
3. Verificar que las imágenes se cargan correctamente
4. **Herramienta recomendada:** Usar el script `verificar-enlaces.ps1` (si tienes acceso técnico)

#### ✅ Comprobar Velocidad del Sitio
1. Ir a [PageSpeed Insights](https://pagespeed.web.dev/)
2. Ingresar la URL de tu sitio
3. Verificar que el puntaje sea superior a 85
4. **Si es menor:** Revisar optimizaciones o contactar soporte

### Frecuencia Mensual

#### ✅ Actualizar Información de Contacto
- Verificar que teléfonos y emails estén actualizados
- Revisar horarios de atención si han cambiado
- Actualizar dirección si es necesario

#### ✅ Revisar Políticas Legales
- Verificar que las políticas estén actualizadas
- Revisar cambios en regulaciones locales
- Actualizar fechas de modificación si es necesario

#### ✅ Backup de Contenido
- Descargar copia de `assets/data/projects.json`
- Guardar copia de imágenes importantes
- Documentar cambios realizados

## Actualización de Contenido

### Cambiar Precios de Servicios

**Archivo a modificar:** `precios.html`

1. Abrir el archivo `precios.html` en un editor de texto
2. Buscar la sección de precios:
```html
<div class="price-card">
    <h3>Sitio Web Básico</h3>
    <div class="price">
        <span class="currency">$</span>
        <span class="amount" data-usd="800" data-pen="3200">800</span>
    </div>
</div>
```
3. Modificar los valores en `data-usd` y `data-pen`
4. Guardar el archivo
5. Verificar que los cambios se reflejen en el sitio

### Actualizar Información de la Empresa

**Archivos principales:**
- `index.html` - Página principal
- `contacto.html` - Información de contacto
- `servicios.html` - Descripción de servicios

**Pasos:**
1. Identificar la sección a modificar
2. Editar el texto directamente en el HTML
3. Mantener las etiquetas HTML intactas
4. Guardar y verificar cambios

### Modificar Texto de Servicios

**Archivo:** `servicios.html`

Para cambiar la descripción de un servicio:
1. Buscar la tarjeta del servicio específico
2. Modificar el contenido dentro de las etiquetas `<p>` y `<li>`
3. Mantener la estructura HTML
4. Guardar cambios

Ejemplo:
```html
<div class="service-detail-card">
    <h3>Desarrollo Web Personalizado</h3>
    <p>AQUÍ PUEDES CAMBIAR LA DESCRIPCIÓN</p>
    <ul class="service-features">
        <li>AQUÍ PUEDES CAMBIAR LAS CARACTERÍSTICAS</li>
    </ul>
</div>
```

## Gestión del Portafolio

### Agregar Nuevo Proyecto

**Archivo:** `assets/data/projects.json`

1. Abrir el archivo `projects.json`
2. Agregar un nuevo proyecto al final del array:

```json
{
  "id": 9,
  "title": "Nombre del Nuevo Proyecto",
  "category": "web",
  "image": "assets/images/portfolio/nuevo-proyecto.jpg",
  "technologies": ["HTML5", "CSS3", "JavaScript"],
  "duration": "4 semanas",
  "description": "Descripción detallada del proyecto...",
  "features": [
    "Característica 1",
    "Característica 2",
    "Característica 3"
  ],
  "liveUrl": "https://sitio-del-cliente.com",
  "client": "Nombre del Cliente",
  "year": 2024
}
```

3. Guardar el archivo
4. Subir la imagen del proyecto a `assets/images/portfolio/`

### Modificar Proyecto Existente

1. Buscar el proyecto por su `id` en `projects.json`
2. Modificar los campos necesarios
3. Guardar el archivo
4. Los cambios se reflejarán automáticamente

### Eliminar Proyecto

1. Localizar el proyecto en `projects.json`
2. Eliminar todo el objeto del proyecto (desde `{` hasta `}`)
3. Asegurarse de mantener la sintaxis JSON correcta
4. Guardar el archivo

### Optimizar Imágenes del Portafolio

**Para nuevas imágenes:**
1. Redimensionar a máximo 800x600 píxeles
2. Comprimir usando herramientas online como TinyPNG
3. Guardar en formato JPG o WebP
4. Nombrar descriptivamente: `proyecto-nombre-cliente.jpg`

## Monitoreo y Optimización

### Herramientas de Monitoreo Recomendadas

#### Google Analytics (si está configurado)
- Revisar tráfico mensual
- Identificar páginas más visitadas
- Monitorear tiempo de permanencia

#### Google Search Console
- Verificar indexación de páginas
- Revisar errores de rastreo
- Monitorear palabras clave

#### PageSpeed Insights
- Verificar velocidad mensualmente
- Objetivo: mantener puntaje > 85
- Revisar sugerencias de optimización

### Optimización Continua

#### Imágenes
- Comprimir nuevas imágenes antes de subirlas
- Usar formatos modernos (WebP) cuando sea posible
- Mantener tamaños apropiados (no subir imágenes gigantes)

#### Contenido
- Mantener textos actualizados y relevantes
- Agregar nuevos proyectos regularmente
- Actualizar información de servicios según evolución del negocio

## Resolución de Problemas Comunes

### Problema: El formulario de contacto no envía emails

**Posibles causas:**
- Configuración del servidor de email
- Campos requeridos no completados
- Problemas con el hosting

**Solución:**
1. Verificar que todos los campos estén llenos
2. Probar con diferentes navegadores
3. Contactar al proveedor de hosting
4. Como alternativa temporal, usar el email directo

### Problema: Las imágenes no se cargan

**Posibles causas:**
- Archivos movidos o eliminados
- Nombres de archivo incorrectos
- Problemas de permisos

**Solución:**
1. Verificar que los archivos existan en la carpeta correcta
2. Revisar que los nombres coincidan exactamente
3. Verificar permisos de archivos (644 para archivos, 755 para carpetas)

### Problema: El sitio se ve diferente en móvil

**Posibles causas:**
- Cache del navegador
- Modificaciones CSS incorrectas

**Solución:**
1. Limpiar cache del navegador móvil
2. Probar en modo incógnito
3. Verificar que no se hayan modificado archivos CSS

### Problema: Páginas no aparecen en Google

**Posibles causas:**
- Sitio muy nuevo
- Problemas con sitemap
- Contenido duplicado

**Solución:**
1. Verificar que el sitemap.xml esté accesible
2. Enviar sitio a Google Search Console
3. Esperar tiempo de indexación (puede tomar semanas)

## Actualizaciones de Seguridad

### Mensual
- Verificar que el hosting esté actualizado
- Revisar certificado SSL (debe mostrar candado verde)
- Cambiar contraseñas de acceso si es necesario

### Trimestral
- Revisar políticas de privacidad por cambios legales
- Actualizar información de contacto
- Verificar cumplimiento GDPR si aplica

## Mejores Prácticas

### ✅ Hacer Siempre
- Hacer backup antes de cambios importantes
- Probar cambios en navegador antes de publicar
- Mantener estructura de archivos organizada
- Documentar cambios realizados

### ❌ Nunca Hacer
- Modificar archivos CSS o JS sin conocimiento técnico
- Eliminar archivos sin estar seguro de su función
- Cambiar estructura de carpetas
- Modificar código JavaScript complejo

## Calendario de Mantenimiento Sugerido

### Semanal (Lunes)
- [ ] Verificar formulario de contacto
- [ ] Revisar velocidad del sitio
- [ ] Comprobar enlaces principales

### Mensual (Primer viernes del mes)
- [ ] Actualizar portafolio con nuevos proyectos
- [ ] Revisar y actualizar precios si es necesario
- [ ] Verificar información de contacto
- [ ] Hacer backup de contenido importante

### Trimestral (Cada 3 meses)
- [ ] Revisar políticas legales
- [ ] Actualizar información de servicios
- [ ] Optimizar imágenes antiguas
- [ ] Revisar métricas de rendimiento

### Anual (Enero)
- [ ] Revisión completa de contenido
- [ ] Actualización de año en footer
- [ ] Planificación de mejoras para el año
- [ ] Renovación de dominio y hosting

## Contacto de Soporte

### Soporte Técnico Prioritario
- **Email:** soporte@uweb.com
- **Teléfono:** +51 XXX XXX XXX
- **Horario:** Lunes a Viernes, 9:00 AM - 6:00 PM

### Soporte de Emergencia (24/7)
- **Solo para:** Sitio completamente caído, problemas de seguridad críticos
- **Email:** emergencia@uweb.com
- **WhatsApp:** +51 XXX XXX XXX

### Información a Proporcionar al Contactar Soporte
1. URL del sitio web
2. Descripción detallada del problema
3. Pasos realizados antes del problema
4. Capturas de pantalla si es posible
5. Navegador y dispositivo utilizado

## Recursos Adicionales

### Herramientas Útiles Online
- [TinyPNG](https://tinypng.com/) - Comprimir imágenes
- [PageSpeed Insights](https://pagespeed.web.dev/) - Verificar velocidad
- [GTmetrix](https://gtmetrix.com/) - Análisis de rendimiento
- [Google Search Console](https://search.google.com/search-console) - SEO

### Tutoriales Recomendados
- Cómo comprimir imágenes para web
- Básicos de SEO para sitios web
- Cómo usar Google Analytics
- Mejores prácticas de mantenimiento web

---

**Última actualización:** Noviembre 2024  
**Versión de la guía:** 1.0  
**Próxima revisión:** Febrero 2025

**Nota importante:** Esta guía debe actualizarse cada 6 meses o cuando se implementen cambios significativos en el sitio web.