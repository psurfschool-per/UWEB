    </main>
    
    <!-- Footer del Admin -->
    <footer class="admin-footer">
        <div class="admin-footer__container">
            <div class="admin-footer__content">
                <div class="admin-footer__section">
                    <p class="admin-footer__text">
                        © <?php echo date('Y'); ?> <strong>UWEB</strong> - Sistema de Gestión de Contactos
                    </p>
                    <p class="admin-footer__version">
                        Versión 1.0 | 
                        <a href="https://uweb.com" target="_blank" class="admin-footer__link">Sitio Web</a> |
                        <a href="mailto:soporte@uweb.com" class="admin-footer__link">Soporte</a>
                    </p>
                </div>
                
                <div class="admin-footer__section">
                    <div class="admin-footer__stats">
                        <span class="admin-footer__stat">
                            🕒 Última actualización: <span id="last-update"><?php echo date('H:i:s'); ?></span>
                        </span>
                        <span class="admin-footer__stat">
                            👤 Usuario: <?php echo htmlspecialchars($_SESSION['admin_username'] ?? 'admin'); ?>
                        </span>
                        <span class="admin-footer__stat">
                            🌐 IP: <?php echo getClientIP(); ?>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Modal de confirmación global -->
    <div class="modal-overlay" id="confirm-modal-overlay">
        <div class="modal modal--confirm" id="confirm-modal">
            <div class="modal__header">
                <h3 class="modal__title" id="confirm-modal-title">Confirmar Acción</h3>
            </div>
            <div class="modal__body">
                <p class="modal__message" id="confirm-modal-message">¿Estás seguro de que deseas realizar esta acción?</p>
            </div>
            <div class="modal__footer">
                <button class="btn btn--secondary" id="confirm-modal-cancel">Cancelar</button>
                <button class="btn btn--danger" id="confirm-modal-confirm">Confirmar</button>
            </div>
        </div>
    </div>
    
    <!-- Modal de loading global -->
    <div class="modal-overlay" id="loading-modal-overlay">
        <div class="modal modal--loading" id="loading-modal">
            <div class="modal__body">
                <div class="loading-spinner"></div>
                <p class="modal__message" id="loading-modal-message">Procesando...</p>
            </div>
        </div>
    </div>
    
    <!-- Toast notifications container -->
    <div class="toast-container" id="toast-container"></div>
    
    <!-- JavaScript del Admin -->
    <script src="assets/js/admin.js"></script>
    
    <!-- JavaScript específico de la página (si existe) -->
    <?php if (isset($pageScript)): ?>
        <script src="assets/js/<?php echo $pageScript; ?>"></script>
    <?php endif; ?>
    
    <script>
    // Funciones globales del admin
    
    // Actualizar timestamp del footer cada minuto
    setInterval(function() {
        document.getElementById('last-update').textContent = new Date().toLocaleTimeString('es-PE', {
            hour12: false,
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    }, 60000);
    
    // Función global para mostrar modal de confirmación
    window.showConfirmModal = function(title, message, onConfirm, onCancel = null) {
        const overlay = document.getElementById('confirm-modal-overlay');
        const modal = document.getElementById('confirm-modal');
        const titleEl = document.getElementById('confirm-modal-title');
        const messageEl = document.getElementById('confirm-modal-message');
        const confirmBtn = document.getElementById('confirm-modal-confirm');
        const cancelBtn = document.getElementById('confirm-modal-cancel');
        
        titleEl.textContent = title;
        messageEl.textContent = message;
        
        // Limpiar event listeners anteriores
        const newConfirmBtn = confirmBtn.cloneNode(true);
        const newCancelBtn = cancelBtn.cloneNode(true);
        confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
        cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
        
        // Agregar nuevos event listeners
        newConfirmBtn.addEventListener('click', function() {
            hideConfirmModal();
            if (onConfirm) onConfirm();
        });
        
        newCancelBtn.addEventListener('click', function() {
            hideConfirmModal();
            if (onCancel) onCancel();
        });
        
        overlay.style.display = 'flex';
        modal.classList.add('show');
        document.body.classList.add('no-scroll');
    };
    
    // Función para ocultar modal de confirmación
    window.hideConfirmModal = function() {
        const overlay = document.getElementById('confirm-modal-overlay');
        const modal = document.getElementById('confirm-modal');
        
        modal.classList.remove('show');
        setTimeout(() => {
            overlay.style.display = 'none';
            document.body.classList.remove('no-scroll');
        }, 300);
    };
    
    // Función global para mostrar modal de loading
    window.showLoadingModal = function(message = 'Procesando...') {
        const overlay = document.getElementById('loading-modal-overlay');
        const messageEl = document.getElementById('loading-modal-message');
        
        messageEl.textContent = message;
        overlay.style.display = 'flex';
        document.body.classList.add('no-scroll');
    };
    
    // Función para ocultar modal de loading
    window.hideLoadingModal = function() {
        const overlay = document.getElementById('loading-modal-overlay');
        
        setTimeout(() => {
            overlay.style.display = 'none';
            document.body.classList.remove('no-scroll');
        }, 300);
    };
    
    // Función global para mostrar toast notifications
    window.showToast = function(message, type = 'info', duration = 5000) {
        const container = document.getElementById('toast-container');
        const toast = document.createElement('div');
        
        toast.className = `toast toast--${type}`;
        toast.innerHTML = `
            <div class="toast__content">
                <span class="toast__icon">${getToastIcon(type)}</span>
                <span class="toast__message">${message}</span>
            </div>
            <button class="toast__close" onclick="this.parentElement.remove()">×</button>
        `;
        
        container.appendChild(toast);
        
        // Mostrar toast
        setTimeout(() => toast.classList.add('show'), 100);
        
        // Auto-remover
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => toast.remove(), 300);
        }, duration);
    };
    
    // Obtener icono para toast según el tipo
    function getToastIcon(type) {
        const icons = {
            'success': '✅',
            'error': '❌',
            'warning': '⚠️',
            'info': 'ℹ️'
        };
        return icons[type] || icons.info;
    }
    
    // Función para confirmar eliminación
    window.confirmDelete = function(itemName, deleteUrl) {
        showConfirmModal(
            'Confirmar Eliminación',
            `¿Estás seguro de que deseas eliminar "${itemName}"? Esta acción no se puede deshacer.`,
            function() {
                showLoadingModal('Eliminando...');
                window.location.href = deleteUrl;
            }
        );
    };
    
    // Función para confirmar acción genérica
    window.confirmAction = function(actionName, actionUrl, itemName = '') {
        const message = itemName ? 
            `¿Estás seguro de que deseas ${actionName} "${itemName}"?` :
            `¿Estás seguro de que deseas ${actionName}?`;
            
        showConfirmModal(
            'Confirmar Acción',
            message,
            function() {
                showLoadingModal(`Procesando ${actionName}...`);
                window.location.href = actionUrl;
            }
        );
    };
    
    // Manejar formularios con confirmación
    document.addEventListener('DOMContentLoaded', function() {
        // Formularios que requieren confirmación
        const confirmForms = document.querySelectorAll('[data-confirm]');
        confirmForms.forEach(function(form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                
                const message = form.getAttribute('data-confirm');
                showConfirmModal(
                    'Confirmar Acción',
                    message,
                    function() {
                        showLoadingModal('Procesando...');
                        form.submit();
                    }
                );
            });
        });
        
        // Enlaces que requieren confirmación
        const confirmLinks = document.querySelectorAll('[data-confirm]');
        confirmLinks.forEach(function(link) {
            if (link.tagName === 'A') {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    const message = link.getAttribute('data-confirm');
                    const href = link.getAttribute('href');
                    
                    showConfirmModal(
                        'Confirmar Acción',
                        message,
                        function() {
                            showLoadingModal('Procesando...');
                            window.location.href = href;
                        }
                    );
                });
            }
        });
        
        // Cerrar modales con ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                hideConfirmModal();
                hideLoadingModal();
            }
        });
        
        // Cerrar modales al hacer clic en el overlay
        document.getElementById('confirm-modal-overlay').addEventListener('click', function(e) {
            if (e.target === this) {
                hideConfirmModal();
            }
        });
    });
    
    // Función para formatear números
    window.formatNumber = function(num) {
        return new Intl.NumberFormat('es-PE').format(num);
    };
    
    // Función para formatear fechas
    window.formatDate = function(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('es-PE', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        });
    };
    
    // Función para copiar al portapapeles
    window.copyToClipboard = function(text) {
        navigator.clipboard.writeText(text).then(function() {
            showToast('Copiado al portapapeles', 'success', 2000);
        }).catch(function() {
            showToast('Error al copiar', 'error', 2000);
        });
    };
    
    // Detectar si el usuario está inactivo (para auto-logout)
    let inactivityTimer;
    const INACTIVITY_TIMEOUT = <?php echo ADMIN_SESSION_TIMEOUT * 1000; ?>; // Convertir a milisegundos
    
    function resetInactivityTimer() {
        clearTimeout(inactivityTimer);
        inactivityTimer = setTimeout(function() {
            showToast('Sesión expirada por inactividad. Redirigiendo...', 'warning', 3000);
            setTimeout(function() {
                window.location.href = 'logout.php?reason=timeout';
            }, 3000);
        }, INACTIVITY_TIMEOUT);
    }
    
    // Eventos que resetean el timer de inactividad
    ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'].forEach(function(event) {
        document.addEventListener(event, resetInactivityTimer, true);
    });
    
    // Inicializar timer
    resetInactivityTimer();
    
    // Verificar conexión a internet
    window.addEventListener('online', function() {
        showToast('Conexión restaurada', 'success', 2000);
    });
    
    window.addEventListener('offline', function() {
        showToast('Sin conexión a internet', 'warning', 5000);
    });
    </script>
</body>
</html>