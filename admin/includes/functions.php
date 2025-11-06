<?php
/**
 * Funciones Auxiliares - Panel de Administración UWEB
 * 
 * Este archivo contiene todas las funciones auxiliares utilizadas
 * en el panel de administración del sistema de contactos.
 */

if (!defined('UWEB_SYSTEM')) {
    die('Acceso directo no permitido');
}

/**
 * Verificar si el usuario está autenticado
 */
function verificarAutenticacion() {
    if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
        header('Location: login.php');
        exit;
    }
    
    // Verificar timeout de sesión
    if (isset($_SESSION['last_activity']) && 
        (time() - $_SESSION['last_activity']) > ADMIN_SESSION_TIMEOUT) {
        session_destroy();
        header('Location: login.php?timeout=1');
        exit;
    }
    
    $_SESSION['last_activity'] = time();
}

/**
 * Obtener estadísticas principales del dashboard
 */
function obtenerEstadisticasDashboard() {
    $db = Database::getInstance();
    
    // Estadísticas de hoy
    $sql = "SELECT 
                COUNT(*) as contactos_hoy,
                COUNT(CASE WHEN estado = 'respondido' THEN 1 END) as respondidos_hoy,
                COUNT(CASE WHEN estado = 'nuevo' THEN 1 END) as pendientes_hoy,
                COUNT(CASE WHEN prioridad = 'alta' AND estado != 'respondido' THEN 1 END) as alta_prioridad
            FROM contactos 
            WHERE DATE(fecha_envio) = CURDATE()";
    
    $statsHoy = $db->fetchOne($sql);
    
    // Estadísticas de la semana
    $sql = "SELECT COUNT(*) as contactos_semana
            FROM contactos 
            WHERE fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
    
    $statsSemana = $db->fetchOne($sql);
    
    // Tiempo promedio de respuesta (en horas)
    $sql = "SELECT AVG(TIMESTAMPDIFF(HOUR, fecha_envio, fecha_respuesta)) as tiempo_promedio
            FROM contactos 
            WHERE fecha_respuesta IS NOT NULL 
            AND fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)";
    
    $tiempoPromedio = $db->fetchOne($sql);
    
    // Contactos sin responder en 24h
    $sql = "SELECT COUNT(*) as sin_responder_24h
            FROM contactos 
            WHERE estado = 'nuevo' 
            AND fecha_envio < DATE_SUB(NOW(), INTERVAL 24 HOUR)";
    
    $sinResponder = $db->fetchOne($sql);
    
    // Contactos de alta prioridad pendientes
    $sql = "SELECT COUNT(*) as alta_prioridad_pendientes
            FROM contactos 
            WHERE prioridad = 'alta' 
            AND estado IN ('nuevo', 'leido')";
    
    $altaPrioridadPendientes = $db->fetchOne($sql);
    
    return [
        'contactos_hoy' => $statsHoy['contactos_hoy'] ?? 0,
        'respondidos_hoy' => $statsHoy['respondidos_hoy'] ?? 0,
        'pendientes_hoy' => $statsHoy['pendientes_hoy'] ?? 0,
        'alta_prioridad' => $statsHoy['alta_prioridad'] ?? 0,
        'contactos_semana' => $statsSemana['contactos_semana'] ?? 0,
        'tiempo_respuesta_promedio' => round($tiempoPromedio['tiempo_promedio'] ?? 0, 1),
        'tasa_respuesta_hoy' => $statsHoy['contactos_hoy'] > 0 ? 
            round(($statsHoy['respondidos_hoy'] / $statsHoy['contactos_hoy']) * 100, 1) : 0,
        'contactos_sin_responder_24h' => $sinResponder['sin_responder_24h'] ?? 0,
        'contactos_alta_prioridad_pendientes' => $altaPrioridadPendientes['alta_prioridad_pendientes'] ?? 0,
        'alertas' => ($sinResponder['sin_responder_24h'] ?? 0) + ($altaPrioridadPendientes['alta_prioridad_pendientes'] ?? 0)
    ];
}

/**
 * Obtener contactos recientes
 */
function obtenerContactosRecientes($limite = 5) {
    $db = Database::getInstance();
    
    $sql = "SELECT id, nombre, email, tipo_servicio, mensaje, estado, prioridad, fecha_envio
            FROM contactos 
            ORDER BY fecha_envio DESC 
            LIMIT ?";
    
    return $db->fetchAll($sql, [$limite]);
}

/**
 * Obtener estadísticas de servicios más solicitados
 */
