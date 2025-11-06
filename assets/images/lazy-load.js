// Lazy Loading para imágenes del portafolio UWEB
// Optimiza la carga de imágenes con soporte WebP automático

document.addEventListener('DOMContentLoaded', function() {
    // Verificar soporte para WebP
    function supportsWebP() {
        return new Promise(resolve => {
            const webP = new Image();
            webP.onload = webP.onerror = () => resolve(webP.height === 2);
            webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
        });
    }

    // Configurar lazy loading con soporte WebP
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    const src = img.dataset.src;
                    
                    // Usar WebP si está disponible y existe el archivo
                    supportsWebP().then(hasWebP => {
                        if (hasWebP && src.includes('.jpg')) {
                            // Intentar cargar versión WebP primero
                            const webpSrc = src.replace('.jpg', '.webp');
                            const testImg = new Image();
                            testImg.onload = () => {
                                img.src = webpSrc;
                                img.classList.remove('lazy');
                                img.classList.add('loaded');
                            };
                            testImg.onerror = () => {
                                img.src = src;
                                img.classList.remove('lazy');
                                img.classList.add('loaded');
                            };
                            testImg.src = webpSrc;
                        } else {
                            img.src = src;
                            img.classList.remove('lazy');
                            img.classList.add('loaded');
                        }
                        imageObserver.unobserve(img);
                    });
                }
            });
        }, {
            rootMargin: '50px 0px',
            threshold: 0.01
        });

        // Observar todas las imágenes con data-src
        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    } else {
        // Fallback para navegadores sin IntersectionObserver
        document.querySelectorAll('img[data-src]').forEach(img => {
            img.src = img.dataset.src;
            img.classList.remove('lazy');
            img.classList.add('loaded');
        });
    }
});

// CSS para lazy loading (agregar al CSS principal)
const lazyLoadCSS = `
.lazy {
    opacity: 0;
    transition: opacity 0.3s;
}

.loaded {
    opacity: 1;
}

.lazy::before {
    content: '';
    display: block;
    width: 100%;
    height: 200px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
}

@keyframes loading {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}
`;

// Agregar CSS si no existe
if (!document.querySelector('#lazy-load-css')) {
    const style = document.createElement('style');
    style.id = 'lazy-load-css';
    style.textContent = lazyLoadCSS;
    document.head.appendChild(style);
}