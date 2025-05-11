// Utilidades para localStorage
function obtenerCarrito() {
    return JSON.parse(localStorage.getItem('carrito')) || [];
}

function guardarCarrito(carrito) {
    localStorage.setItem('carrito', JSON.stringify(carrito));
}

function agregarAlCarrito(id, nombre, precio, imagen_url, descripcion) {
    let carrito = obtenerCarrito();
    const productoExistente = carrito.find(p => p.id === id);

    if (productoExistente) {
        productoExistente.cantidad += 1;
    } else {
        carrito.push({ id, nombre, precio, cantidad: 1 , imagen_url, descripcion });
    }

    guardarCarrito(carrito);
    JSON.parse(localStorage.getItem('carrito'))
    alert(`${nombre} se añadió al carrito.`);
}

function cambiarCantidad(indice, nuevaCantidad) {
    let carrito = obtenerCarrito();
    nuevaCantidad = parseInt(nuevaCantidad);

    if (nuevaCantidad <= 0 || isNaN(nuevaCantidad)) {
        eliminarDelCarrito(indice);
        return;
    }

    carrito[indice].cantidad = nuevaCantidad;
    guardarCarrito(carrito);
    mostrarCarrito();
}

// Mostrar productos en carrito.html
function mostrarCarrito() {
    const carrito = obtenerCarrito();
    const contenedor = document.getElementById('contenedor-carrito');
    const totalSpan = document.getElementById('total-carrito');
    let total = 0;

    contenedor.innerHTML = '';

    carrito.forEach((producto, index) => {
        const subtotal = producto.precio * producto.cantidad;
        total += subtotal;

        const article = document.createElement('article');
        article.className = 'productoCarr';
        article.innerHTML = `
            <a class="eliminar" onclick="eliminarDelCarrito(${index})">
                <i class="fa-solid fa-xmark"></i>
            </a>
            <div class="productoCarrito">
                <img src="${producto.imagen_url}" alt="${producto.nombre}" />
                <div class="productoContenido">
                    <h3>${producto.nombre}</h3>
                    <h5>${producto.descripcion}</h5>
                    <p id="opciones">Precio: $${producto.precio.toFixed(2)}</p>
                    <div class="cantidades">
                        <p>Cantidad </p>
                        <button class="boton" onclick="cambiarCantidad(${index}, ${producto.cantidad - 1})">-</button>
                        <span class="cantidad" id="cantidad">${producto.cantidad}</span>
                        <button class="boton" onclick="cambiarCantidad(${index}, ${producto.cantidad + 1})">+</button>
                    </div>
                </div>
            </div>
        `;

        contenedor.appendChild(article);
    });

    totalSpan.textContent = total.toFixed(2);
}

function eliminarDelCarrito(indice) {
    const carrito = obtenerCarrito();
    carrito.splice(indice, 1);
    guardarCarrito(carrito);
    mostrarCarrito();
}

// Enviar carrito a Flask para simular compra
function realizarCompra() {
    const carrito = obtenerCarrito();

    if (carrito.length === 0) {
        alert("Tu carrito está vacío.");
        return;
    }

    fetch('/comprar', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ carrito })
    })
    .then(response => {
        if (response.ok) {
            localStorage.removeItem('carrito');
            alert('Compra realizada con éxito.');
            window.location.href = '/miscompras';
        } else {
            alert('Error al procesar la compra.');
        }
    })
    .catch(() => alert('Error de conexión.'));
}

// Ejecutar automáticamente en carrito.html
if (window.location.pathname === '/carrito') {
    document.addEventListener('DOMContentLoaded', mostrarCarrito);
}
