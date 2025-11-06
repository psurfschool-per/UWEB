// Navegación móvil
const navToggle = document.getElementById('nav-toggle');
const navMenu = document.getElementById('nav-menu');

if (navToggle && navMenu) {
    navToggle.addEventListener('click', () => {
        navMenu.classList.toggle('active');
        navToggle.classList.toggle('active');
    });
}

// Cerrar menú al hacer clic en un enlace
const navLinks = document.querySelectorAll('.nav__link');
navLinks.forEach(link => {
    link.addEventListener('click', () => {
        if (navMenu) navMenu.classList.remove('active');
        if (navToggle) navToggle.classList.remove('active');
    });
});

// Header con scroll
let lastScroll = 0;
const header = document.querySelector('.header');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    if (header) {
        if (currentScroll > 100) {
            header.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
        } else {
            header.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
        }
    }
    
    lastScroll = currentScroll;
});

// Animación al hacer scroll (Intersection Observer)
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const scrollObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observar elementos para animación
const animateElements = document.querySelectorAll('.service__card, .stat, .about__content');
animateElements.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    scrollObserver.observe(el);
});

// ===== FORMULARIO DE CONTACTO MEJORADO =====
function initContactForm() {
    const contactForm = document.getElementById('contact-form');
    if (!contactForm) return;

    const submitBtn = document.getElementById('submit-btn');
    const btnText = submitBtn?.querySelector('.btn-text');
    const btnLoading = submitBtn?.querySelector('.btn-loading');
    const formStatus = document.getElementById('form-status');
    
    // Configurar validación en tiempo real
    const formFields = {
        name: {
            element: document.getElementById('name'),
            validators: ['required', 'minLength'],
            minLength: 2
        },
        email: {
            element: document.getElementById('email'),
            validators: ['required', 'email']
        },
        phone: {
            element: document.getElementById('phone'),
            validators: ['phone']
        },
        serviceType: {
            element: document.getElementById('service-type'),
            validators: ['required']
        },
        message: {
            element: document.getElementById('message'),
            validators: ['required', 'minLength'],
            minLength: 10
        }
    };

    // Agregar event listeners para validación en tiempo real
    Object.keys(formFields).forEach(fieldName => {
        const field = formFields[fieldName];
        const element = field.element;
        
        if (!element) return;

        // Validar al perder el foco
        element.addEventListener('blur', () => {
            validateField(fieldName, field);
        });

        // Validar mientras escribe (solo si ya hay un error)
        element.addEventListener('input', () => {
            if (element.classList.contains('error')) {
                validateField(fieldName, field);
            }
        });
    });

    // Manejar envío del formulario
    contactForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        // Validar todos los campos
        let isFormValid = true;
        Object.keys(formFields).forEach(fieldName => {
            const field = formFields[fieldName];
            if (!validateField(fieldName, field)) {
                isFormValid = false;
            }
        });

        if (!isFormValid) {
            showFormStatus('error', 'Por favor, corrige los errores antes de enviar el formulario.');
            return;
        }

        // Mostrar estado de carga
        setLoadingState(true);
        showFormStatus('loading', 'Enviando tu mensaje...');

        // Recopilar datos del formulario
        const formData = {
            name: formFields.name.element?.value.trim() || '',
            email: formFields.email.element?.value.trim() || '',
            phone: formFields.phone.element?.value.trim() || '',
            serviceType: formFields.serviceType.element?.value || '',
            message: formFields.message.element?.value.trim() || '',
            timestamp: new Date().toISOString()
        };

        try {
            // Simular envío del formulario (reemplazar con llamada real al servidor)
            await simulateFormSubmission(formData);
            
            // Éxito - mensaje personalizado según el servicio
            const serviceType = formData.serviceType;
            const serviceMessages = {
                'web': '¡Gracias por tu interés en desarrollo web! Te contactaremos en 24 horas para discutir tu proyecto.',
                'app': '¡Perfecto! Nos especializamos en aplicaciones web. Te responderemos pronto con una propuesta.',
                'ecommerce': '¡Excelente! Te ayudaremos a crear tu tienda online. Esperamos tu llamada en breve.',
                'maintenance': '¡Mensaje recibido! Nuestro equipo de soporte técnico te contactará pronto.',
                'consulting': '¡Gracias! Programaremos una consultoría gratuita contigo en los próximos días.',
                'other': '¡Mensaje enviado con éxito! Te responderemos pronto para entender mejor tus necesidades.'
            };
            
            const successMessage = serviceMessages[serviceType] || serviceMessages['other'];
            showFormStatus('success', successMessage);
            contactForm.reset();
            clearAllValidationStates();
            
        } catch (error) {
            console.error('Error al enviar formulario:', error);
            showFormStatus('error', 'Hubo un error al enviar tu mensaje. Por favor, intenta de nuevo.');
        } finally {
            setLoadingState(false);
        }
    });

    // Función para validar un campo individual
    function validateField(fieldName, field) {
        const element = field.element;
        
        // Verificar que el elemento existe
        if (!element) {
            console.warn(`Campo ${fieldName} no encontrado en el DOM`);
            return true; // Considerar válido si no existe
        }
        
        const value = element.value.trim();
        const validators = field.validators;
        
        // Limpiar estados previos
        clearFieldValidation(element);
        
        // Ejecutar validadores
        for (const validator of validators) {
            const result = runValidator(validator, value, field);
            if (!result.isValid) {
                showFieldError(element, result.message);
                return false;
            }
        }
        
        // Campo válido
        showFieldSuccess(element);
        return true;
    }

    // Ejecutar validador específico
    function runValidator(validator, value, field) {
        switch (validator) {
            case 'required':
                return {
                    isValid: value.length > 0,
                    message: 'Este campo es obligatorio'
                };
            
            case 'email':
                if (!value) return { isValid: true }; // Campo requerido se valida por separado
                const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                return {
                    isValid: emailRegex.test(value),
                    message: 'Por favor, ingresa un email válido (ejemplo: usuario@dominio.com)'
                };
            
            case 'phone':
                if (!value) return { isValid: true }; // Campo opcional
                const phoneRegex = /^(\+51\s?)?[9][0-9]{8}$|^[\+]?[0-9\s\-\(\)]{9,15}$/;
                return {
                    isValid: phoneRegex.test(value.replace(/\s/g, '')),
                    message: 'Por favor, ingresa un teléfono válido (ej: +51 987654321 o formato internacional)'
                };
            
            case 'minLength':
                return {
                    isValid: value.length >= field.minLength,
                    message: `Debe tener al menos ${field.minLength} caracteres`
                };
            
            default:
                return { isValid: true };
        }
    }

    // Mostrar error en campo
    function showFieldError(element, message) {
        if (!element) return;
        
        element.classList.add('error');
        element.classList.remove('success');
        
        const container = element.parentNode.querySelector('.field-error-container');
        if (container) {
            container.innerHTML = `<div class="field-error">${message}</div>`;
        }
    }

    // Mostrar éxito en campo
    function showFieldSuccess(element) {
        if (!element) return;
        
        element.classList.add('success');
        element.classList.remove('error');
        
        const container = element.parentNode.querySelector('.field-error-container');
        if (container) {
            container.innerHTML = '<div class="field-success">Válido</div>';
        }
    }

    // Limpiar validación de campo
    function clearFieldValidation(element) {
        if (!element) return;
        
        element.classList.remove('error', 'success');
        const container = element.parentNode.querySelector('.field-error-container');
        if (container) {
            container.innerHTML = '';
        }
    }

    // Limpiar todos los estados de validación
    function clearAllValidationStates() {
        Object.keys(formFields).forEach(fieldName => {
            const element = formFields[fieldName].element;
            if (element) {
                clearFieldValidation(element);
            }
        });
    }

    // Mostrar estado del formulario
    function showFormStatus(type, message) {
        if (!formStatus) return;
        
        formStatus.className = `form__status ${type}`;
        formStatus.textContent = message;
        
        // Auto-ocultar mensajes después de 5 segundos (excepto loading)
        if (type !== 'loading') {
            setTimeout(() => {
                formStatus.style.display = 'none';
            }, 5000);
        }
    }

    // Controlar estado de carga del botón
    function setLoadingState(isLoading) {
        if (!submitBtn || !btnText || !btnLoading) return;
        
        if (isLoading) {
            submitBtn.disabled = true;
            btnText.style.display = 'none';
            btnLoading.style.display = 'flex';
        } else {
            submitBtn.disabled = false;
            btnText.style.display = 'inline';
            btnLoading.style.display = 'none';
        }
    }

    // Simular envío del formulario (reemplazar con implementación real)
    async function simulateFormSubmission(formData) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                // Simular éxito/error aleatorio para demostración
                if (Math.random() > 0.1) { // 90% éxito
                    console.log('Formulario enviado:', formData);
                    resolve({ success: true, message: 'Mensaje enviado correctamente' });
                } else {
                    reject(new Error('Error simulado del servidor'));
                }
            }, 2000); // Simular delay de red
        });
    }
}

