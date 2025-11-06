<?php
/**
 * Configuración de Base de Datos - UWEB
 * 
 * Este archivo contiene la configuración para la conexión a MySQL
 * y otras configuraciones del sistema de contacto.
 */

// Prevenir acceso directo
if (!defined('UWEB_SYSTEM')) {
    die('Acceso directo no permitido');
}

// Configuración de Base de Datos
define('DB_HOST', 'localhost');
define('DB_NAME', 'uweb_contactos');
define('DB_USER', 'uweb_user');
define('DB_PASS', 'uweb_2024_secure!');
define('DB_CHARSET', 'utf8mb4');

// Configuración de Email SMTP
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_SECURE', 'tls');
define('SMTP_USER', 'info@uweb.com');
define('SMTP_PASS', 'your_app_password_here');
define('ADMIN_EMAIL', 'admin@uweb.com');
define('FROM_EMAIL', 'info@uweb.com');
define('FROM_NAME', 'UWEB - Desarrollo Web');

// Configuración del Sistema
define('SITE_URL', 'https://uweb.com');
define('ADMIN_URL', SITE_URL . '/admin');
define('TIMEZONE', 'America/Lima');
define('DATE_FORMAT', 'Y-m-d H:i:s');

// Configuración de Seguridad
define('ADMIN_SESSION_TIMEOUT', 3600); // 1 hora
define('MAX_LOGIN_ATTEMPTS', 5);
define('LOGIN_LOCKOUT_TIME', 900); // 15 minutos
define('CSRF_TOKEN_EXPIRE', 1800); // 30 minutos

// Configuración de Archivos
define('UPLOAD_MAX_SIZE', 5 * 1024 * 1024); // 5MB
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx']);

// Configuración de Logs
define('LOG_ERRORS', true);
define('LOG_FILE', __DIR__ . '/../logs/system.log');
define('LOG_MAX_SIZE', 10 * 1024 * 1024); // 10MB

/**
 * Clase para manejo de conexión a base de datos
 */
class Database {
    private static $instance = null;
    private $connection;
    
    private function __construct() {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES " . DB_CHARSET
            ];
            
            $this->connection = new PDO($dsn, DB_USER, DB_PASS, $options);
            
        } catch (PDOException $e) {
            error_log("Error de conexión a base de datos: " . $e->getMessage());
            die("Error de conexión a la base de datos");
        }
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function getConnection() {
        return $this->connection;
    }
    
    /**
     * Ejecutar consulta preparada
     */
    public function query($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            return $stmt;
        } catch (PDOException $e) {
            error_log("Error en consulta SQL: " . $e->getMessage());
            throw new Exception("Error en la consulta a la base de datos");
        }
    }
    
    /**
     * Insertar registro y retornar ID
     */
    public function insert($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $this->connection->lastInsertId();
    }
    
    /**
     * Obtener un solo registro
     */
    public function fetchOne($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetch();
    }
    
    /**
     * Obtener múltiples registros
     */
    public function fetchAll($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchAll();
    }
    
    /**
     * Contar registros
     */
    public function count($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchColumn();
    }
}

/**
 * Funciones auxiliares para configuración
 */

/**
 * Obtener configuración de zona horaria
 */
function setTimezone() {
    date_default_timezone_set(TIMEZONE);
}

/**
 * Verificar si estamos en modo desarrollo
 */
function isDevelopment() {
    return (defined('ENVIRONMENT') && ENVIRONMENT === 'development');
}

/**
 * Obtener URL base del sitio
 */
function getSiteUrl() {
    return SITE_URL;
}

/**
 * Generar token CSRF
 */
function generateCSRFToken() {
    if (!isset($_SESSION['csrf_token']) || 
        !isset($_SESSION['csrf_token_time']) || 
        (time() - $_SESSION['csrf_token_time']) > CSRF_TOKEN_EXPIRE) {
        
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        $_SESSION['csrf_token_time'] = time();
    }
    
    return $_SESSION['csrf_token'];
}

/**
 * Verificar token CSRF
 */
function verifyCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && 
           hash_equals($_SESSION['csrf_token'], $token) &&
           isset($_SESSION['csrf_token_time']) &&
           (time() - $_SESSION['csrf_token_time']) <= CSRF_TOKEN_EXPIRE;
}

/**
 * Registrar evento en log
 */
function logEvent($message, $level = 'INFO') {
    if (!LOG_ERRORS) return;
    
    $timestamp = date(DATE_FORMAT);
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
    
    $logMessage = "[{$timestamp}] [{$level}] [{$ip}] {$message} | User-Agent: {$userAgent}" . PHP_EOL;
    
    // Crear directorio de logs si no existe
    $logDir = dirname(LOG_FILE);
    if (!is_dir($logDir)) {
        mkdir($logDir, 0755, true);
    }
    
    // Rotar log si es muy grande
    if (file_exists(LOG_FILE) && filesize(LOG_FILE) > LOG_MAX_SIZE) {
        rename(LOG_FILE, LOG_FILE . '.' . date('Y-m-d-H-i-s'));
    }
    
    file_put_contents(LOG_FILE, $logMessage, FILE_APPEND | LOCK_EX);
}

/**
 * Sanitizar entrada de usuario
 */
function sanitizeInput($input) {
    if (is_array($input)) {
        return array_map('sanitizeInput', $input);
    }
    
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

/**
 * Validar email
 */
function isValidEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * Validar teléfono
 */
function isValidPhone($phone) {
    // Permitir formatos internacionales y peruanos
    $pattern = '/^(\+51\s?)?[9][0-9]{8}$|^[\+]?[0-9\s\-\(\)]{9,15}$/';
    return preg_match($pattern, preg_replace('/\s/', '', $phone));
}

/**
 * Generar respuesta JSON
 */
function jsonResponse($data, $httpCode = 200) {
    http_response_code($httpCode);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Obtener IP del cliente
 */
function getClientIP() {
    $ipKeys = ['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'HTTP_CLIENT_IP', 'REMOTE_ADDR'];
    
    foreach ($ipKeys as $key) {
        if (!empty($_SERVER[$key])) {
            $ips = explode(',', $_SERVER[$key]);
            $ip = trim($ips[0]);
            
            if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                return $ip;
            }
        }
    }
    
    return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
}

// Inicializar configuración
setTimezone();

// Iniciar sesión si no está iniciada
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
?>