<?php
/**
 * Procesador de Formulario de Contacto - UWEB
 * 
 * Este archivo procesa los datos del formulario de contacto,
 * los valida, los guarda en la base de datos y envía notificaciones.
 */

// Definir constante del sistema
define('UWEB_SYSTEM', true);

// Incluir configuración
require_once 'config/database.php';

// Configurar headers para CORS y JSON
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');

// Manejar preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Solo permitir método POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse([
        'success' => false,
        'message' => 'Método no permitido. Solo se acepta POST.'
    ], 405);
}

try {
    // Verificar rate limiting (máximo 5 envíos por hora por IP)
    checkRateLimit();
    
    // Obtener y validar datos del formulario
    $datos = obtenerDatosFormulario();
    
    // Validar datos
    $errores = validarDatos($datos);
    if (!empty($errores)) {
        jsonResponse([
            'success' => false,
            'message' => 'Datos inválidos',
            'errors' => $errores
        ], 400);
    }
    
    // Guardar en base de datos
    $contactoId = guardarContacto($datos);
    
    // Enviar notificaciones por email
    $emailEnviado = enviarNotificaciones($datos, $contactoId);
    
    // Registrar actividad
    logEvent("Nuevo contacto recibido - ID: {$contactoId} - Email: {$datos['email']}", 'INFO');
    
    // Respuesta exitosa
    jsonResponse([
        'success' => true,
        'message' => '¡Gracias por contactarnos! Hemos recibido tu mensaje y te responderemos pronto.',
        'contacto_id' => $contactoId,
        'email_enviado' => $emailEnviado
    ]);
    
} catch (Exception $e) {
    // Log del error
    logEvent("Error procesando contacto: " . $e->getMessage(), 'ERROR');
    
    // Respuesta de error
    jsonResponse([
        'success' => false,
        'message' => 'Ocurrió un error al procesar tu mensaje. Por favor, intenta nuevamente.'
    ], 500);
}

/**
 * Verificar rate limiting por IP
 */
function checkRateLimit() {
    $ip = getClientIP();
    $db = Database::getInstance();
    
    // Contar contactos de la última hora desde esta IP
    $sql = "SELECT COUNT(*) FROM contactos 
            WHERE ip_cliente = ? 
            AND fecha_envio > DATE_SUB(NOW(), INTERVAL 1 HOUR)";
    
    $count = $db->count($sql, [$ip]);
    
    if ($count >= 5) {
        logEvent("Rate limit excedido para IP: {$ip}", 'WARNING');
        jsonResponse([
            'success' => false,
            'message' => 'Has enviado demasiados mensajes. Por favor, espera una hora antes de enviar otro.'
        ], 429);
    }
}

/**
 * Obtener y sanitizar datos del formulario
 */
function obtenerDatosFormulario() {
    $datos = [];
    
    // Campos requeridos
    $camposRequeridos = ['name', 'email', 'serviceType', 'message'];
    
    foreach ($camposRequeridos as $campo) {
        if (!isset($_POST[$campo]) || empty(trim($_POST[$campo]))) {
            throw new Exception("Campo requerido faltante: {$campo}");
        }
        
        $datos[$campo] = sanitizeInput($_POST[$campo]);
    }
    
    // Campos opcionales
    $datos['phone'] = isset($_POST['phone']) ? sanitizeInput($_POST['phone']) : '';
    
    // Datos adicionales del sistema
    $datos['ip_cliente'] = getClientIP();
    $datos['user_agent'] = $_SERVER['HTTP_USER_AGENT'] ?? '';
    $datos['origen'] = 'web';
    
    return $datos;
}

/**
 * Validar datos del formulario
 */
function validarDatos($datos) {
    $errores = [];
    
    // Validar nombre
    if (strlen($datos['name']) < 2) {
        $errores['name'] = 'El nombre debe tener al menos 2 caracteres';
    }
    if (strlen($datos['name']) > 100) {
        $errores['name'] = 'El nombre no puede tener más de 100 caracteres';
    }
    
    // Validar email
    if (!isValidEmail($datos['email'])) {
        $errores['email'] = 'Por favor, ingresa un email válido';
    }
    if (strlen($datos['email']) > 150) {
        $errores['email'] = 'El email es demasiado largo';
    }
    
    // Validar teléfono (opcional)
    if (!empty($datos['phone']) && !isValidPhone($datos['phone'])) {
        $errores['phone'] = 'Por favor, ingresa un teléfono válido';
    }
    
    // Validar tipo de servicio
    $tiposValidos = ['estudio', 'diseno', 'construccion', 'despliegue', 'completo', 'other'];
    if (!in_array($datos['serviceType'], $tiposValidos)) {
        $errores['serviceType'] = 'Tipo de servicio inválido';
    }
    
    // Validar mensaje
    if (strlen($datos['message']) < 10) {
        $errores['message'] = 'El mensaje debe tener al menos 10 caracteres';
    }
    if (strlen($datos['message']) > 5000) {
        $errores['message'] = 'El mensaje es demasiado largo';
    }
    
    // Verificar si el email ya envió un mensaje reciente (últimas 24 horas)
    $db = Database::getInstance();
    $sql = "SELECT COUNT(*) FROM contactos 
            WHERE email = ? 
            AND fecha_envio > DATE_SUB(NOW(), INTERVAL 24 HOUR)";
    
    $count = $db->count($sql, [$datos['email']]);
    if ($count > 0) {
        $errores['email'] = 'Ya has enviado un mensaje recientemente. Por favor, espera 24 horas.';
    }
    
    return $errores;
}