// Smooth scroll para enlaces de navegación
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        
        if (target) {
            const headerOffset = 80;
            const elementPosition = target.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
            
            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// Efecto de escritura en el título (opcional)
const heroTitle = document.querySelector('.hero__title');
if (heroTitle) {
    const text = heroTitle.textContent;
    heroTitle.textContent = '';
    let i = 0;
    
    function typeWriter() {
        if (i < text.length) {
            heroTitle.textContent += text.charAt(i);
            i++;
            setTimeout(typeWriter, 50);
        }
    }
    
    // Iniciar efecto después de un pequeño delay
    setTimeout(typeWriter, 500);
}

// Contador animado para estadísticas
const stats = document.querySelectorAll('.stat__number');
const animateCounter = (element) => {
    const target = parseInt(element.textContent.replace(/\D/g, ''));
    const duration = 2000;
    const increment = target / (duration / 16);
    let current = 0;
    
    const updateCounter = () => {
        current += increment;
        if (current < target) {
            element.textContent = Math.floor(current) + '+';
            requestAnimationFrame(updateCounter);
        } else {
            element.textContent = target + '+';
        }
    };
    
    updateCounter();
};

// Observar estadísticas para animar el contador
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumber = entry.target.querySelector('.stat__number');
            if (statNumber && !statNumber.dataset.animated) {
                statNumber.dataset.animated = 'true';
                animateCounter(statNumber);
            }
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat').forEach(stat => {
    statsObserver.observe(stat);
});