function obtenerEstadisticasServicios() {
    $db = Database::getInstance();
    
    $sql = "SELECT 
                tipo_servicio,
                COUNT(*) as cantidad,
                ROUND(COUNT(*) * 100.0 / (
                    SELECT COUNT(*) FROM contactos 
                    WHERE fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                ), 2) as porcentaje
            FROM contactos 
            WHERE fecha_envio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            GROUP BY tipo_servicio
            ORDER BY cantidad DESC";
    
    return $db->fetchAll($sql);
}

/**
 * Obtener actividad reciente del sistema
 */
function obtenerActividadReciente($limite = 10) {
    $db = Database::getInstance();
    
    $sql = "SELECT accion, descripcion, fecha_hora
            FROM logs_actividad 
            ORDER BY fecha_hora DESC 
            LIMIT ?";
    
    return $db->fetchAll($sql, [$limite]);
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
    
    return $nombres[$tipo] ?? ucfirst($tipo);
}

/**
 * Formatear fecha para mostrar
 */
function formatearFecha($fecha, $formato = 'relativo') {
    if (!$fecha) return 'N/A';
    
    $timestamp = strtotime($fecha);
    
    if ($formato === 'relativo') {
        $diff = time() - $timestamp;
        
        if ($diff < 60) {
            return 'Hace ' . $diff . ' segundos';
        } elseif ($diff < 3600) {
            return 'Hace ' . floor($diff / 60) . ' minutos';
        } elseif ($diff < 86400) {
            return 'Hace ' . floor($diff / 3600) . ' horas';
        } elseif ($diff < 604800) {
            return 'Hace ' . floor($diff / 86400) . ' días';
        } else {
            return date('d/m/Y H:i', $timestamp);
        }
    }
    
    return date('d/m/Y H:i', $timestamp);
}

/**
 * Obtener contacto por ID
 */
function obtenerContactoPorId($id) {
    $db = Database::getInstance();
    
    $sql = "SELECT * FROM contactos WHERE id = ?";
    return $db->fetchOne($sql, [$id]);
}

/**
 * Actualizar estado de contacto
 */
function actualizarEstadoContacto($id, $estado, $notas = null) {
    $db = Database::getInstance();
    
    $sql = "UPDATE contactos 
            SET estado = ?, notas_admin = ?, fecha_respuesta = CASE WHEN ? = 'respondido' THEN NOW() ELSE fecha_respuesta END
            WHERE id = ?";
    
    $params = [$estado, $notas, $estado, $id];
    
    try {
        $db->query($sql, $params);
        
        // Registrar actividad
        registrarActividad('cambio_estado_contacto', "Estado cambiado a '{$estado}' para contacto ID: {$id}");
        
        return true;
    } catch (Exception $e) {
        logEvent("Error actualizando estado de contacto {$id}: " . $e->getMessage(), 'ERROR');
        return false;
    }
}

/**
 * Obtener lista de contactos con filtros
 */
function obtenerContactosConFiltros($filtros = [], $pagina = 1, $porPagina = 20) {
    $db = Database::getInstance();
    
    $where = ['1=1'];
    $params = [];
    
    // Aplicar filtros
    if (!empty($filtros['estado'])) {
        $where[] = 'estado = ?';
        $params[] = $filtros['estado'];
    }
    
    if (!empty($filtros['prioridad'])) {
        $where[] = 'prioridad = ?';
        $params[] = $filtros['prioridad'];
    }
    
    if (!empty($filtros['tipo_servicio'])) {
        $where[] = 'tipo_servicio = ?';
        $params[] = $filtros['tipo_servicio'];
    }
    
    if (!empty($filtros['fecha_desde'])) {
        $where[] = 'DATE(fecha_envio) >= ?';
        $params[] = $filtros['fecha_desde'];
    }
    
    if (!empty($filtros['fecha_hasta'])) {
        $where[] = 'DATE(fecha_envio) <= ?';
        $params[] = $filtros['fecha_hasta'];
    }
    
    if (!empty($filtros['busqueda'])) {
        $where[] = '(nombre LIKE ? OR email LIKE ? OR mensaje LIKE ?)';
        $busqueda = '%' . $filtros['busqueda'] . '%';
        $params[] = $busqueda;
        $params[] = $busqueda;
        $params[] = $busqueda;
    }
    
    // Contar total de registros
    $sqlCount = "SELECT COUNT(*) FROM contactos WHERE " . implode(' AND ', $where);
    $total = $db->count($sqlCount, $params);
    
    // Obtener registros paginados
    $offset = ($pagina - 1) * $porPagina;
    $sql = "SELECT * FROM contactos 
            WHERE " . implode(' AND ', $where) . "
            ORDER BY fecha_envio DESC 
            LIMIT ? OFFSET ?";
    
    $params[] = $porPagina;
    $params[] = $offset;
    
    $contactos = $db->fetchAll($sql, $params);
    
    return [
        'contactos' => $contactos,
        'total' => $total,
        'paginas' => ceil($total / $porPagina),
        'pagina_actual' => $pagina
    ];
}

