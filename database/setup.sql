-- =====================================================
-- Script de Instalación de Base de Datos - UWEB
-- =====================================================
-- 
-- Este script crea la base de datos y las tablas necesarias
-- para el sistema de contacto de UWEB
--
-- Ejecutar como administrador de MySQL
-- =====================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS uweb_contactos 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE uweb_contactos;

-- =====================================================
-- TABLA: contactos
-- Almacena todos los mensajes de contacto recibidos
-- =====================================================

CREATE TABLE contactos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL COMMENT 'Nombre completo del contacto',
    email VARCHAR(150) NOT NULL COMMENT 'Email del contacto',
    telefono VARCHAR(20) NULL COMMENT 'Teléfono del contacto (opcional)',
    tipo_servicio ENUM(
        'estudio', 
        'diseno', 
        'construccion', 
        'despliegue', 
        'completo', 
        'other'
    ) NOT NULL COMMENT 'Tipo de servicio solicitado',
    mensaje TEXT NOT NULL COMMENT 'Mensaje del contacto',
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de envío',
    ip_cliente VARCHAR(45) NULL COMMENT 'IP del cliente (IPv4 o IPv6)',
    user_agent TEXT NULL COMMENT 'User Agent del navegador',
    estado ENUM(
        'nuevo', 
        'leido', 
        'respondido', 
        'archivado'
    ) DEFAULT 'nuevo' COMMENT 'Estado del contacto',
    notas_admin TEXT NULL COMMENT 'Notas internas del administrador',
    fecha_respuesta TIMESTAMP NULL COMMENT 'Fecha de respuesta al contacto',
    respondido_por VARCHAR(50) NULL COMMENT 'Usuario que respondió',
    prioridad ENUM(
        'baja', 
        'media', 
        'alta', 
        'urgente'
    ) DEFAULT 'media' COMMENT 'Prioridad del contacto',
    origen VARCHAR(50) DEFAULT 'web' COMMENT 'Origen del contacto',
    
    -- Índices para optimizar consultas
    INDEX idx_fecha_envio (fecha_envio),
    INDEX idx_estado (estado),
    INDEX idx_email (email),
    INDEX idx_tipo_servicio (tipo_servicio),
    INDEX idx_prioridad (prioridad),
    INDEX idx_fecha_respuesta (fecha_respuesta)
) ENGINE=InnoDB COMMENT='Tabla principal de contactos recibidos';

-- =====================================================
-- TABLA: admin_users
-- Usuarios administradores del sistema
-- =====================================================

CREATE TABLE admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT 'Nombre de usuario',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hash de la contraseña',
    email VARCHAR(150) NOT NULL UNIQUE COMMENT 'Email del administrador',
    nombre_completo VARCHAR(100) NOT NULL COMMENT 'Nombre completo',
    rol ENUM('admin', 'moderador', 'viewer') DEFAULT 'viewer' COMMENT 'Rol del usuario',
    activo BOOLEAN DEFAULT TRUE COMMENT 'Usuario activo',
    ultimo_acceso TIMESTAMP NULL COMMENT 'Último acceso al sistema',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación',
    intentos_login INT DEFAULT 0 COMMENT 'Intentos de login fallidos',
    bloqueado_hasta TIMESTAMP NULL COMMENT 'Bloqueado hasta esta fecha',
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_ultimo_acceso (ultimo_acceso)
) ENGINE=InnoDB COMMENT='Usuarios administradores del sistema';

-- =====================================================
-- TABLA: configuracion
-- Configuraciones del sistema
-- =====================================================

CREATE TABLE configuracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(100) NOT NULL UNIQUE COMMENT 'Clave de configuración',
    valor TEXT NULL COMMENT 'Valor de configuración',
    descripcion TEXT NULL COMMENT 'Descripción de la configuración',
    tipo ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string' COMMENT 'Tipo de dato',
    categoria VARCHAR(50) DEFAULT 'general' COMMENT 'Categoría de configuración',
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_clave (clave),
    INDEX idx_categoria (categoria)
) ENGINE=InnoDB COMMENT='Configuraciones del sistema';

-- =====================================================
-- TABLA: logs_actividad
-- Registro de actividades del sistema
-- =====================================================