// ===== SERVICES PAGE FUNCTIONALITY =====
function initServicesPage() {
    // Animate service cards on scroll
    const serviceCards = document.querySelectorAll('.service-detail-card');
    const techItems = document.querySelectorAll('.tech-item');
    const timelineItems = document.querySelectorAll('.timeline-item');
    
    // Enhanced scroll observer for services
    const servicesObserver = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, index * 100); // Stagger animation
            }
        });
    }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
    
    // Observe service cards
    serviceCards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        card.style.transition = `opacity 0.6s ease ${index * 0.1}s, transform 0.6s ease ${index * 0.1}s`;
        servicesObserver.observe(card);
    });
    
    // Observe tech items
    techItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'translateY(20px)';
        item.style.transition = `opacity 0.4s ease ${index * 0.05}s, transform 0.4s ease ${index * 0.05}s`;
        servicesObserver.observe(item);
    });
    
    // Observe timeline items
    timelineItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'translateX(-30px)';
        item.style.transition = `opacity 0.6s ease ${index * 0.2}s, transform 0.6s ease ${index * 0.2}s`;
        servicesObserver.observe(item);
    });
    
    // Add hover effects to CTA buttons
    const ctaButtons = document.querySelectorAll('.cta-buttons .btn');
    ctaButtons.forEach(btn => {
        btn.addEventListener('mouseenter', () => {
            btn.style.transform = 'translateY(-3px) scale(1.05)';
        });
        
        btn.addEventListener('mouseleave', () => {
            btn.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Service card click tracking (for analytics)
    serviceCards.forEach(card => {
        const serviceTitle = card.querySelector('.service__title')?.textContent || 'Unknown';
        const ctaButton = card.querySelector('.btn');
        
        if (ctaButton) {
            ctaButton.addEventListener('click', (e) => {
                // Track service interest (replace with actual analytics)
                console.log(`Service CTA clicked: ${serviceTitle}`);
                
                // Add visual feedback
                ctaButton.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    ctaButton.style.transform = 'scale(1)';
                }, 150);
            });
        }
    });
    
    // Smooth scroll for service navigation
    const serviceNavLinks = document.querySelectorAll('a[href="#servicios-detalle"]');
    serviceNavLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const target = document.getElementById('servicios-detalle');
            if (target) {
                const headerOffset = 80;
                const elementPosition = target.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
    
    // Auto-populate contact form if coming from service CTA
    const urlParams = new URLSearchParams(window.location.search);
    const serviceParam = urlParams.get('servicio');
    
    if (serviceParam) {
        // If on contact page, pre-select service type
        const serviceSelect = document.getElementById('service-type');
        if (serviceSelect) {
            const serviceMap = {
                'desarrollo-web': 'web',
                'aplicaciones-web': 'app',
                'ecommerce': 'ecommerce',
                'diseno-uiux': 'design',
                'optimizacion': 'optimization',
                'mantenimiento': 'maintenance'
            };
            
            const serviceValue = serviceMap[serviceParam];
            if (serviceValue) {
                serviceSelect.value = serviceValue;
                
                // Add visual highlight
                serviceSelect.style.borderColor = 'var(--primary-color)';
                serviceSelect.style.backgroundColor = 'var(--bg-light)';
            }
        }
    }
}

// ===== CURRENCY EXCHANGE FUNCTIONALITY =====
function initCurrencyExchange() {
    const currencySelect = document.getElementById('currency-select');
    const exchangeRateDisplay = document.getElementById('exchange-rate');
    const priceElements = document.querySelectorAll('.pricing-card__amount');
    const currencySymbols = document.querySelectorAll('.pricing-card__currency');
    
    if (!currencySelect || !exchangeRateDisplay) return;
    
    let currentExchangeRate = 3.75; // Tasa por defecto actualizada
    let isLoading = false;
    
    // Función para obtener la tasa de cambio real
    async function fetchExchangeRate() {
        if (isLoading) return currentExchangeRate;
        
        isLoading = true;
        updateExchangeRateDisplay('loading');
        
        try {
            // Usar API gratuita confiable
            const response = await fetch('https://api.exchangerate-api.com/v4/latest/USD');
            
            if (response.ok) {
                const data = await response.json();
                
                if (data.rates && data.rates.PEN) {
                    currentExchangeRate = parseFloat(data.rates.PEN);
                    updateExchangeRateDisplay('success', currentExchangeRate);
                    
                    // Guardar en localStorage
                    const cacheData = {
                        rate: currentExchangeRate,
                        timestamp: Date.now()
                    };
                    localStorage.setItem('usd_pen_rate', JSON.stringify(cacheData));
                    
                    return currentExchangeRate;
                }
            }
            
            // Fallback: usar caché o tasa por defecto
            const cachedData = getCachedExchangeRate();
            if (cachedData) {
                currentExchangeRate = cachedData.rate;
                updateExchangeRateDisplay('cached', currentExchangeRate);
            } else {
                currentExchangeRate = 3.75;
                updateExchangeRateDisplay('fallback', currentExchangeRate);
            }
            
        } catch (error) {
            console.error('Error obteniendo tasa de cambio:', error);
            currentExchangeRate = 3.75;
            updateExchangeRateDisplay('error', currentExchangeRate);
        } finally {
            isLoading = false;
        }
        
        return currentExchangeRate;
    }
    
    // Función para obtener tasa de cambio del caché
    function getCachedExchangeRate() {
        try {
            const cached = localStorage.getItem('usd_pen_rate');
            if (!cached) return null;
            
            const data = JSON.parse(cached);
            const now = Date.now();
            const oneHour = 60 * 60 * 1000;
            
            if (now - data.timestamp < oneHour) {
                return data;
            }
            
            return null;
        } catch (error) {
            return null;
        }
    }
    
    // Función para actualizar la visualización de la tasa de cambio
    function updateExchangeRateDisplay(status, rate) {
        if (!exchangeRateDisplay) return;
        
        exchangeRateDisplay.className = 'currency-selector__rate ' + status;
        
        switch (status) {
            case 'loading':
                exchangeRateDisplay.innerHTML = '<span class="rate-loading">🔄 Obteniendo tasa actual...</span>';
                break;
            case 'success':
                exchangeRateDisplay.innerHTML = '<span class="rate-value">1 USD = S/ ' + rate.toFixed(3) + '<br><small style="opacity: 0.7;">Actualizado</small></span>';
                break;
            case 'cached':
                exchangeRateDisplay.innerHTML = '<span class="rate-value">1 USD = S/ ' + rate.toFixed(3) + '<br><small style="opacity: 0.7;">Reciente</small></span>';
                break;
            case 'fallback':
                exchangeRateDisplay.innerHTML = '<span class="rate-value">1 USD ≈ S/ ' + rate.toFixed(3) + '<br><small style="opacity: 0.7;">Estimado</small></span>';
                break;
            case 'error':
                exchangeRateDisplay.innerHTML = '<span class="rate-error">1 USD ≈ S/ ' + rate.toFixed(3) + '<br><small style="opacity: 0.7;">Sin conexión</small></span>';
                break;
        }
    }
    
    // Función para actualizar precios
    function updatePrices(currency) {
        priceElements.forEach(function(element, index) {
            const penPrice = parseFloat(element.getAttribute('data-price-pen'));
            let displayPrice;
            let currencySymbol;
            
            if (currency === 'USD') {
                displayPrice = Math.round(penPrice / currentExchangeRate);
                currencySymbol = '$';
            } else {
                displayPrice = penPrice;
                currencySymbol = 'S/';
            }
            
            // Animación de cambio de precio
            element.classList.add('price-updated');
            setTimeout(function() {
                element.textContent = displayPrice.toLocaleString();
                element.classList.remove('price-updated');
            }, 150);
            
            // Actualizar símbolo de moneda
            if (currencySymbols[index]) {
                currencySymbols[index].textContent = currencySymbol;
            }
        });
    }
    
    // Event listener para cambio de moneda
    currencySelect.addEventListener('change', async function(e) {
        const selectedCurrency = e.target.value;
        
        if (selectedCurrency === 'USD') {
            await fetchExchangeRate();
        }
        
        updatePrices(selectedCurrency);
        localStorage.setItem('preferred_currency', selectedCurrency);
    });
    
    // Inicializar funcionalidad
    async function initializeCurrency() {
        const preferredCurrency = localStorage.getItem('preferred_currency') || 'PEN';
        currencySelect.value = preferredCurrency;
        
        await fetchExchangeRate();
        updatePrices(preferredCurrency);
        
        // Actualizar cada 30 minutos
        setInterval(async function() {
            if (currencySelect.value === 'USD') {
                await fetchExchangeRate();
                updatePrices('USD');
            }
        }, 30 * 60 * 1000);
    }
    
    // Botón de actualización manual
    const refreshButton = document.createElement('button');
    refreshButton.innerHTML = '↻';
    refreshButton.className = 'rate-refresh-btn';
    refreshButton.title = 'Actualizar tasa de cambio';
    
    refreshButton.addEventListener('click', async function() {
        refreshButton.style.transform = 'rotate(360deg)';
        await fetchExchangeRate();
        if (currencySelect.value === 'USD') {
            updatePrices('USD');
        }
        setTimeout(function() {
            refreshButton.style.transform = 'rotate(0deg)';
        }, 500);
    });
    
    exchangeRateDisplay.appendChild(refreshButton);
    initializeCurrency();
}

// ===== TIMEZONE AND LOCAL TIME FUNCTIONALITY =====
function initTimezone() {
    // Mostrar hora local de Perú en la página de contacto
    const timeElements = document.querySelectorAll('.local-time');
    
    function updatePeruTime() {
        const now = new Date();
        const peruTime = new Intl.DateTimeFormat('es-PE', {
            timeZone: 'America/Lima',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        }).format(now);
        
        const peruDate = new Intl.DateTimeFormat('es-PE', {
            timeZone: 'America/Lima',
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }).format(now);
        
        timeElements.forEach(element => {
            element.innerHTML = `
                <div style="font-size: 0.9rem; color: var(--text-light);">
                    🕒 Hora local en Perú: <strong>${peruTime}</strong><br>
                    📅 ${peruDate}
                </div>
            `;
        });
    }
    
    if (timeElements.length > 0) {
        updatePeruTime();
        setInterval(updatePeruTime, 1000); // Actualizar cada segundo
    }
}

// ===== POLICY PAGES FUNCTIONALITY =====
function initPolicyPages() {
    // Automatic date update for policy pages
    const lastUpdatedElements = document.querySelectorAll('#last-updated');
    
    if (lastUpdatedElements.length > 0) {
        const currentDate = new Date();
        const formattedDate = new Intl.DateTimeFormat('es-ES', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }).format(currentDate);
        
        lastUpdatedElements.forEach(element => {
            element.textContent = formattedDate;
        });
    }
    
    // Smooth scroll for table of contents links
    const tocLinks = document.querySelectorAll('.policy-toc a[href^="#"]');
    tocLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = link.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                const headerOffset = 100;
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
                
                // Add highlight effect to the target section
                targetElement.style.backgroundColor = 'rgba(99, 102, 241, 0.05)';
                targetElement.style.transition = 'background-color 0.3s ease';
                
                setTimeout(() => {
                    targetElement.style.backgroundColor = 'transparent';
                }, 2000);
            }
        });
    });
    
    // Add reading progress indicator for policy pages
    const policyPage = document.querySelector('.policy-page');
    if (policyPage) {
        const progressBar = document.createElement('div');
        progressBar.style.cssText = `
            position: fixed;
            top: 70px;
            left: 0;
            width: 0%;
            height: 3px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            z-index: 1000;
            transition: width 0.1s ease;
        `;
        document.body.appendChild(progressBar);
        
        window.addEventListener('scroll', () => {
            const scrollTop = window.pageYOffset;
            const docHeight = document.documentElement.scrollHeight - window.innerHeight;
            const scrollPercent = (scrollTop / docHeight) * 100;
            
            progressBar.style.width = Math.min(scrollPercent, 100) + '%';
        });
    }
    
    // Cross-reference navigation between policy pages
    const policyNavigation = document.querySelectorAll('a[href*="politicas/"]');
    policyNavigation.forEach(link => {
        link.addEventListener('click', (e) => {
            // Add loading state for better UX
            const originalText = link.textContent;
            link.textContent = 'Cargando...';
            link.style.opacity = '0.7';
            
            setTimeout(() => {
                link.textContent = originalText;
                link.style.opacity = '1';
            }, 500);
        });
    });
}

