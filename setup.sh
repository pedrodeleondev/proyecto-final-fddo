#!/bin/bash

set -e  # Detener si ocurre un error

# Determinar la carpeta actual del script
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

echo "🔧 Instalando Terraform en /tmp..."

cd /tmp
wget https://releases.hashicorp.com/terraform/0.15.1/terraform_0.15.1_linux_amd64.zip
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

# Extraer datos de RDS
echo "🔍 Extrayendo datos de la base de datos..."
DB_HOST=$(terraform output -raw endpoint)
DB_USER="admin"
DB_PASSWORD="admin"
DB_NAME="tienda_audifonos"

cd "$BASE_DIR/proyecto-final-fddo/aplicacionWeb"

echo "🛠️ Modificando db_config.py con los datos de RDS..."
sed -i "s/'host': os.getenv('DB_HOST', 'localhost')/'host': '$DB_HOST'/g" db_config.py
sed -i "s/'user': os.getenv('DB_USER', 'root')/'user': '$DB_USER'/g" db_config.py
sed -i "s/'password': os.getenv('DB_PASSWORD', '')/'password': '$DB_PASSWORD'/g" db_config.py
sed -i "s/'db': os.getenv('DB_NAME', 'tienda_audifonos')/'db': '$DB_NAME'/g" db_config.py

echo "🐳 Instalando Docker..."
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

sleep 5

echo "🐋 Ejecutando Docker Compose..."
docker compose up -d --build

echo "✅ Todo listo. Abre http://localhost:5000 o la IP pública:5000 en el navegador."
