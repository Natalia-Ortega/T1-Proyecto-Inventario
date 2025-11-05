-- CREACIÓN DE LA BASE DE DATOS Y TABLAS

-- base de datos
CREATE DATABASE IF NOT EXISTS sigi__inventario;
USE sigi__inventario;

-- proveedores
CREATE TABLE IF NOT EXISTS Proveedor (
    ID_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    empresa VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- usuarios r10
CREATE TABLE IF NOT EXISTS Usuario (
    ID_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    rol ENUM('administrador', 'vendedor') NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso DATETIME
);

-- cliente r8
CREATE TABLE IF NOT EXISTS Cliente (
    ID_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_compras DECIMAL(12,2) DEFAULT 0,
    cantidad_compras INT DEFAULT 0
);

-- categorías 
CREATE TABLE IF NOT EXISTS Categoria (
    ID_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- productos r1,r2,r3,r9,r12,r13
CREATE TABLE IF NOT EXISTS Producto (
    ID_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    stock_min INT NOT NULL DEFAULT 5,
    vendidos INT DEFAULT 0,
    es_perecedero BOOLEAN DEFAULT FALSE,
    fecha_caducidad DATE NULL,
    ID_proveedor INT,
    ID_categoria INT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_proveedor) REFERENCES Proveedor(ID_proveedor) ON DELETE SET NULL,
    FOREIGN KEY (ID_categoria) REFERENCES Categoria(ID_categoria) ON DELETE SET NULL
);

-- ventas 
CREATE TABLE IF NOT EXISTS Venta (
    ID_venta INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia') NOT NULL,
    ID_usuario INT NOT NULL,
    ID_cliente INT NULL,
    estado ENUM('completada', 'cancelada', 'pendiente') DEFAULT 'completada',
    FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (ID_cliente) REFERENCES Cliente(ID_cliente) ON DELETE SET NULL
);

-- detalles de venta r9
CREATE TABLE IF NOT EXISTS DetalleVenta (
    ID_detalle INT PRIMARY KEY AUTO_INCREMENT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unit DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    ID_venta INT NOT NULL,
    ID_producto INT NOT NULL,
    FOREIGN KEY (ID_venta) REFERENCES Venta(ID_venta) ON DELETE CASCADE,
    FOREIGN KEY (ID_producto) REFERENCES Producto(ID_producto) ON DELETE RESTRICT
);

-- movimientos de inventario r3,r6
CREATE TABLE IF NOT EXISTS MovimientoInventario (
    ID_movimiento INT PRIMARY KEY AUTO_INCREMENT,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste') NOT NULL,
    cantidad INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    motivo ENUM('compra', 'venta', 'ajuste_stock', 'devolucion', 'danio', 'caducidad') NOT NULL,
    ID_producto INT NOT NULL,
    ID_usuario INT NOT NULL,
    FOREIGN KEY (ID_producto) REFERENCES Producto(ID_producto) ON DELETE CASCADE,
    FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE RESTRICT
);

-- alertas r4.r5
CREATE TABLE IF NOT EXISTS Alerta (
    ID_alerta INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta ENUM('stock_bajo', 'caducidad_proxima', 'stock_agotado') NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_generada DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_resuelta DATETIME NULL,
    leida BOOLEAN DEFAULT FALSE,
    ID_producto INT NOT NULL,
    ID_usuario_genera INT,
    prioridad ENUM('baja', 'media', 'alta') DEFAULT 'media',
    FOREIGN KEY (ID_producto) REFERENCES Producto(ID_producto) ON DELETE CASCADE,
    FOREIGN KEY (ID_usuario_genera) REFERENCES Usuario(ID_usuario) ON DELETE SET NULL
);

-- reportes r7.r8
CREATE TABLE IF NOT EXISTS Reporte (
    ID_reporte INT PRIMARY KEY AUTO_INCREMENT,
    tipo_reporte ENUM('inventario', 'ventas', 'stock_bajo', 'caducidad', 'rendimiento', 'clientes') NOT NULL,
    nombre_archivo VARCHAR(255),
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_inicio DATE,
    fecha_fin DATE,
    ID_usuario INT NOT NULL,
    FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE RESTRICT
);

-- configuracion del sistema
CREATE TABLE IF NOT EXISTS Configuracion (
    ID_config INT PRIMARY KEY AUTO_INCREMENT,
    clave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT NOT NULL,
    descripcion TEXT,
    tipo ENUM('entero', 'decimal', 'texto', 'booleano', 'fecha') DEFAULT 'texto',
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- auditoría de actividades r14
CREATE TABLE IF NOT EXISTS Auditoria (
    ID_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    ID_usuario INT NOT NULL,
    tipo_operacion ENUM('creacion', 'edicion', 'eliminacion', 'ingreso', 'salida', 'consulta', 'login', 'logout', 'configuracion') NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    modulo_afectado ENUM('producto', 'venta', 'usuario', 'proveedor', 'categoria', 'cliente', 'sistema', 'inventario') NOT NULL,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE RESTRICT
);

-- indices para mejor rendimiento
CREATE INDEX idx_producto_nombre ON Producto(nombre);
CREATE INDEX idx_producto_stock ON Producto(stock);
CREATE INDEX idx_producto_caducidad ON Producto(fecha_caducidad);
CREATE INDEX idx_venta_fecha ON Venta(fecha);
CREATE INDEX idx_venta_usuario ON Venta(ID_usuario);
CREATE INDEX idx_venta_cliente ON Venta(ID_cliente);
CREATE INDEX idx_movimiento_producto ON MovimientoInventario(ID_producto);
CREATE INDEX idx_movimiento_fecha ON MovimientoInventario(fecha);
CREATE INDEX idx_alerta_producto ON Alerta(ID_producto);
CREATE INDEX idx_alerta_tipo ON Alerta(tipo_alerta);
CREATE INDEX idx_alerta_leida ON Alerta(leida);
CREATE INDEX idx_usuario_rol ON Usuario(rol);
CREATE INDEX idx_cliente_nombre ON Cliente(nombre);
CREATE INDEX idx_cliente_compras ON Cliente(cantidad_compras);
CREATE INDEX idx_categoria_nombre ON Categoria(nombre);
CREATE INDEX idx_auditoria_usuario ON Auditoria(ID_usuario);
CREATE INDEX idx_auditoria_fecha ON Auditoria(fecha_hora);
CREATE INDEX idx_auditoria_tipo ON Auditoria(tipo_operacion);
CREATE INDEX idx_auditoria_modulo ON Auditoria(modulo_afectado);

-- actualizar estadísticas del cliente
DELIMITER //
CREATE TRIGGER actualizar_estadisticas_cliente
AFTER INSERT ON Venta
FOR EACH ROW
BEGIN
    IF NEW.ID_cliente IS NOT NULL THEN
        UPDATE Cliente 
        SET total_compras = total_compras + NEW.total,
            cantidad_compras = cantidad_compras + 1
        WHERE ID_cliente = NEW.ID_cliente;
    END IF;
END//
DELIMITER ;

-- actualizar stock al realizar ventas
DELIMITER //
CREATE TRIGGER actualizar_stock_venta
AFTER INSERT ON DetalleVenta
FOR EACH ROW
BEGIN
    UPDATE Producto 
    SET stock = stock - NEW.cantidad,
        vendidos = vendidos + NEW.cantidad,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE ID_producto = NEW.ID_producto;
    
    -- Insertar movimiento de inventario por la venta
    INSERT INTO MovimientoInventario (tipo_movimiento, cantidad, motivo, ID_producto, ID_usuario)
    SELECT 'salida', NEW.cantidad, 'venta', NEW.ID_producto, V.ID_usuario
    FROM Venta V WHERE V.ID_venta = NEW.ID_venta;
END//
DELIMITER ;

-- Trigger para inserción de producto
DELIMITER //
CREATE TRIGGER auditoria_after_insert_producto
AFTER INSERT ON Producto
FOR EACH ROW
BEGIN
    -- Supongamos que el usuario que realiza la acción tiene ID 1 (administrador)
    INSERT INTO Auditoria (
        ID_usuario, 
        tipo_operacion, 
        modulo_afectado, 
        descripcion
    )
    VALUES (
        1, -- ID de usuario fijo para pruebas
        'creacion', 
        'producto', 
        CONCAT('Se creó el producto: ', NEW.nombre, ' (ID: ', NEW.ID_producto, ') - Stock inicial: ', NEW.stock)
    );
END//
DELIMITER ;

-- DATOS PRUEBA

-- configuración del sistema
INSERT INTO Configuracion (clave, valor, descripcion, tipo) VALUES 
('dias_alerta_caducidad', '7', 'Días de anticipación para alertas de caducidad', 'entero'),
('stock_minimo_global', '5', 'Stock mínimo global para productos', 'entero'),
('empresa_nombre', 'Minimarket SIGI', 'Nombre de la empresa', 'texto'),
('empresa_direccion', 'Antofagasta, Chile', 'Dirección de la empresa', 'texto'),
('empresa_telefono', '+56 9 1234 5678', 'Teléfono de la empresa', 'texto');

-- usuario administrador por defecto
INSERT INTO Usuario (nombre, contrasena, rol) VALUES 
('admin', 'admin123', 'administrador'),
('vendedor1', 'vendedor123', 'vendedor');

-- cliente por defecto 
INSERT INTO Cliente (nombre) VALUES 
('Cliente general');

-- categorias de productos
INSERT INTO Categoria (nombre) VALUES 
('Abarrotes'),
('Lácteos y Huevos'),
('Bebidas'),
('Limpieza'),
('Panadería');

-- ejemplo de proveedores
INSERT INTO Proveedor (nombre, empresa, telefono) VALUES 
('Juan Pérez', 'La Vega', '+56 9 1234 5678'),
('María González', 'Bebidas del Norte Ltda.', '+56 9 8765 4321'),
('Carlos López', 'Jumbo', '+56 9 5555 4444');

-- CONSULTAS DE SEGÚN REQUISITOS FUNCIONALES (PRUEBA)

-- RF-001: REGISTRO DE PRODUCTOS
INSERT INTO Producto (nombre, descripcion, precio, costo, stock, stock_min, es_perecedero, fecha_caducidad, ID_proveedor, ID_categoria) 
VALUES 
('Arroz Grano Largo 1kg', 'Arroz premium grano largo', 1200.00, 800.00, 50, 10, FALSE, NULL, 1, 1),
('Leche Entera 1L', 'Leche entera ultrapasteurizada', 850.00, 600.00, 30, 15, TRUE, '2025-12-15', 1, 2),
('Jabón Líquido 500ml', 'Jabón líquido para manos', 1500.00, 1000.00, 25, 5, FALSE, NULL, 3, 4);

SELECT '=== RF-001: PRODUCTOS REGISTRADOS ===' as resultado;
SELECT ID_producto, nombre, precio, stock FROM Producto;

-- RF-003: CONTROL DE STOCK
SELECT '=== RF-003: ESTADO DE STOCK ===' as resultado;
SELECT nombre, stock, stock_min FROM Producto ORDER BY stock ASC;

-- RF-005: ALERTAS DE CADUCIDAD
INSERT INTO Alerta (tipo_alerta, descripcion, ID_producto, ID_usuario_genera, prioridad)
VALUES ('caducidad_proxima', 'Leche próxima a caducar el 2025-12-15', 2, 1, 'alta');

SELECT '=== RF-005: ALERTAS DE CADUCIDAD ===' as resultado;
SELECT tipo_alerta, descripcion FROM Alerta WHERE tipo_alerta = 'caducidad_proxima';

-- RF-007: REPORTES DE INVENTARIO
SELECT '=== RF-007: REPORTE DE INVENTARIO ===' as resultado;
SELECT nombre, precio, costo, stock, (precio - costo) as utilidad FROM Producto;

-- RF-008: REPORTES DE VENTAS DIARIAS
INSERT INTO Venta (total, subtotal, metodo_pago, ID_usuario, ID_cliente) VALUES 
(2400.00, 2400.00, 'efectivo', 2, 1);

INSERT INTO DetalleVenta (cantidad, precio_unit, subtotal, ID_venta, ID_producto)
VALUES (2, 1200.00, 2400.00, LAST_INSERT_ID(), 1);

SELECT '=== RF-008: VENTAS DEL DÍA ===' as resultado;
SELECT v.fecha, v.total, v.metodo_pago, u.nombre as vendedor 
FROM Venta v 
JOIN Usuario u ON v.ID_usuario = u.ID_usuario 
WHERE DATE(v.fecha) = CURDATE();

-- RF-009: CÁLCULO DE DEMANDA
SELECT '=== RF-009: NIVELES DE DEMANDA ===' as resultado;
SELECT 
    nombre,
    vendidos as cantidad_vendida,
    CASE 
        WHEN vendidos > 10 THEN 'ALTA'
        WHEN vendidos BETWEEN 5 AND 10 THEN 'MEDIA'
        ELSE 'BAJA'
    END as demanda
FROM Producto;

-- RF-011: DASHBOARD GERENCIAL
SELECT '=== RF-011: MÉTRICAS DEL DASHBOARD ===' as resultado;
SELECT 
    (SELECT COUNT(*) FROM Producto) as total_productos,
    (SELECT COUNT(*) FROM Producto WHERE stock <= stock_min) as productos_stock_bajo,
    (SELECT COUNT(*) FROM Alerta WHERE leida = FALSE) as alertas_pendientes,
    (SELECT COALESCE(SUM(total), 0) FROM Venta WHERE DATE(fecha) = CURDATE()) as ventas_hoy;

-- RF-012: DETALLES DEL PRODUCTO
SELECT '=== RF-012: DETALLES DE PRODUCTO ===' as resultado;
SELECT p.*, c.nombre as categoria, pr.nombre as proveedor 
FROM Producto p 
LEFT JOIN Categoria c ON p.ID_categoria = c.ID_categoria 
LEFT JOIN Proveedor pr ON p.ID_proveedor = pr.ID_proveedor 
WHERE p.ID_producto = 1;

-- RF-013: BÚSQUEDA PARAMÉTRICA
SELECT '=== RF-013: BÚSQUEDA DE PRODUCTOS ===' as resultado;
SELECT ID_producto, nombre, precio, stock 
FROM Producto 
WHERE nombre LIKE '%arroz%' OR nombre LIKE '%leche%';

-- RF-014: AUDITORÍA DE ACTIVIDADES
INSERT INTO Producto (
    nombre, 
    descripcion, 
    precio, 
    costo, 
    stock, 
    stock_min, 
    es_perecedero,
    ID_proveedor,
    ID_categoria
) VALUES (
    'Arroz Integral 1kg',
    'Arroz integral de grano largo',
    2.50,
    1.80,
    100,
    10,
    FALSE,
    1,  -- Asegúrate de que exista un proveedor con ID 1
    1   -- Asegúrate de que exista una categoría con ID 1
);

UPDATE Producto 
SET stock = 85 
WHERE nombre = 'Arroz Integral 1kg';

SELECT 
    a.tipo_operacion,
    a.descripcion,
    a.fecha_hora,
    u.nombre as usuario_responsable
FROM Auditoria a
LEFT JOIN Usuario u ON a.ID_usuario = u.ID_usuario
WHERE a.modulo_afectado = 'producto'
ORDER BY a.fecha_hora DESC;

-- VERIFICACIÓN FINAL

SELECT 
    (SELECT COUNT(*) FROM Producto) as total_productos,
    (SELECT COUNT(*) FROM Venta) as total_ventas,
    (SELECT COUNT(*) FROM Alerta) as total_alertas,
    (SELECT COUNT(*) FROM MovimientoInventario) as total_movimientos,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'sigi__inventario') as total_tablas;

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'sigi__inventario' 
ORDER BY table_name;