// Inicializar todas las funcionalidades cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    initContactForm();
    initFAQAccordion();
    initServicesPage();
    initCurrencyExchange();
    initTimezone();
    initPolicyPages();
});

// Agregar estilos CSS adicionales para animaciones
const additionalStyles = `
    .animate-on-scroll {
        opacity: 0;
        transform: translateY(30px);
        transition: opacity 0.6s ease, transform 0.6s ease;
    }
    
    .animate-on-scroll.animated {
        opacity: 1;
        transform: translateY(0);
    }
    
    img.lazy {
        opacity: 0;
        transition: opacity 0.3s;
    }
    
    img.lazy.loaded {
        opacity: 1;
    }
`;

// Agregar estilos al head
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet);

// ===== FAQ ACCORDION FUNCTIONALITY =====
function initFAQAccordion() {
    const faqItems = document.querySelectorAll('.faq-item');
    
    if (!faqItems.length) return;
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        const answer = item.querySelector('.faq-answer');
        
        if (!question || !answer) return;
        
        // Set initial state
        item.setAttribute('data-expanded', 'false');
        
        question.addEventListener('click', () => {
            const isExpanded = item.getAttribute('data-expanded') === 'true';
            
            // Close all other FAQ items
            faqItems.forEach(otherItem => {
                if (otherItem !== item) {
                    otherItem.setAttribute('data-expanded', 'false');
                    const otherQuestion = otherItem.querySelector('.faq-question');
                    if (otherQuestion) {
                        otherQuestion.setAttribute('aria-expanded', 'false');
                    }
                }
            });
            
            // Toggle current item
            const newState = !isExpanded;
            item.setAttribute('data-expanded', newState.toString());
            question.setAttribute('aria-expanded', newState.toString());
            
            // Smooth scroll to question if opening and not in viewport
            if (newState) {
                setTimeout(() => {
                    const rect = question.getBoundingClientRect();
                    const headerHeight = 80;
                    
                    if (rect.top < headerHeight) {
                        const elementPosition = question.getBoundingClientRect().top;
                        const offsetPosition = elementPosition + window.pageYOffset - headerHeight - 20;
                        
                        window.scrollTo({
                            top: offsetPosition,
                            behavior: 'smooth'
                        });
                    }
                }, 300); // Wait for animation to start
            }
        });
        
        // Keyboard accessibility
        question.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                question.click();
            }
        });
    });
}

