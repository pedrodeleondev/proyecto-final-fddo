FROM python:3.10

# Crear carpeta y copiar archivos
WORKDIR /app
COPY . /app

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Exponer el puerto
EXPOSE 5000

# Ejecutar la app
CMD ["python", "app.py"]
