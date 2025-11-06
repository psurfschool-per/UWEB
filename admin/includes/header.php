<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    <title><?php echo $pageTitle ?? 'Panel de Administración - UWEB'; ?></title>
    
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="../favicon.ico">
    
    <!-- CSS del Admin -->
    <link rel="stylesheet" href="assets/css/admin.css">
    
    <!-- Fuentes -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Meta tags adicionales -->
    <meta name="description" content="Panel de administración del sistema de contactos UWEB">
    <meta name="author" content="UWEB">
</head>
<body class="admin-body">
    <!-- Header del Admin -->
    <header class="admin-header">
        <div class="admin-header__container">
            <!-- Logo y título -->
            <div class="admin-header__brand">
                <a href="index.php" class="admin-header__logo">
                    <h1>UWEB</h1>
                    <span class="admin-header__subtitle">Admin Panel</span>
                </a>
            </div>
            
            <!-- Navegación principal -->
            <nav class="admin-nav">
                <ul class="admin-nav__list">
                    <li class="admin-nav__item">
                        <a href="index.php" class="admin-nav__link <?php echo basename($_SERVER['PHP_SELF']) === 'index.php' ? 'admin-nav__link--active' : ''; ?>">
                            📊 Dashboard
                        </a>
                    </li>
                    <li class="admin-nav__item">
                        <a href="contactos.php" class="admin-nav__link <?php echo basename($_SERVER['PHP_SELF']) === 'contactos.php' ? 'admin-nav__link--active' : ''; ?>">
                            📧 Contactos
                            <?php 
                            $pendientes = obtenerConfiguracion('contactos_pendientes') ?? 0;
                            if ($pendientes > 0): 
                            ?>
                                <span class="admin-nav__badge"><?php echo $pendientes; ?></span>
                            <?php endif; ?>
                        </a>
                    </li>
                    <li class="admin-nav__item">
                        <a href="estadisticas.php" class="admin-nav__link <?php echo basename($_SERVER['PHP_SELF']) === 'estadisticas.php' ? 'admin-nav__link--active' : ''; ?>">
                            📈 Estadísticas
                        </a>
                    </li>
                    <li class="admin-nav__item">
                        <a href="configuracion.php" class="admin-nav__link <?php echo basename($_SERVER['PHP_SELF']) === 'configuracion.php' ? 'admin-nav__link--active' : ''; ?>">
                            ⚙️ Configuración
                        </a>
                    </li>
                </ul>
            </nav>
            
            <!-- Información del usuario y acciones -->
            <div class="admin-header__user">
                <!-- Notificaciones -->
                <div class="admin-header__notifications">
                    <button class="admin-header__notification-btn" id="notifications-btn">
                        🔔
                        <span class="admin-header__notification-count" id="notification-count" style="display: none;">0</span>
                    </button>
                    <div class="admin-header__notification-dropdown" id="notifications-dropdown">
                        <div class="notification-dropdown__header">
                            <h4>Notificaciones</h4>
                            <button class="notification-dropdown__clear" onclick="clearAllNotifications()">Limpiar</button>
                        </div>
                        <div class="notification-dropdown__content" id="notifications-content">
                            <p class="notification-dropdown__empty">No hay notificaciones nuevas</p>
                        </div>
                    </div>
                </div>
                
                <!-- Acciones rápidas -->
                <div class="admin-header__quick-actions">
                    <a href="../contacto.html" target="_blank" class="admin-header__action" title="Ver sitio web">
                        🌐
                    </a>
                    <a href="contactos.php?export=csv" class="admin-header__action" title="Exportar contactos">
                        📤
                    </a>
                </div>
                
                <!-- Menú de usuario -->
                <div class="admin-header__user-menu">
                    <button class="admin-header__user-btn" id="user-menu-btn">
                        <div class="admin-header__user-avatar">
                            <?php echo strtoupper(substr($_SESSION['admin_nombre'] ?? 'A', 0, 2)); ?>
                        </div>
                        <div class="admin-header__user-info">
                            <span class="admin-header__user-name"><?php echo htmlspecialchars($_SESSION['admin_nombre'] ?? 'Administrador'); ?></span>
                            <span class="admin-header__user-role"><?php echo ucfirst($_SESSION['admin_rol'] ?? 'admin'); ?></span>
                        </div>
                        <span class="admin-header__user-arrow">▼</span>
                    </button>
                    
                    <div class="admin-header__user-dropdown" id="user-dropdown">
                        <a href="perfil.php" class="admin-header__dropdown-item">
                            👤 Mi Perfil
                        </a>
                        <a href="configuracion.php" class="admin-header__dropdown-item">
                            ⚙️ Configuración
                        </a>
                        <div class="admin-header__dropdown-divider"></div>
                        <a href="logout.php" class="admin-header__dropdown-item admin-header__dropdown-item--danger">
                            🚪 Cerrar Sesión
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Botón de menú móvil -->
            <button class="admin-header__mobile-toggle" id="mobile-menu-toggle">
                <span></span>
                <span></span>
                <span></span>
            </button>
        </div>
    </header>
    
    <!-- Sidebar móvil -->
    <div class="admin-sidebar-mobile" id="mobile-sidebar">
        <div class="admin-sidebar-mobile__header">
            <h3>Menú</h3>
            <button class="admin-sidebar-mobile__close" id="mobile-sidebar-close">×</button>
        </div>
        <nav class="admin-sidebar-mobile__nav">
            <a href="index.php" class="admin-sidebar-mobile__link">📊 Dashboard</a>
            <a href="contactos.php" class="admin-sidebar-mobile__link">📧 Contactos</a>
            <a href="estadisticas.php" class="admin-sidebar-mobile__link">📈 Estadísticas</a>
            <a href="configuracion.php" class="admin-sidebar-mobile__link">⚙️ Configuración</a>
            <div class="admin-sidebar-mobile__divider"></div>
            <a href="../contacto.html" target="_blank" class="admin-sidebar-mobile__link">🌐 Ver Sitio</a>
            <a href="logout.php" class="admin-sidebar-mobile__link admin-sidebar-mobile__link--danger">🚪 Cerrar Sesión</a>
        </nav>
    </div>
    
    <!-- Overlay para móvil -->
    <div class="admin-overlay" id="mobile-overlay"></div>
    
    <!-- Contenido principal -->
    <main class="admin-main">
        <!-- Breadcrumbs (si están definidos) -->
        <?php if (isset($breadcrumbs) && !empty($breadcrumbs)): ?>
            <?php echo generarBreadcrumbs($breadcrumbs); ?>
        <?php endif; ?>
        
        <!-- Mensajes flash -->
        <?php if (isset($_SESSION['flash_message'])): ?>
            <div class="flash-message flash-message--<?php echo $_SESSION['flash_type'] ?? 'info'; ?>">
                <div class="flash-message__content">
                    <?php echo htmlspecialchars($_SESSION['flash_message']); ?>
                </div>
                <button class="flash-message__close" onclick="this.parentElement.remove()">×</button>
            </div>
            <?php 
            unset($_SESSION['flash_message']);
            unset($_SESSION['flash_type']);
            ?>
        <?php endif; ?>