// ========================================
// PERFORMANCE OPTIMIZATIONS
// ========================================

// Enhanced Lazy Loading Implementation
function initLazyLoading() {
    // Check if Intersection Observer is supported
    if ('IntersectionObserver' in window) {
        const lazyImages = document.querySelectorAll('img[data-src], .lazy-image');
        
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    
                    // Handle images with data-src attribute
                    if (img.hasAttribute('data-src')) {
                        const src = img.getAttribute('data-src');
                        const webpSrc = img.getAttribute('data-webp');
                        
                        // Check WebP support and use appropriate format
                        checkWebPSupport().then(supportsWebP => {
                            const finalSrc = supportsWebP && webpSrc ? webpSrc : src;
                            
                            // Preload image
                            const imageLoader = new Image();
                            imageLoader.onload = () => {
                                img.src = finalSrc;
                                img.classList.add('loaded');
                                img.removeAttribute('data-src');
                                img.removeAttribute('data-webp');
                                
                                // Trigger custom event for analytics
                                img.dispatchEvent(new CustomEvent('imageLoaded', {
                                    detail: { src: finalSrc, webp: supportsWebP && webpSrc }
                                }));
                            };
                            imageLoader.onerror = () => {
                                img.classList.add('error');
                                console.warn('Failed to load image:', finalSrc);
                            };
                            imageLoader.src = finalSrc;
                        });
                    } else {
                        // Handle lazy-image class
                        img.classList.add('loaded');
                    }
                    
                    observer.unobserve(img);
                }
            });
        }, {
            rootMargin: '100px 0px', // Increased for better UX
            threshold: 0.1
        });
        
        lazyImages.forEach(img => imageObserver.observe(img));
    } else {
        // Fallback for browsers without Intersection Observer
        const lazyImages = document.querySelectorAll('img[data-src]');
        lazyImages.forEach(img => {
            const src = img.getAttribute('data-src');
            if (src) {
                img.src = src;
                img.classList.add('loaded');
                img.removeAttribute('data-src');
            }
        });
    }
}

