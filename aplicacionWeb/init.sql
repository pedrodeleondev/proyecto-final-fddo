DROP DATABASE IF EXISTS tienda_audifonos;
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS tienda_audifonos;
USE tienda_audifonos;

-- Tabla de usuarios con rol de admin
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    es_admin BOOLEAN DEFAULT FALSE
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    imagen_url VARCHAR(255),
    precio DECIMAL(10, 2) NOT NULL,
    inventario INT NOT NULL
);

-- Compras (cabecera)
CREATE TABLE IF NOT EXISTS compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    fecha_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Detalle de compras
CREATE TABLE IF NOT EXISTS detalle_compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    imagen_url VARCHAR(255),
    descripcion TEXT,
    FOREIGN KEY (compra_id) REFERENCES compras(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);


-- Datos iniciales (productos)
INSERT INTO productos (nombre, descripcion, imagen_url, precio, inventario) VALUES
('Sony WH-1000XM5', 'Audífonos con cancelacion de ruido', 'https://www.sony.com.mx/image/6145c1d32e6ac8e63a46c912dc33c5bb?fmt=pjpeg&wid=330&bgcolor=FFFFFF&bgc=FFFFFF', 299.99, 20),
('AirPods Pro 2', 'Auriculares inalambricos de Apple', 'https://cdn1.coppel.com/images/catalog/pm/2730753-1.jpg', 249.99, 30);

