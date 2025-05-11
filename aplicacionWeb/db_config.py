import pymysql
import os
import time
from flask import g

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'tienda_audifonos'),
    'cursorclass': pymysql.cursors.DictCursor
}

def get_db():
    if 'db' not in g:
        # Intentar conectarse con reintentos si MySQL aún no está listo
        for intento in range(10):
            try:
                g.db = pymysql.connect(**DB_CONFIG)
                break  # Si conecta, sal del bucle
            except pymysql.err.OperationalError as e:
                print(f"[MySQL] Intento {intento + 1}/10 fallido. Esperando conexión...")
                time.sleep(2)
        else:
            raise Exception("No se pudo conectar a la base de datos MySQL después de varios intentos.")
    return g.db

def close_db(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()
