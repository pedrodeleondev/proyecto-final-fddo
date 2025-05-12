#!/bin/bash

set -e

echo "🐳 Instalando Docker..."
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "🔧 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

echo "📦 Clonando el repositorio..."
cd /home/ec2-user
git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git

cd proyecto-final-fddo/aplicacionWeb

echo "🛠️ Modificando db_config.py..."
# Asegúrate de reemplazar los valores de abajo con los que imprimió el script anterior
DB_HOST="<RDS_ENDPOINT>"
DB_USER="admin"
DB_PASSWORD="proyecto98765"
DB_NAME="proyecto_db"

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