/**
 * Guardar contacto en base de datos
 */
function guardarContacto($datos) {
    $db = Database::getInstance();
    
    $sql = "INSERT INTO contactos (
                nombre, email, telefono, tipo_servicio, mensaje, 
                ip_cliente, user_agent, origen, prioridad
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    // Determinar prioridad basada en tipo de servicio
    $prioridad = determinarPrioridad($datos['serviceType']);
    
    $params = [
        $datos['name'],
        $datos['email'],
        $datos['phone'] ?: null,
        $datos['serviceType'],
        $datos['message'],
        $datos['ip_cliente'],
        $datos['user_agent'],
        $datos['origen'],
        $prioridad
    ];
    
    return $db->insert($sql, $params);
}

/**
 * Determinar prioridad basada en tipo de servicio
 */
function determinarPrioridad($tipoServicio) {
    $prioridades = [
        'completo' => 'alta',      // Proyecto completo = alta prioridad
        'construccion' => 'alta',   // Desarrollo = alta prioridad
        'estudio' => 'media',       // Análisis = media prioridad
        'diseno' => 'media',        // Diseño = media prioridad
        'despliegue' => 'media',    // Despliegue = media prioridad
        'other' => 'baja'           // Otros = baja prioridad
    ];
    
    return $prioridades[$tipoServicio] ?? 'media';
}

/**
 * Enviar notificaciones por email
 */
function enviarNotificaciones($datos, $contactoId) {
    try {
        // Enviar email al administrador
        $emailAdmin = enviarEmailAdmin($datos, $contactoId);
        
        // Enviar email de confirmación al cliente
        $emailCliente = enviarEmailConfirmacion($datos, $contactoId);
        
        return $emailAdmin && $emailCliente;
        
    } catch (Exception $e) {
        logEvent("Error enviando emails: " . $e->getMessage(), 'ERROR');
        return false;
    }
}

/**
 * Enviar email de notificación al administrador
 */