<script>
// JavaScript para funcionalidad del header
document.addEventListener('DOMContentLoaded', function() {
    // Menú de usuario
    const userMenuBtn = document.getElementById('user-menu-btn');
    const userDropdown = document.getElementById('user-dropdown');
    
    if (userMenuBtn && userDropdown) {
        userMenuBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            userDropdown.classList.toggle('show');
        });
    }
    
    // Notificaciones
    const notificationsBtn = document.getElementById('notifications-btn');
    const notificationsDropdown = document.getElementById('notifications-dropdown');
    
    if (notificationsBtn && notificationsDropdown) {
        notificationsBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            notificationsDropdown.classList.toggle('show');
            loadNotifications();
        });
    }
    
    // Menú móvil
    const mobileToggle = document.getElementById('mobile-menu-toggle');
    const mobileSidebar = document.getElementById('mobile-sidebar');
    const mobileOverlay = document.getElementById('mobile-overlay');
    const mobileSidebarClose = document.getElementById('mobile-sidebar-close');
    
    if (mobileToggle && mobileSidebar) {
        mobileToggle.addEventListener('click', function() {
            mobileSidebar.classList.add('show');
            mobileOverlay.classList.add('show');
            document.body.classList.add('no-scroll');
        });
    }
    
    if (mobileSidebarClose) {
        mobileSidebarClose.addEventListener('click', closeMobileSidebar);
    }
    
    if (mobileOverlay) {
        mobileOverlay.addEventListener('click', closeMobileSidebar);
    }
    
    function closeMobileSidebar() {
        mobileSidebar.classList.remove('show');
        mobileOverlay.classList.remove('show');
        document.body.classList.remove('no-scroll');
    }
    
    // Cerrar dropdowns al hacer clic fuera
    document.addEventListener('click', function() {
        if (userDropdown) userDropdown.classList.remove('show');
        if (notificationsDropdown) notificationsDropdown.classList.remove('show');
    });
    
    // Auto-ocultar mensajes flash
    const flashMessages = document.querySelectorAll('.flash-message');
    flashMessages.forEach(function(message) {
        setTimeout(function() {
            message.style.opacity = '0';
            setTimeout(function() {
                message.remove();
            }, 300);
        }, 5000);
    });
});

// Cargar notificaciones
function loadNotifications() {
    fetch('api/notifications.php')
        .then(response => response.json())
        .then(data => {
            const content = document.getElementById('notifications-content');
            const count = document.getElementById('notification-count');
            
            if (data.notifications && data.notifications.length > 0) {
                content.innerHTML = data.notifications.map(notification => `
                    <div class="notification-item notification-item--${notification.type}">
                        <div class="notification-item__content">
                            <h5>${notification.title}</h5>
                            <p>${notification.message}</p>
                            <small>${notification.time}</small>
                        </div>
                    </div>
                `).join('');
                
                count.textContent = data.count;
                count.style.display = data.count > 0 ? 'block' : 'none';
            } else {
                content.innerHTML = '<p class="notification-dropdown__empty">No hay notificaciones nuevas</p>';
                count.style.display = 'none';
            }
        })
        .catch(error => {
            console.error('Error cargando notificaciones:', error);
        });
}

// Limpiar todas las notificaciones
function clearAllNotifications() {
    fetch('api/notifications.php', {
        method: 'DELETE'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('notifications-content').innerHTML = 
                '<p class="notification-dropdown__empty">No hay notificaciones nuevas</p>';
            document.getElementById('notification-count').style.display = 'none';
        }
    })
    .catch(error => {
        console.error('Error limpiando notificaciones:', error);
    });
}

// Verificar nuevas notificaciones cada 2 minutos
setInterval(function() {
    fetch('api/notifications.php?count_only=1')
        .then(response => response.json())
        .then(data => {
            const count = document.getElementById('notification-count');
            if (data.count > 0) {
                count.textContent = data.count;
                count.style.display = 'block';
            } else {
                count.style.display = 'none';
            }
        })
        .catch(error => {
            console.error('Error verificando notificaciones:', error);
        });
}, 120000);
</script>