// WebP Support Detection
function checkWebPSupport() {
    return new Promise(resolve => {
        const webP = new Image();
        webP.onload = webP.onerror = () => resolve(webP.height === 2);
        webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
    });
}

// Preload Critical Resources
function preloadCriticalResources() {
    const criticalResources = [
        { href: 'styles.css', as: 'style' },
        { href: 'assets/images/og-image.jpg', as: 'image' }
    ];
    
    criticalResources.forEach(resource => {
        const link = document.createElement('link');
        link.rel = 'preload';
        link.href = resource.href;
        link.as = resource.as;
        
        if (resource.as === 'style') {
            link.onload = () => {
                link.rel = 'stylesheet';
            };
        }
        
        document.head.appendChild(link);
    });
}

// Debounce Function for Performance
function debounce(func, wait, immediate) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            timeout = null;
            if (!immediate) func(...args);
        };
        const callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func(...args);
    };
}

// Throttle Function for Performance
function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Optimized Scroll Handler
const optimizedScrollHandler = throttle(() => {
    const currentScroll = window.pageYOffset;
    
    // Update header shadow
    if (header) {
        if (currentScroll > 100) {
            header.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.15)';
        } else {
            header.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
        }
    }
    
    // Update scroll progress (if element exists)
    const scrollProgress = document.querySelector('.scroll-progress');
    if (scrollProgress) {
        const scrollPercent = (currentScroll / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
        scrollProgress.style.width = `${Math.min(scrollPercent, 100)}%`;
    }
}, 16); // ~60fps