function enviarEmailAdmin($datos, $contactoId) {
    $asunto = "Nuevo contacto en UWEB - {$datos['serviceType']} - ID: {$contactoId}";
    
    $tiposServicio = [
        'estudio' => 'Estudio - Análisis y estrategia',
        'diseno' => 'Diseño - UI/UX y prototipado',
        'construccion' => 'Construcción - Desarrollo web',
        'despliegue' => 'Despliegue - Lanzamiento y hosting',
        'completo' => 'Proyecto completo (4 etapas)',
        'other' => 'Otro'
    ];
    
    $tipoServicioTexto = $tiposServicio[$datos['serviceType']] ?? $datos['serviceType'];
    
    $mensaje = "
    <html>
    <head>
        <meta charset='UTF-8'>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .header { background: #667eea; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .info-box { background: #f8f9fa; border-left: 4px solid #667eea; padding: 15px; margin: 15px 0; }
            .footer { background: #f1f1f1; padding: 15px; text-align: center; font-size: 12px; }
            .priority-alta { border-left-color: #dc3545; }
            .priority-media { border-left-color: #ffc107; }
            .priority-baja { border-left-color: #28a745; }
        </style>
    </head>
    <body>
        <div class='header'>
            <h1>🚀 Nuevo Contacto - UWEB</h1>
            <p>ID del Contacto: #{$contactoId}</p>
        </div>
        
        <div class='content'>
            <div class='info-box priority-" . determinarPrioridad($datos['serviceType']) . "'>
                <h3>📋 Información del Contacto</h3>
                <p><strong>Nombre:</strong> {$datos['name']}</p>
                <p><strong>Email:</strong> <a href='mailto:{$datos['email']}'>{$datos['email']}</a></p>
                <p><strong>Teléfono:</strong> " . ($datos['phone'] ?: 'No proporcionado') . "</p>
                <p><strong>Servicio:</strong> {$tipoServicioTexto}</p>
                <p><strong>Prioridad:</strong> " . strtoupper(determinarPrioridad($datos['serviceType'])) . "</p>
            </div>
            
            <div class='info-box'>
                <h3>💬 Mensaje</h3>
                <p>" . nl2br(htmlspecialchars($datos['message'])) . "</p>
            </div>
            
            <div class='info-box'>
                <h3>🔍 Información Técnica</h3>
                <p><strong>IP:</strong> {$datos['ip_cliente']}</p>
                <p><strong>Fecha:</strong> " . date('d/m/Y H:i:s') . "</p>
                <p><strong>Navegador:</strong> " . substr($datos['user_agent'], 0, 100) . "...</p>
            </div>
            
            <div style='text-align: center; margin: 30px 0;'>
                <a href='" . ADMIN_URL . "/ver_contacto.php?id={$contactoId}' 
                   style='background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;'>
                   👁️ Ver en Panel Admin
                </a>
            </div>
        </div>
        
        <div class='footer'>
            <p>Este email fue generado automáticamente por el sistema de contacto de UWEB</p>
            <p>Panel de administración: <a href='" . ADMIN_URL . "'>" . ADMIN_URL . "</a></p>
        </div>
    </body>
    </html>";
    
    return enviarEmail(ADMIN_EMAIL, $asunto, $mensaje);
}

/**
 * Enviar email de confirmación al cliente
 */
function enviarEmailConfirmacion($datos, $contactoId) {
    $asunto = "Confirmación de contacto - UWEB";
    
    $mensaje = "
    <html>
    <head>
        <meta charset='UTF-8'>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .header { background: #667eea; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .info-box { background: #f8f9fa; border-left: 4px solid #667eea; padding: 15px; margin: 15px 0; }
            .footer { background: #f1f1f1; padding: 15px; text-align: center; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class='header'>
            <h1>¡Gracias por contactarnos!</h1>
            <p>UWEB - Desarrollo Web Profesional</p>
        </div>
        
        <div class='content'>
            <p>Hola <strong>{$datos['name']}</strong>,</p>
            
            <p>Hemos recibido tu mensaje y queremos agradecerte por contactarnos. Nuestro equipo revisará tu consulta y te responderemos a la brevedad.</p>
            
            <div class='info-box'>
                <h3>📋 Resumen de tu consulta</h3>
                <p><strong>Número de referencia:</strong> #{$contactoId}</p>
                <p><strong>Servicio de interés:</strong> " . obtenerNombreServicio($datos['serviceType']) . "</p>
                <p><strong>Fecha de envío:</strong> " . date('d/m/Y H:i:s') . "</p>
            </div>
            
            <div class='info-box'>
                <h3>⏰ ¿Cuándo recibirás respuesta?</h3>
                <p>Nuestro tiempo de respuesta típico es:</p>
                <ul>
                    <li><strong>Consultas generales:</strong> 24-48 horas</li>
                    <li><strong>Cotizaciones:</strong> 2-3 días hábiles</li>
                    <li><strong>Proyectos urgentes:</strong> Mismo día</li>
                </ul>
            </div>
            
            <div class='info-box'>
                <h3>📞 ¿Necesitas respuesta inmediata?</h3>
                <p>Si tu consulta es urgente, puedes contactarnos directamente:</p>
                <p><strong>WhatsApp:</strong> +51 987 654 321</p>
                <p><strong>Email:</strong> info@uweb.com</p>
                <p><strong>Horario:</strong> Lunes a Viernes, 9:00 - 18:00 (PET)</p>
            </div>
            
            <div style='text-align: center; margin: 30px 0;'>
                <a href='" . SITE_URL . "' 
                   style='background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;'>
                   🌐 Visitar nuestro sitio web
                </a>
            </div>
        </div>
        
        <div class='footer'>
            <p><strong>UWEB - Desarrollo Web Profesional</strong></p>
            <p>Barranca, Lima, Perú | info@uweb.com | +51 987 654 321</p>
            <p>Este es un email automático, por favor no respondas a esta dirección.</p>
        </div>
    </body>
    </html>";
    
    return enviarEmail($datos['email'], $asunto, $mensaje);
}

/**
 * Obtener nombre legible del servicio
 */
function obtenerNombreServicio($tipo) {
    $nombres = [
        'estudio' => 'Estudio - Análisis y estrategia',
        'diseno' => 'Diseño - UI/UX y prototipado',
        'construccion' => 'Construcción - Desarrollo web',
        'despliegue' => 'Despliegue - Lanzamiento y hosting',
        'completo' => 'Proyecto completo (4 etapas)',
        'other' => 'Consulta general'
    ];
    
    return $nombres[$tipo] ?? $tipo;
}

/**
 * Función para enviar email (usando mail() de PHP)
 * En producción, reemplazar con PHPMailer o similar
 */
function enviarEmail($destinatario, $asunto, $mensaje) {
    $headers = [
        'MIME-Version: 1.0',
        'Content-type: text/html; charset=UTF-8',
        'From: ' . FROM_NAME . ' <' . FROM_EMAIL . '>',
        'Reply-To: ' . FROM_EMAIL,
        'X-Mailer: PHP/' . phpversion()
    ];
    
    return mail($destinatario, $asunto, $mensaje, implode("\r\n", $headers));
}
?>