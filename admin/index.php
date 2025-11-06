<?php
/**
 * Panel de Administración - Dashboard Principal
 * UWEB - Sistema de Gestión de Contactos
 */

define('UWEB_SYSTEM', true);
require_once '../config/database.php';
require_once 'includes/functions.php';

// Verificar autenticación
verificarAutenticacion();

// Obtener estadísticas del dashboard
$stats = obtenerEstadisticasDashboard();
$contactosRecientes = obtenerContactosRecientes(5);
$estadisticasServicios = obtenerEstadisticasServicios();

$pageTitle = 'Dashboard - Panel de Administración';
include 'includes/header.php';
?>

<div class="dashboard-container">
    <!-- Header del Dashboard -->
    <div class="dashboard-header">
        <h1>📊 Dashboard - Sistema de Contactos</h1>
        <p class="dashboard-subtitle">Resumen de actividad y métricas principales</p>
    </div>

    <!-- Tarjetas de Estadísticas Principales -->
    <div class="stats-grid">
        <div class="stat-card stat-card--primary">
            <div class="stat-card__icon">📧</div>
            <div class="stat-card__content">
                <h3 class="stat-card__number"><?php echo $stats['contactos_hoy']; ?></h3>
                <p class="stat-card__label">Contactos Hoy</p>
                <span class="stat-card__change stat-card__change--positive">
                    +<?php echo $stats['contactos_semana']; ?> esta semana
                </span>
            </div>
        </div>

        <div class="stat-card stat-card--success">
            <div class="stat-card__icon">✅</div>
            <div class="stat-card__content">
                <h3 class="stat-card__number"><?php echo $stats['respondidos_hoy']; ?></h3>
                <p class="stat-card__label">Respondidos Hoy</p>
                <span class="stat-card__change">
                    <?php echo $stats['tasa_respuesta_hoy']; ?>% tasa de respuesta
                </span>
            </div>
        </div>

        <div class="stat-card stat-card--warning">
            <div class="stat-card__icon">⏳</div>
            <div class="stat-card__content">
                <h3 class="stat-card__number"><?php echo $stats['pendientes_hoy']; ?></h3>
                <p class="stat-card__label">Pendientes</p>
                <span class="stat-card__change stat-card__change--negative">
                    Requieren atención
                </span>
            </div>
        </div>

        <div class="stat-card stat-card--info">
            <div class="stat-card__icon">⏱️</div>
            <div class="stat-card__content">
                <h3 class="stat-card__number"><?php echo $stats['tiempo_respuesta_promedio']; ?>h</h3>
                <p class="stat-card__label">Tiempo Promedio</p>
                <span class="stat-card__change">
                    Tiempo de respuesta
                </span>
            </div>
        </div>
    </div>

    <!-- Gráfico de Servicios Más Solicitados -->
    <div class="dashboard-section">
        <div class="section-header">
            <h2>🎯 Servicios Más Solicitados (Último Mes)</h2>
            <a href="estadisticas.php" class="btn btn--outline btn--small">Ver Reportes Completos</a>
        </div>
        
        <div class="services-chart">
            <?php foreach ($estadisticasServicios as $servicio): ?>
                <div class="service-bar">
                    <div class="service-bar__info">
                        <span class="service-bar__name"><?php echo obtenerNombreServicio($servicio['tipo_servicio']); ?></span>
                        <span class="service-bar__count"><?php echo $servicio['cantidad']; ?> contactos</span>
                    </div>
                    <div class="service-bar__progress">
                        <div class="service-bar__fill" style="width: <?php echo $servicio['porcentaje']; ?>%"></div>
                    </div>
                    <span class="service-bar__percentage"><?php echo number_format($servicio['porcentaje'], 1); ?>%</span>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Contactos Recientes y Acciones Rápidas -->
    <div class="dashboard-grid">
        <!-- Contactos Recientes -->
        <div class="dashboard-section">
            <div class="section-header">
                <h2>📋 Contactos Recientes</h2>
                <a href="contactos.php" class="btn btn--outline btn--small">Ver Todos</a>
            </div>
            
            <div class="contacts-list">
                <?php if (empty($contactosRecientes)): ?>
                    <div class="empty-state">
                        <p>No hay contactos recientes</p>
                    </div>
                <?php else: ?>
                    <?php foreach ($contactosRecientes as $contacto): ?>
                        <div class="contact-item">
                            <div class="contact-item__avatar">
                                <?php echo strtoupper(substr($contacto['nombre'], 0, 2)); ?>
                            </div>
                            <div class="contact-item__info">
                                <h4 class="contact-item__name"><?php echo htmlspecialchars($contacto['nombre']); ?></h4>
                                <p class="contact-item__email"><?php echo htmlspecialchars($contacto['email']); ?></p>
                                <p class="contact-item__service"><?php echo obtenerNombreServicio($contacto['tipo_servicio']); ?></p>
                                <p class="contact-item__message"><?php echo substr(htmlspecialchars($contacto['mensaje']), 0, 100); ?>...</p>
                            </div>
                            <div class="contact-item__meta">
                                <span class="contact-item__status contact-item__status--<?php echo $contacto['estado']; ?>">
                                    <?php echo ucfirst($contacto['estado']); ?>
                                </span>
                                <span class="contact-item__priority contact-item__priority--<?php echo $contacto['prioridad']; ?>">
                                    <?php echo ucfirst($contacto['prioridad']); ?>
                                </span>
                                <span class="contact-item__date"><?php echo formatearFecha($contacto['fecha_envio']); ?></span>
                                <div class="contact-item__actions">
                                    <a href="ver_contacto.php?id=<?php echo $contacto['id']; ?>" class="btn btn--small btn--primary">Ver</a>
                                    <?php if ($contacto['estado'] === 'nuevo'): ?>
                                        <a href="responder.php?id=<?php echo $contacto['id']; ?>" class="btn btn--small btn--success">Responder</a>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>

        <!-- Acciones Rápidas -->
        <div class="dashboard-section">
            <div class="section-header">
                <h2>⚡ Acciones Rápidas</h2>
            </div>
            
            <div class="quick-actions">
                <a href="contactos.php?estado=nuevo" class="quick-action">
                    <div class="quick-action__icon">📬</div>
                    <div class="quick-action__content">
                        <h4>Contactos Nuevos</h4>
                        <p><?php echo $stats['pendientes_hoy']; ?> sin leer</p>
                    </div>
                </a>

                <a href="contactos.php?prioridad=alta" class="quick-action">
                    <div class="quick-action__icon">🔥</div>
                    <div class="quick-action__content">
                        <h4>Alta Prioridad</h4>
                        <p><?php echo $stats['alta_prioridad']; ?> contactos</p>
                    </div>
                </a>

                <a href="contactos.php?fecha=hoy" class="quick-action">
                    <div class="quick-action__icon">📅</div>
                    <div class="quick-action__content">
                        <h4>Hoy</h4>
                        <p><?php echo $stats['contactos_hoy']; ?> contactos</p>
                    </div>
                </a>

                <a href="estadisticas.php" class="quick-action">
                    <div class="quick-action__icon">📊</div>
                    <div class="quick-action__content">
                        <h4>Reportes</h4>
                        <p>Ver estadísticas</p>
                    </div>
                </a>

                <a href="contactos.php?export=csv" class="quick-action">
                    <div class="quick-action__icon">📤</div>
                    <div class="quick-action__content">
                        <h4>Exportar</h4>
                        <p>Descargar CSV</p>
                    </div>
                </a>

                <a href="../procesar_contacto.php" target="_blank" class="quick-action">
                    <div class="quick-action__icon">🧪</div>
                    <div class="quick-action__content">
                        <h4>Probar Formulario</h4>
                        <p>Test de funcionamiento</p>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <!-- Alertas y Notificaciones -->
    <?php if ($stats['alertas'] > 0): ?>
    <div class="dashboard-section">
        <div class="section-header">
            <h2>⚠️ Alertas del Sistema</h2>
        </div>
        
        <div class="alerts-container">
            <?php if ($stats['contactos_sin_responder_24h'] > 0): ?>
                <div class="alert alert--warning">
                    <div class="alert__icon">⏰</div>
                    <div class="alert__content">
                        <h4>Contactos sin responder</h4>
                        <p><?php echo $stats['contactos_sin_responder_24h']; ?> contactos llevan más de 24 horas sin respuesta.</p>
                        <a href="contactos.php?sin_responder=24h" class="alert__action">Ver contactos</a>
                    </div>
                </div>
            <?php endif; ?>

            <?php if ($stats['contactos_alta_prioridad_pendientes'] > 0): ?>
                <div class="alert alert--danger">
                    <div class="alert__icon">🚨</div>
                    <div class="alert__content">
                        <h4>Alta prioridad pendiente</h4>
                        <p><?php echo $stats['contactos_alta_prioridad_pendientes']; ?> contactos de alta prioridad requieren atención inmediata.</p>
                        <a href="contactos.php?prioridad=alta&estado=nuevo" class="alert__action">Atender ahora</a>
                    </div>
                </div>
            <?php endif; ?>
        </div>
    </div>
    <?php endif; ?>

    <!-- Actividad Reciente del Sistema -->
    <div class="dashboard-section">
        <div class="section-header">
            <h2>📝 Actividad Reciente del Sistema</h2>
            <a href="logs.php" class="btn btn--outline btn--small">Ver Logs Completos</a>
        </div>
        
        <div class="activity-log">
            <?php 
            $actividadReciente = obtenerActividadReciente(10);
            foreach ($actividadReciente as $actividad): 
            ?>
                <div class="activity-item">
                    <div class="activity-item__time"><?php echo formatearFecha($actividad['fecha_hora']); ?></div>
                    <div class="activity-item__content">
                        <span class="activity-item__action"><?php echo htmlspecialchars($actividad['accion']); ?></span>
                        <span class="activity-item__description"><?php echo htmlspecialchars($actividad['descripcion']); ?></span>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
