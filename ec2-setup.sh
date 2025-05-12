#!/bin/bash

set -e

echo "🐳 Instalando Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

echo "🔧 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

echo "📦 Clonando el repositorio..."
cd /home/ec2-user
if [ ! -d "proyecto-final-fddo" ]; then
  git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git
fi
cd proyecto-final-fddo/aplicacionWeb

echo "📥 Cargando variables de entorno..."
if [ ! -f "./db.env" ]; then
  echo "❌ ERROR: No se encontró db.env. Verifica el user_data o crea el archivo antes de continuar."
  exit 1
fi

source ./db.env

echo "🛠️ Modificando db_config.py..."
sed -i "s/'host': os.getenv('DB_HOST', 'localhost')/'host': '$DB_HOST'/g" db_config.py
sed -i "s/'user': os.getenv('DB_USER', 'root')/'user': '$DB_USER'/g" db_config.py
sed -i "s/'password': os.getenv('DB_PASSWORD', '')/'password': '$DB_PASSWORD'/g" db_config.py
sed -i "s/'db': os.getenv('DB_NAME', 'tienda_audifonos')/'db': '$DB_NAME'/g" db_config.py

echo "🐋 Ejecutando Docker Compose..."
docker-compose down --volumes --remove-orphans || true
docker-compose up -d --build

echo ""
echo "✅ La aplicación está en ejecución."
