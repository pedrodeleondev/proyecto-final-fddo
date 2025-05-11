from flask import Flask, render_template, request, redirect, session, url_for, flash, jsonify
from db_config import get_db, close_db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'clave_super_secreta'
app.teardown_appcontext(close_db)

# Página principal con lista de productos
@app.route('/')
def index():
    if 'usuario' not in session:
        return redirect(url_for('login'))

    db = get_db()
    with db.cursor() as cursor:
        cursor.execute("SELECT * FROM productos")
        productos = cursor.fetchall()

    return render_template('index.html', productos=productos)

# Login
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        usuario = request.form['usuario']
        contrasena = request.form['contrasena']
        db = get_db()
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM usuarios WHERE usuario=%s", (usuario,))
            user = cursor.fetchone()
            if user and check_password_hash(user['contrasena'], contrasena):
                session['usuario'] = user['id']
                session['es_admin'] = user.get('es_admin', 0)
                return redirect(url_for('index'))
            flash("Credenciales incorrectas")
    return render_template('login.html')

# Registro
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        usuario = request.form['usuario']
        contrasena = generate_password_hash(request.form['contrasena'])
        codigo = request.form.get('codigo', '').strip()
        es_admin = codigo == 'ppf25'

        db = get_db()
        with db.cursor() as cursor:
            try:
                cursor.execute(
                    "INSERT INTO usuarios (usuario, contrasena, es_admin) VALUES (%s, %s, %s)",
                    (usuario, contrasena, es_admin)
                )
                db.commit()
                flash("Registro exitoso. Inicia sesión.")
                return redirect(url_for('login'))
            except Exception as e:
                db.rollback()
                if "Duplicate entry" in str(e):
                    flash("Error: El usuario ya existe.")
                else:
                    flash(f"Error inesperado: {e}")
                return render_template('register.html')

    return render_template('register.html')

# Logout
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

# Mis compras
@app.route('/miscompras')
def miscompras():
    if 'usuario' not in session:
        return redirect(url_for('login'))

    db = get_db()
    with db.cursor() as cursor:
        cursor.execute("""
            SELECT c.id AS compra_id, c.fecha_compra, c.total,
                   p.nombre, dc.cantidad, dc.precio_unitario
            FROM compras c
            JOIN detalle_compras dc ON c.id = dc.compra_id
            JOIN productos p ON dc.producto_id = p.id
            WHERE c.usuario_id = %s
            ORDER BY c.fecha_compra DESC
        """, (session['usuario'],))
        registros = cursor.fetchall()

    compras = {}
    for row in registros:
        cid = row['compra_id']
        if cid not in compras:
            compras[cid] = {
                'id': cid,
                'fecha_compra': row['fecha_compra'],
                'total': row['total'],
                'items': []
            }
        compras[cid]['items'].append({
            'nombre': row['nombre'],
            'cantidad': row['cantidad'],
            'precio_unitario': row['precio_unitario'],
            'subtotal': row['cantidad'] * row['precio_unitario']
        })

    return render_template('miscompras.html', compras=list(compras.values()))

# Carrito
@app.route('/carrito')
def carrito():
    if 'usuario' not in session:
        return redirect(url_for('login'))
    return render_template('carrito.html')

# Comprar
@app.route('/comprar', methods=['POST'])
def comprar():
    if 'usuario' not in session:
        return jsonify({'error': 'No autorizado'}), 401

    data = request.get_json()
    carrito = data.get('carrito', [])

    if not carrito:
        return jsonify({'error': 'Carrito vacío'}), 400

    db = get_db()
    total = sum(item['precio'] * item['cantidad'] for item in carrito)

    try:
        with db.cursor() as cursor:
            cursor.execute(
                "INSERT INTO compras (usuario_id, total) VALUES (%s, %s)",
                (session['usuario'], total)
            )
            compra_id = cursor.lastrowid

            for item in carrito:
                cursor.execute(
                    "INSERT INTO detalle_compras (compra_id, producto_id, cantidad, precio_unitario) "
                    "VALUES (%s, %s, %s, %s)",
                    (compra_id, item['id'], item['cantidad'], item['precio'])
                )
                cursor.execute(
                    "UPDATE productos SET inventario = inventario - %s WHERE id = %s",
                    (item['cantidad'], item['id'])
                )

            db.commit()
        return jsonify({'message': 'Compra realizada'})
    except Exception as e:
        db.rollback()
        return jsonify({'error': 'Error al procesar compra', 'details': str(e)}), 500

# Administración de productos
@app.route('/admin_productos', methods=['GET', 'POST'])
def admin_productos():
    if not session.get('es_admin'):
        flash("Acceso no autorizado.")
        return redirect(url_for('index'))

    db = get_db()
    with db.cursor() as cursor:
        if request.method == 'POST':
            nombre = request.form['nombre']
            descripcion = request.form['descripcion']
            imagen_url = request.form['imagen_url']
            precio = float(request.form['precio'])
            inventario = int(request.form['inventario'])

            cursor.execute("""
                INSERT INTO productos (nombre, descripcion, imagen_url, precio, inventario)
                VALUES (%s, %s, %s, %s, %s)
            """, (nombre, descripcion, imagen_url, precio, inventario))
            db.commit()

        cursor.execute("SELECT * FROM productos")
        productos = cursor.fetchall()

    return render_template('admin_productos.html', productos=productos)

@app.route('/eliminar_producto/<int:producto_id>', methods=['POST'])
def eliminar_producto(producto_id):
    if not session.get('es_admin'):
        return redirect(url_for('index'))
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM productos WHERE id = %s", (producto_id,))
        db.commit()
    return redirect(url_for('admin_productos'))

@app.route('/editar_producto/<int:producto_id>', methods=['POST'])
def editar_producto(producto_id):
    if not session.get('es_admin'):
        return redirect(url_for('index'))

    nombre = request.form['nombre']
    descripcion = request.form['descripcion']
    imagen_url = request.form['imagen_url']
    precio = float(request.form['precio'])
    inventario = int(request.form['inventario'])

    db = get_db()
    with db.cursor() as cursor:
        cursor.execute("""
            UPDATE productos
            SET nombre=%s, descripcion=%s, imagen_url=%s, precio=%s, inventario=%s
            WHERE id=%s
        """, (nombre, descripcion, imagen_url, precio, inventario, producto_id))
        db.commit()

    return redirect(url_for('admin_productos'))

# Ejecutar la app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