// Replace the existing scroll listener with optimized version
window.removeEventListener('scroll', () => {}); // Remove existing if any
window.addEventListener('scroll', optimizedScrollHandler, { passive: true });

// Optimized Resize Handler
const optimizedResizeHandler = debounce(() => {
    // Recalculate layouts that depend on window size
    const portfolioGrid = document.querySelector('.portfolio-grid');
    if (portfolioGrid) {
        // Trigger reflow for masonry-like layouts
        portfolioGrid.style.display = 'none';
        portfolioGrid.offsetHeight; // Trigger reflow
        portfolioGrid.style.display = '';
    }
}, 250);

window.addEventListener('resize', optimizedResizeHandler, { passive: true });

// Performance Monitoring
function initPerformanceMonitoring() {
    // Monitor Core Web Vitals
    if ('web-vital' in window) {
        // This would integrate with web-vitals library if available
        console.log('Web Vitals monitoring initialized');
    }
    
    // Monitor resource loading
    if ('PerformanceObserver' in window) {
        const observer = new PerformanceObserver((list) => {
            list.getEntries().forEach((entry) => {
                if (entry.entryType === 'navigation') {
                    console.log('Page Load Time:', entry.loadEventEnd - entry.loadEventStart);
                }
                
                if (entry.entryType === 'resource' && entry.duration > 1000) {
                    console.warn('Slow resource:', entry.name, entry.duration + 'ms');
                }
            });
        });
        
        observer.observe({ entryTypes: ['navigation', 'resource'] });
    }
}

