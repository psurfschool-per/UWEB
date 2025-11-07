/**
 * Component Loader
 * Carga componentes reutilizables (navbar y footer) en todas las páginas
 */

(function() {
    'use strict';

    // Función para cargar un componente HTML
    async function loadComponent(componentPath, targetSelector) {
        try {
            const response = await fetch(componentPath);
            if (!response.ok) {
                throw new Error(`Error al cargar ${componentPath}: ${response.statusText}`);
            }
            const html = await response.text();
            const targetElement = document.querySelector(targetSelector);
            
            if (targetElement) {
                targetElement.innerHTML = html;
                
                // Ejecutar scripts dentro del componente si los hay
                const scripts = targetElement.querySelectorAll('script');
                scripts.forEach(oldScript => {
                    const newScript = document.createElement('script');
                    Array.from(oldScript.attributes).forEach(attr => {
                        newScript.setAttribute(attr.name, attr.value);
                    });
                    newScript.appendChild(document.createTextNode(oldScript.innerHTML));
                    oldScript.parentNode.replaceChild(newScript, oldScript);
                });
                
                return true;
            } else {
                console.warn(`No se encontró el selector ${targetSelector} para cargar ${componentPath}`);
                return false;
            }
        } catch (error) {
            console.error(`Error al cargar componente ${componentPath}:`, error);
            return false;
        }
    }

    // Función para marcar el enlace activo según la página actual
    function setActiveNavLink() {
        const currentPage = window.location.pathname.split('/').pop() || 'index.html';
        const navLinks = document.querySelectorAll('.nav__link[data-page]');
        
        navLinks.forEach(link => {
            link.classList.remove('nav__link--active');
            const linkPage = link.getAttribute('data-page');
            const linkHref = link.getAttribute('href');
            
            // Si es index.html o está vacío, comparar con index
            if (currentPage === 'index.html' || currentPage === '' || currentPage === '/') {
                if (linkPage === 'index' || linkHref === 'index.html' || linkHref === '#inicio') {
                    link.classList.add('nav__link--active');
                }
            } else if (currentPage.includes(linkPage)) {
                link.classList.add('nav__link--active');
            }
        });
    }

    // Función para inicializar el menú móvil
    function initMobileMenu() {
        const navToggle = document.getElementById('nav-toggle');
        const navMenu = document.getElementById('nav-menu');
        
        if (navToggle && navMenu) {
            navToggle.addEventListener('click', () => {
                navMenu.classList.toggle('active');
                navToggle.classList.toggle('active');
            });

            // Cerrar menú al hacer clic en un enlace
            const navLinks = navMenu.querySelectorAll('.nav__link');
            navLinks.forEach(link => {
                link.addEventListener('click', () => {
                    navMenu.classList.remove('active');
                    navToggle.classList.remove('active');
                });
            });

            // Cerrar menú al hacer clic fuera
            document.addEventListener('click', (e) => {
                if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
                    navMenu.classList.remove('active');
                    navToggle.classList.remove('active');
                }
            });
        }
    }

    // Función principal de inicialización
    async function initComponents() {
        // Cargar navbar
        const navbarLoaded = await loadComponent('components/navbar.html', '#navbar-container');
        
        // Cargar footer
        const footerLoaded = await loadComponent('components/footer.html', '#footer-container');
        
        // Si los componentes se cargaron correctamente, inicializar funcionalidades
        if (navbarLoaded) {
            // Esperar un momento para que el DOM se actualice
            setTimeout(() => {
                setActiveNavLink();
                initMobileMenu();
            }, 100);
        }
    }

    // Inicializar cuando el DOM esté listo
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initComponents);
    } else {
        initComponents();
    }
})();

