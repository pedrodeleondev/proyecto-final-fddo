FROM python:3.10-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos necesarios
COPY requirements.txt .

# Instalar dependencias primero (cache mejor)
RUN pip install --no-cache-dir -r requirements.txt

# Luego copiar el resto del proyecto
COPY . .

# Exponer el puerto que usa Flask
EXPOSE 5000

# Comando por defecto para ejecutar la app
CMD ["python", "app.py"]
