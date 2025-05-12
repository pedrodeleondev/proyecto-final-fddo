#!/bin/bash

set -e

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

echo "🧹 Limpiando espacio en Cloud9..."
sudo service docker stop || true
sudo rm -rf /var/lib/docker || true
rm -rf /tmp/* ~/.cache/* ~/.npm ~/.terraform.d ~/.local/share/Trash
sudo rm -rf /usr/share/doc/*
df -h

echo "🔧 Instalando Terraform en /tmp..."
cd /tmp
wget -q https://releases.hashicorp.com/terraform/0.15.1/terraform_0.15.1_linux_amd64.zip
unzip -o terraform_0.15.1_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -version

cd "$BASE_DIR"

echo "📦 Clonando el repositorio..."
git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git
cd proyecto-final-fddo

echo "🚀 Ejecutando Terraform..."
cd infraestructuraTF-AWS
terraform init -input=false
terraform plan -input=false -out=tfplan
terraform apply -auto-approve tfplan
rm -rf .terraform tfplan

echo "🔍 Extrayendo datos de la base de datos..."
DB_HOST=$(terraform output -raw rds_endpoint | cut -d':' -f1)
DB_USER=$(terraform output -raw rds_username)
DB_NAME=$(terraform output -raw rds_database_name)
DB_PASSWORD="proyecto98765"

echo "🛠️ Modificando db_config.py..."
cd "$BASE_DIR/proyecto-final-fddo/aplicacionWeb"
sed -i "s/'host': os.getenv('DB_HOST', 'localhost')/'host': '$DB_HOST'/g" db_config.py
sed -i "s/'user': os.getenv('DB_USER', 'root')/'user': '$DB_USER'/g" db_config.py
sed -i "s/'password': os.getenv('DB_PASSWORD', '')/'password': '$DB_PASSWORD'/g" db_config.py
sed -i "s/'db': os.getenv('DB_NAME', 'tienda_audifonos')/'db': '$DB_NAME'/g" db_config.py

echo "🐳 Instalando Docker..."
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "🔧 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

sleep 3

echo "🐋 Ejecutando Docker Compose (modo limpio)..."
docker-compose down --volumes --remove-orphans || true
docker-compose up -d --build

echo ""
echo "✅ La aplicación está en ejecución."
echo "🌐 Abre: http://$(curl -s http://checkip.amazonaws.com):5000"