CREATE TABLE logs_actividad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NULL COMMENT 'ID del usuario (si aplica)',
    accion VARCHAR(100) NOT NULL COMMENT 'Acción realizada',
    descripcion TEXT NULL COMMENT 'Descripción detallada',
    ip_cliente VARCHAR(45) NULL COMMENT 'IP del cliente',
    user_agent TEXT NULL COMMENT 'User Agent',
    datos_adicionales JSON NULL COMMENT 'Datos adicionales en formato JSON',
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la acción',
    
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_accion (accion),
    INDEX idx_fecha_hora (fecha_hora),
    
    FOREIGN KEY (usuario_id) REFERENCES admin_users(id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Registro de actividades del sistema';

-- =====================================================
-- TABLA: estadisticas_diarias
-- Estadísticas agregadas por día
-- =====================================================

CREATE TABLE estadisticas_diarias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE COMMENT 'Fecha de las estadísticas',
    total_contactos INT DEFAULT 0 COMMENT 'Total de contactos recibidos',
    contactos_respondidos INT DEFAULT 0 COMMENT 'Contactos respondidos',
    tiempo_respuesta_promedio INT DEFAULT 0 COMMENT 'Tiempo promedio de respuesta en minutos',
    servicios_solicitados JSON NULL COMMENT 'Distribución de servicios solicitados',
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_fecha (fecha)
) ENGINE=InnoDB COMMENT='Estadísticas diarias del sistema';

-- =====================================================
-- INSERTAR DATOS INICIALES
-- =====================================================

-- Insertar usuario administrador por defecto
-- Contraseña: admin123 (cambiar inmediatamente)
INSERT INTO admin_users (username, password_hash, email, nombre_completo, rol) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@uweb.com', 'Administrador UWEB', 'admin');

-- Insertar configuraciones iniciales
INSERT INTO configuracion (clave, valor, descripcion, tipo, categoria) VALUES 
('site_name', 'UWEB', 'Nombre del sitio web', 'string', 'general'),
('admin_email', 'admin@uweb.com', 'Email del administrador principal', 'string', 'email'),
('smtp_enabled', '1', 'Habilitar envío de emails', 'boolean', 'email'),
('auto_response_enabled', '1', 'Habilitar respuesta automática', 'boolean', 'email'),
('max_contacts_per_hour', '10', 'Máximo de contactos por hora desde la misma IP', 'number', 'seguridad'),
('backup_enabled', '1', 'Habilitar backups automáticos', 'boolean', 'sistema'),
('log_retention_days', '90', 'Días de retención de logs', 'number', 'sistema');

-- =====================================================
-- CREAR USUARIO DE BASE DE DATOS
-- =====================================================

-- Crear usuario específico para la aplicación
CREATE USER IF NOT EXISTS 'uweb_user'@'localhost' IDENTIFIED BY 'uweb_2024_secure!';

-- Otorgar permisos necesarios
GRANT SELECT, INSERT, UPDATE ON uweb_contactos.contactos TO 'uweb_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON uweb_contactos.admin_users TO 'uweb_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON uweb_contactos.configuracion TO 'uweb_user'@'localhost';
GRANT SELECT, INSERT ON uweb_contactos.logs_actividad TO 'uweb_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON uweb_contactos.estadisticas_diarias TO 'uweb_user'@'localhost';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Vista de contactos con información resumida
CREATE VIEW vista_contactos_resumen AS
SELECT 
    c.id,
    c.nombre,
    c.email,
    c.tipo_servicio,
    c.estado,
    c.prioridad,
    c.fecha_envio,
    c.fecha_respuesta,
    CASE 
        WHEN c.fecha_respuesta IS NOT NULL THEN 
            TIMESTAMPDIFF(MINUTE, c.fecha_envio, c.fecha_respuesta)
        ELSE NULL 
    END as tiempo_respuesta_minutos,
    LEFT(c.mensaje, 100) as mensaje_preview
FROM contactos c
ORDER BY c.fecha_envio DESC;

