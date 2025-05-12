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
git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git || true
cd proyecto-final-fddo/aplicacionWeb

echo "📥 Cargando variables de entorno desde /home/ec2-user/db.env..."
if [ ! -f /home/ec2-user/db.env ]; then
  echo "❌ ERROR: El archivo db.env no existe. Sube el archivo desde Cloud9 con los datos de la base de datos."
  exit 1
fi

source /home/ec2-user/db.env

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
echo "🌐 Abre en tu navegador: http://$(curl -s http://checkip.amazonaws.com):5000"