/**
 * Registrar actividad en el log
 */
function registrarActividad($accion, $descripcion, $datosAdicionales = null) {
    $db = Database::getInstance();
    
    $sql = "INSERT INTO logs_actividad (usuario_id, accion, descripcion, ip_cliente, user_agent, datos_adicionales)
            VALUES (?, ?, ?, ?, ?, ?)";
    
    $params = [
        $_SESSION['admin_user_id'] ?? null,
        $accion,
        $descripcion,
        getClientIP(),
        $_SERVER['HTTP_USER_AGENT'] ?? '',
        $datosAdicionales ? json_encode($datosAdicionales) : null
    ];
    
    try {
        $db->query($sql, $params);
    } catch (Exception $e) {
        logEvent("Error registrando actividad: " . $e->getMessage(), 'ERROR');
    }
}

/**
 * Generar CSV de contactos
 */
function generarCSVContactos($filtros = []) {
    $resultado = obtenerContactosConFiltros($filtros, 1, 10000); // Máximo 10k registros
    $contactos = $resultado['contactos'];
    
    $filename = 'contactos_' . date('Y-m-d_H-i-s') . '.csv';
    
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    header('Pragma: no-cache');
    header('Expires: 0');
    
    $output = fopen('php://output', 'w');
    
    // BOM para UTF-8
    fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));
    
    // Encabezados
    fputcsv($output, [
        'ID',
        'Nombre',
        'Email',
        'Teléfono',
        'Tipo de Servicio',
        'Mensaje',
        'Estado',
        'Prioridad',
        'Fecha de Envío',
        'Fecha de Respuesta',
        'IP Cliente',
        'Notas Admin'
    ]);
    
    // Datos
    foreach ($contactos as $contacto) {
        fputcsv($output, [
            $contacto['id'],
            $contacto['nombre'],
            $contacto['email'],
            $contacto['telefono'] ?: 'N/A',
            obtenerNombreServicio($contacto['tipo_servicio']),
            $contacto['mensaje'],
            ucfirst($contacto['estado']),
            ucfirst($contacto['prioridad']),
            $contacto['fecha_envio'],
            $contacto['fecha_respuesta'] ?: 'N/A',
            $contacto['ip_cliente'],
            $contacto['notas_admin'] ?: 'N/A'
        ]);
    }
    
    fclose($output);
    exit;
}

/**
 * Validar credenciales de administrador
 */
function validarCredencialesAdmin($username, $password) {
    $db = Database::getInstance();
    
    // Verificar intentos de login
    $sql = "SELECT intentos_login, bloqueado_hasta FROM admin_users WHERE username = ?";
    $user = $db->fetchOne($sql, [$username]);
    
    if ($user && $user['bloqueado_hasta'] && strtotime($user['bloqueado_hasta']) > time()) {
        return ['success' => false, 'message' => 'Usuario bloqueado temporalmente'];
    }
    
    // Verificar credenciales
    $sql = "SELECT id, username, password_hash, email, nombre_completo, rol, activo 
            FROM admin_users 
            WHERE username = ? AND activo = 1";
    
    $user = $db->fetchOne($sql, [$username]);
    
    if ($user && password_verify($password, $user['password_hash'])) {
        // Login exitoso - resetear intentos
        $sql = "UPDATE admin_users 
                SET intentos_login = 0, bloqueado_hasta = NULL, ultimo_acceso = NOW() 
                WHERE id = ?";
        $db->query($sql, [$user['id']]);
        
        // Configurar sesión
        $_SESSION['admin_logged_in'] = true;
        $_SESSION['admin_user_id'] = $user['id'];
        $_SESSION['admin_username'] = $user['username'];
        $_SESSION['admin_nombre'] = $user['nombre_completo'];
        $_SESSION['admin_rol'] = $user['rol'];
        $_SESSION['last_activity'] = time();
        
        registrarActividad('login_exitoso', 'Login exitoso al panel de administración');
        
        return ['success' => true, 'user' => $user];
    } else {
        // Login fallido - incrementar intentos
        if ($user) {
            $intentos = ($user['intentos_login'] ?? 0) + 1;
            $bloqueado = $intentos >= MAX_LOGIN_ATTEMPTS ? date('Y-m-d H:i:s', time() + LOGIN_LOCKOUT_TIME) : null;
            
            $sql = "UPDATE admin_users 
                    SET intentos_login = ?, bloqueado_hasta = ? 
                    WHERE id = ?";
            $db->query($sql, [$intentos, $bloqueado, $user['id']]);
        }
        
        registrarActividad('login_fallido', "Intento de login fallido para usuario: {$username}");
        
        return ['success' => false, 'message' => 'Credenciales inválidas'];
    }
}

