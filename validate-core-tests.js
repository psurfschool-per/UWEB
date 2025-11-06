// Validation script for core functionality tests
// This script can be run in the browser console to validate test results

console.log('🧪 Validando funcionalidad core del sitio UWEB...');

// Test 1: Navigation validation
function validateNavigation() {
    console.log('\n🧭 Validando navegación...');
    
    const tests = [];
    
    // Check if main navigation exists
    const navMenu = document.querySelector('.nav__menu');
    tests.push({
        name: 'Menú de navegación principal',
        passed: navMenu !== null,
        element: navMenu
    });
    
    // Check navigation links
    const navLinks = document.querySelectorAll('.nav__link');
    tests.push({
        name: 'Enlaces de navegación',
        passed: navLinks.length >= 5,
        details: `${navLinks.length} enlaces encontrados`
    });
    
    // Check mobile toggle
    const mobileToggle = document.querySelector('.nav__toggle');
    tests.push({
        name: 'Toggle de navegación móvil',
        passed: mobileToggle !== null,
        element: mobileToggle
    });
    
    // Check footer links
    const footerLinks = document.querySelectorAll('.footer__links a');
    tests.push({
        name: 'Enlaces del footer',
        passed: footerLinks.length >= 5,
        details: `${footerLinks.length} enlaces en footer`
    });
    
    return tests;
}

// Test 2: Contact form validation
function validateContactForm() {
    console.log('\n📝 Validando formulario de contacto...');
    
    const tests = [];
    
    // Check if contact form exists
    const contactForm = document.getElementById('contact-form');
    tests.push({
        name: 'Formulario de contacto',
        passed: contactForm !== null,
        element: contactForm
    });
    
    if (contactForm) {
        // Check required fields
        const requiredFields = contactForm.querySelectorAll('[required]');
        tests.push({
            name: 'Campos requeridos',
            passed: requiredFields.length >= 4,
            details: `${requiredFields.length} campos requeridos`
        });
        
        // Check error containers
        const errorContainers = contactForm.querySelectorAll('.field-error-container');
        tests.push({
            name: 'Contenedores de error',
            passed: errorContainers.length >= 4,
            details: `${errorContainers.length} contenedores de error`
        });
        
        // Check submit button
        const submitBtn = contactForm.querySelector('button[type="submit"]');
        tests.push({
            name: 'Botón de envío',
            passed: submitBtn !== null,
            element: submitBtn
        });
        
        // Check form status element
        const formStatus = document.getElementById('form-status');
        tests.push({
            name: 'Elemento de estado del formulario',
            passed: formStatus !== null,
            element: formStatus
        });
    }
    
    return tests;
}

// Test 3: Portfolio functionality validation
function validatePortfolio() {
    console.log('\n🎨 Validando funcionalidad del portafolio...');
    
    const tests = [];
    
    // Check portfolio grid
    const portfolioGrid = document.getElementById('portfolio-grid');
    tests.push({
        name: 'Grid del portafolio',
        passed: portfolioGrid !== null,
        element: portfolioGrid
    });
    
    // Check filter buttons
    const filterBtns = document.querySelectorAll('.filter-btn');
    tests.push({
        name: 'Botones de filtro',
        passed: filterBtns.length >= 4,
        details: `${filterBtns.length} filtros encontrados`
    });
    
    // Check portfolio modal
    const portfolioModal = document.getElementById('portfolio-modal');
    tests.push({
        name: 'Modal del portafolio',
        passed: portfolioModal !== null,
        element: portfolioModal
    });
    
    // Check if projects data is accessible
    const hasProjectsData = typeof window.fetch !== 'undefined';
    tests.push({
        name: 'Capacidad de cargar datos de proyectos',
        passed: hasProjectsData,
        details: hasProjectsData ? 'Fetch API disponible' : 'Fetch API no disponible'
    });
    
    return tests;
}

// Test 4: JavaScript functionality validation
function validateJavaScript() {
    console.log('\n⚙️ Validando funcionalidad JavaScript...');
    
    const tests = [];
    
    // Check if main script functions exist
    const hasInitContactForm = typeof initContactForm === 'function';
    tests.push({
        name: 'Función initContactForm',
        passed: hasInitContactForm,
        details: hasInitContactForm ? 'Función encontrada' : 'Función no encontrada'
    });
    
    // Check if FAQ functionality exists
    const faqItems = document.querySelectorAll('.faq-item');
    tests.push({
        name: 'Elementos FAQ',
        passed: faqItems.length > 0,
        details: `${faqItems.length} elementos FAQ encontrados`
    });
    
    // Check if scroll observer is working
    const hasIntersectionObserver = 'IntersectionObserver' in window;
    tests.push({
        name: 'Intersection Observer API',
        passed: hasIntersectionObserver,
        details: hasIntersectionObserver ? 'API disponible' : 'API no disponible'
    });
    
    // Check if local storage is available
    const hasLocalStorage = typeof Storage !== 'undefined';
    tests.push({
        name: 'Local Storage',
        passed: hasLocalStorage,
        details: hasLocalStorage ? 'Disponible' : 'No disponible'
    });
    
    return tests;
}

// Main validation function
function runAllValidations() {
    console.log('🚀 Ejecutando todas las validaciones...\n');
    
    const allTests = [
        ...validateNavigation(),
        ...validateContactForm(),
        ...validatePortfolio(),
        ...validateJavaScript()
    ];
    
    // Calculate results
    const totalTests = allTests.length;
    const passedTests = allTests.filter(test => test.passed).length;
    const failedTests = totalTests - passedTests;
    const successRate = Math.round((passedTests / totalTests) * 100);
    
    // Display results
    console.log('\n📊 RESUMEN DE RESULTADOS:');
    console.log(`Total de pruebas: ${totalTests}`);
    console.log(`Pruebas exitosas: ${passedTests}`);
    console.log(`Pruebas fallidas: ${failedTests}`);
    console.log(`Tasa de éxito: ${successRate}%`);
    
    // Display failed tests
    if (failedTests > 0) {
        console.log('\n❌ PRUEBAS FALLIDAS:');
        allTests.filter(test => !test.passed).forEach(test => {
            console.log(`- ${test.name}: ${test.details || 'Elemento no encontrado'}`);
        });
    }
    
    // Display passed tests
    console.log('\n✅ PRUEBAS EXITOSAS:');
    allTests.filter(test => test.passed).forEach(test => {
        console.log(`- ${test.name}: ${test.details || 'OK'}`);
    });
    
    return {
        total: totalTests,
        passed: passedTests,
        failed: failedTests,
        successRate: successRate,
        tests: allTests
    };
}

// Auto-run if in browser
if (typeof window !== 'undefined') {
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            setTimeout(runAllValidations, 1000);
        });
    } else {
        setTimeout(runAllValidations, 1000);
    }
}

// Export for manual use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        validateNavigation,
        validateContactForm,
        validatePortfolio,
        validateJavaScript,
        runAllValidations
    };
}