// Utilidades para localStorage
function obtenerCarrito() {
    return JSON.parse(localStorage.getItem('carrito')) || [];
}

function guardarCarrito(carrito) {
    localStorage.setItem('carrito', JSON.stringify(carrito));
}

function agregarAlCarrito(id, nombre, precio) {
    let carrito = obtenerCarrito();
    const productoExistente = carrito.find(p => p.id === id);

    if (productoExistente) {
        productoExistente.cantidad += 1;
    } else {
        carrito.push({ id, nombre, precio, cantidad: 1 });
    }

    guardarCarrito(carrito);
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
    const tbody = document.querySelector('#tabla-carrito tbody');
    const totalSpan = document.getElementById('total-carrito');
    let total = 0;

    tbody.innerHTML = '';

    carrito.forEach((producto, index) => {
        const subtotal = producto.precio * producto.cantidad;
        total += subtotal;

        const fila = document.createElement('tr');
        fila.innerHTML = `
            <td>${producto.nombre}</td>
            <td>$${producto.precio.toFixed(2)}</td>
            <td>
                <input type="number" min="1" value="${producto.cantidad}" onchange="cambiarCantidad(${index}, this.value)">
            </td>
            <td>$${subtotal.toFixed(2)}</td>
            <td><button onclick="eliminarDelCarrito(${index})">❌</button></td>
        `;
        tbody.appendChild(fila);
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
