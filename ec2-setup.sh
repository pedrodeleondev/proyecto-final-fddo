#!/bin/bash

set -e

echo "🐳 Instalando Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

echo "🔧 Instalando Docker Compose..."
DOCKER_COMPOSE_VERSION="v2.20.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version || { echo "❌ Docker Compose no se instaló correctamente."; exit 1; }

echo "📦 Clonando el repositorio..."
cd /home/ec2-user
if [ ! -d "proyecto-final-fddo" ]; then
  git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git
fi
cd proyecto-final-fddo/aplicacionWeb

echo "📥 Verificando archivo db.env..."
if [ ! -f "./db.env" ]; then
  echo "❌ ERROR: No se encontró db.env. Verifica el script user_data o crea el archivo manualmente."
  exit 1
fi

# Mostrar contenido para depuración (puedes comentarlo si es sensible)
echo "🔐 Variables de entorno cargadas:"
cat db.env

echo "📁 Comprobando existencia de archivos requeridos..."
[ -f docker-compose.yml ] || { echo "❌ docker-compose.yml no encontrado."; exit 1; }
[ -f app.py ] || { echo "❌ app.py no encontrado."; exit 1; }

echo "🐋 Ejecutando Docker Compose..."
docker-compose down --volumes --remove-orphans || true
docker-compose up -d --build

echo ""
echo "✅ La aplicación está en ejecución. Verifica el servicio en http://<tu-ip>:5000"