</div>

<script>
// Actualizar estadísticas cada 5 minutos
setInterval(function() {
    fetch('api/stats.php')
        .then(response => response.json())
        .then(data => {
            // Actualizar números en las tarjetas
            document.querySelector('.stat-card--primary .stat-card__number').textContent = data.contactos_hoy;
            document.querySelector('.stat-card--success .stat-card__number').textContent = data.respondidos_hoy;
            document.querySelector('.stat-card--warning .stat-card__number').textContent = data.pendientes_hoy;
        })
        .catch(error => console.log('Error actualizando stats:', error));
}, 300000); // 5 minutos

// Notificaciones en tiempo real (opcional)
function checkNewContacts() {
    fetch('api/check_new.php')
        .then(response => response.json())
        .then(data => {
            if (data.new_contacts > 0) {
                showNotification(`${data.new_contacts} nuevo(s) contacto(s) recibido(s)`, 'info');
            }
        });
}

// Verificar nuevos contactos cada 2 minutos
setInterval(checkNewContacts, 120000);

// Función para mostrar notificaciones
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification--${type}`;
    notification.innerHTML = `
        <div class="notification__content">${message}</div>
        <button class="notification__close" onclick="this.parentElement.remove()">×</button>
    `;
    
    document.body.appendChild(notification);
    
    // Auto-remover después de 5 segundos
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}
</script>

<?php include 'includes/footer.php'; ?>