/**
 * Obtener configuración del sistema
 */
function obtenerConfiguracion($clave = null) {
    $db = Database::getInstance();
    
    if ($clave) {
        $sql = "SELECT valor FROM configuracion WHERE clave = ?";
        $result = $db->fetchOne($sql, [$clave]);
        return $result ? $result['valor'] : null;
    } else {
        $sql = "SELECT clave, valor, tipo FROM configuracion";
        $configs = $db->fetchAll($sql);
        
        $resultado = [];
        foreach ($configs as $config) {
            $valor = $config['valor'];
            
            // Convertir según el tipo
            switch ($config['tipo']) {
                case 'boolean':
                    $valor = (bool) $valor;
                    break;
                case 'number':
                    $valor = is_numeric($valor) ? (float) $valor : $valor;
                    break;
                case 'json':
                    $valor = json_decode($valor, true);
                    break;
            }
            
            $resultado[$config['clave']] = $valor;
        }
        
        return $resultado;
    }
}

/**
 * Actualizar configuración
 */
function actualizarConfiguracion($clave, $valor) {
    $db = Database::getInstance();
    
    $sql = "UPDATE configuracion SET valor = ? WHERE clave = ?";
    
    try {
        $db->query($sql, [$valor, $clave]);
        registrarActividad('config_actualizada', "Configuración actualizada: {$clave}");
        return true;
    } catch (Exception $e) {
        logEvent("Error actualizando configuración {$clave}: " . $e->getMessage(), 'ERROR');
        return false;
    }
}

/**
 * Generar breadcrumbs
 */
function generarBreadcrumbs($items) {
    $html = '<nav class="breadcrumbs"><ol class="breadcrumbs__list">';
    
    foreach ($items as $item) {
        if (isset($item['url'])) {
            $html .= '<li class="breadcrumbs__item"><a href="' . htmlspecialchars($item['url']) . '">' . htmlspecialchars($item['text']) . '</a></li>';
        } else {
            $html .= '<li class="breadcrumbs__item breadcrumbs__item--current">' . htmlspecialchars($item['text']) . '</li>';
        }
    }
    
    $html .= '</ol></nav>';
    return $html;
}

/**
 * Sanitizar parámetros de URL
 */
function sanitizarParametroURL($param, $default = '') {
    return isset($_GET[$param]) ? sanitizeInput($_GET[$param]) : $default;
}

/**
 * Generar paginación
 */
function generarPaginacion($paginaActual, $totalPaginas, $baseUrl) {
    if ($totalPaginas <= 1) return '';
    
    $html = '<nav class="pagination">';
    
    // Botón anterior
    if ($paginaActual > 1) {
        $html .= '<a href="' . $baseUrl . '&pagina=' . ($paginaActual - 1) . '" class="pagination__btn pagination__btn--prev">← Anterior</a>';
    }
    
    // Números de página
    $inicio = max(1, $paginaActual - 2);
    $fin = min($totalPaginas, $paginaActual + 2);
    
    if ($inicio > 1) {
        $html .= '<a href="' . $baseUrl . '&pagina=1" class="pagination__number">1</a>';
        if ($inicio > 2) {
            $html .= '<span class="pagination__ellipsis">...</span>';
        }
    }
    
    for ($i = $inicio; $i <= $fin; $i++) {
        if ($i == $paginaActual) {
            $html .= '<span class="pagination__number pagination__number--current">' . $i . '</span>';
        } else {
            $html .= '<a href="' . $baseUrl . '&pagina=' . $i . '" class="pagination__number">' . $i . '</a>';
        }
    }
    
    if ($fin < $totalPaginas) {
        if ($fin < $totalPaginas - 1) {
            $html .= '<span class="pagination__ellipsis">...</span>';
        }
        $html .= '<a href="' . $baseUrl . '&pagina=' . $totalPaginas . '" class="pagination__number">' . $totalPaginas . '</a>';
    }
    
    // Botón siguiente
    if ($paginaActual < $totalPaginas) {
        $html .= '<a href="' . $baseUrl . '&pagina=' . ($paginaActual + 1) . '" class="pagination__btn pagination__btn--next">Siguiente →</a>';
    }
    
    $html .= '</nav>';
    return $html;
}
?>