-- Vista de estadísticas mensuales
CREATE VIEW vista_estadisticas_mensuales AS
SELECT 
    YEAR(fecha_envio) as año,
    MONTH(fecha_envio) as mes,
    COUNT(*) as total_contactos,
    COUNT(CASE WHEN estado = 'respondido' THEN 1 END) as respondidos,
    ROUND(COUNT(CASE WHEN estado = 'respondido' THEN 1 END) * 100.0 / COUNT(*), 2) as tasa_respuesta,
    AVG(CASE 
        WHEN fecha_respuesta IS NOT NULL THEN 
            TIMESTAMPDIFF(MINUTE, fecha_envio, fecha_respuesta)
        ELSE NULL 
    END) as tiempo_respuesta_promedio
FROM contactos 
GROUP BY YEAR(fecha_envio), MONTH(fecha_envio)
ORDER BY año DESC, mes DESC;

-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =====================================================

DELIMITER //

-- Procedimiento para obtener estadísticas del dashboard
CREATE PROCEDURE GetDashboardStats()
BEGIN
    -- Estadísticas de hoy
    SELECT 
        COUNT(*) as contactos_hoy,
        COUNT(CASE WHEN estado = 'respondido' THEN 1 END) as respondidos_hoy,
        COUNT(CASE WHEN estado = 'nuevo' THEN 1 END) as pendientes_hoy
    FROM contactos 
    WHERE DATE(fecha_envio) = CURDATE();
    
    -- Estadísticas de la semana
    SELECT 
        COUNT(*) as contactos_semana,
        COUNT(CASE WHEN estado = 'respondido' THEN 1 END) as respondidos_semana
    FROM contactos 
    WHERE fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
    
    -- Servicios más solicitados
    SELECT 
        tipo_servicio,
        COUNT(*) as cantidad,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM contactos WHERE fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)), 2) as porcentaje
    FROM contactos 
    WHERE fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY tipo_servicio
    ORDER BY cantidad DESC;
END //

-- Procedimiento para limpiar datos antiguos
CREATE PROCEDURE LimpiarDatosAntiguos()
BEGIN
    -- Archivar contactos antiguos (más de 1 año)
    UPDATE contactos 
    SET estado = 'archivado' 
    WHERE fecha_envio < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) 
    AND estado != 'archivado';
    
    -- Eliminar logs antiguos (más de 90 días)
    DELETE FROM logs_actividad 
    WHERE fecha_hora < DATE_SUB(CURDATE(), INTERVAL 90 DAY);
    
    -- Eliminar estadísticas diarias antiguas (más de 2 años)
    DELETE FROM estadisticas_diarias 
    WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger para registrar cambios de estado
CREATE TRIGGER contactos_estado_change 
AFTER UPDATE ON contactos
FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado THEN
        INSERT INTO logs_actividad (accion, descripcion, datos_adicionales)
        VALUES (
            'cambio_estado_contacto',
            CONCAT('Estado cambiado de ', OLD.estado, ' a ', NEW.estado, ' para contacto ID: ', NEW.id),
            JSON_OBJECT('contacto_id', NEW.id, 'estado_anterior', OLD.estado, 'estado_nuevo', NEW.estado)
        );
    END IF;
END //

DELIMITER ;

-- =====================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================

-- Índice compuesto para consultas frecuentes
CREATE INDEX idx_estado_fecha ON contactos(estado, fecha_envio);
CREATE INDEX idx_tipo_fecha ON contactos(tipo_servicio, fecha_envio);

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

/*
INSTRUCCIONES POST-INSTALACIÓN:

1. Cambiar la contraseña del usuario 'admin' inmediatamente
2. Configurar las variables de entorno en el archivo .env
3. Verificar que el usuario 'uweb_user' tenga los permisos correctos
4. Configurar backups automáticos de la base de datos
5. Configurar rotación de logs
6. Probar la conexión desde la aplicación PHP

COMANDOS ÚTILES:

-- Ver estadísticas rápidas
CALL GetDashboardStats();

-- Limpiar datos antiguos
CALL LimpiarDatosAntiguos();

-- Ver contactos recientes
SELECT * FROM vista_contactos_resumen LIMIT 10;

-- Ver estadísticas mensuales
SELECT * FROM vista_estadisticas_mensuales LIMIT 12;
*/