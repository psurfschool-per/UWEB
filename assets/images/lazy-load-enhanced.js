// Lazy Loading Mejorado para Imágenes UWEB
// Carga diferida con soporte para WebP automático

class UWEBImageOptimizer {
    constructor() {
        this.supportsWebP = false;
        this.checkWebPSupport();
        this.initLazyLoading();
    }
    
    // Detectar soporte para WebP
    checkWebPSupport() {
        const webP = new Image();
        webP.onload = webP.onerror = () => {
            this.supportsWebP = (webP.height === 2);
        };
        webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
    }
    
    // Inicializar lazy loading
    initLazyLoading() {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        this.loadOptimizedImage(img);
                        observer.unobserve(img);
                    }
                });
            }, {
                rootMargin: '50px 0px'
            });
            
            document.querySelectorAll('img[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        } else {
            // Fallback para navegadores antiguos
            this.loadAllImages();
        }
    }
    
    // Cargar imagen optimizada
    loadOptimizedImage(img) {
        const src = img.dataset.src;
        if (!src) return;
        
        // Intentar cargar WebP si es soportado
        if (this.supportsWebP && src.match(/\.(jpe?g|png)$/i)) {
            const webpSrc = src.replace(/\.(jpe?g|png)$/i, '.webp');
            
            const webpImg = new Image();
            webpImg.onload = () => {
                img.src = webpSrc;
                img.classList.add('loaded');
            };
            webpImg.onerror = () => {
                img.src = src;
                img.classList.add('loaded');
            };
            webpImg.src = webpSrc;
        } else {
            img.src = src;
            img.classList.add('loaded');
        }
    }
    
    // Cargar todas las imágenes (fallback)
    loadAllImages() {
        document.querySelectorAll('img[data-src]').forEach(img => {
            this.loadOptimizedImage(img);
        });
    }
}

// Inicializar cuando el DOM esté listo
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new UWEBImageOptimizer();
    });
} else {
    new UWEBImageOptimizer();
}

// Añadir estilos CSS dinámicamente
const style = document.createElement('style');
style.textContent = `
    img[data-src] {
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    img.loaded {
        opacity: 1;
    }
    
    .portfolio-image {
        background-color: #f5f5f5;
        background-image: linear-gradient(45deg, #f0f0f0 25%, transparent 25%), 
                          linear-gradient(-45deg, #f0f0f0 25%, transparent 25%), 
                          linear-gradient(45deg, transparent 75%, #f0f0f0 75%), 
                          linear-gradient(-45deg, transparent 75%, #f0f0f0 75%);
        background-size: 20px 20px;
        background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
    }
    
    .portfolio-image.loaded {
        background-image: none;
    }
`;
document.head.appendChild(style);