// Critical CSS Loading
function loadNonCriticalCSS() {
    const nonCriticalCSS = [
        // Add paths to non-critical CSS files here
    ];
    
    nonCriticalCSS.forEach(href => {
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = href;
        link.media = 'print';
        link.onload = () => {
            link.media = 'all';
        };
        document.head.appendChild(link);
    });
}

// Service Worker Registration (for caching)
function registerServiceWorker() {
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('/sw.js')
                .then(registration => {
                    console.log('SW registered: ', registration);
                })
                .catch(registrationError => {
                    console.log('SW registration failed: ', registrationError);
                });
        });
    }
}

// Optimize Form Performance
function optimizeFormPerformance() {
    const forms = document.querySelectorAll('form');
    
    forms.forEach(form => {
        // Add input debouncing for real-time validation
        const inputs = form.querySelectorAll('input, textarea, select');
        
        inputs.forEach(input => {
            const debouncedValidation = debounce(() => {
                // Trigger validation
                if (input.checkValidity) {
                    input.checkValidity();
                }
            }, 300);
            
            input.addEventListener('input', debouncedValidation);
        });
    });
}

// Memory Management
function cleanupEventListeners() {
    // Clean up any global event listeners when page unloads
    window.addEventListener('beforeunload', () => {
        // Remove observers
        if (scrollObserver) {
            scrollObserver.disconnect();
        }
        
        // Clear timeouts/intervals
        // Add any cleanup code here
    });
}

// Initialize Performance Optimizations
function initPerformanceOptimizations() {
    // Run immediately
    preloadCriticalResources();
    initLazyLoading();
    optimizeFormPerformance();
    cleanupEventListeners();
    
    // Run after page load
    window.addEventListener('load', () => {
        loadNonCriticalCSS();
        initPerformanceMonitoring();
        registerServiceWorker();
    });
}

// Critical Performance Initialization
// Run as early as possible
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initPerformanceOptimizations);
} else {
    initPerformanceOptimizations();
}

// Initialize enhanced lazy loading if available
if (typeof UWEBLazyLoading !== 'undefined') {
    // Configure for better performance
    UWEBLazyLoading.config.rootMargin = '150px 0px';
    UWEBLazyLoading.config.enablePerformanceMonitoring = true;
    
    // Re-initialize after dynamic content loads
    document.addEventListener('portfolioLoaded', () => {
        setTimeout(() => {
            UWEBLazyLoading.init();
        }, 100);
    });
}

// Add performance hints to existing functions
const originalInitContactForm = initContactForm;
initContactForm = function() {
    // Add performance wrapper
    const startTime = performance.now();
    originalInitContactForm.apply(this, arguments);
    const endTime = performance.now();
    console.log(`Contact form initialization took ${endTime - startTime} milliseconds`);
};

// Optimize existing intersection observer
if (scrollObserver) {
    // Add performance improvements to existing observer
    const originalCallback = scrollObserver.callback;
    scrollObserver.callback = throttle(originalCallback, 16); // 60fps limit
}

console.log('🚀 Performance optimizations loaded');