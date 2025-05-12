#!/bin/bash

set -e  # Detener si ocurre un error

# Determinar la carpeta actual del script
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

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

# Extraer datos reales de RDS
echo "🔍 Extrayendo datos de la base de datos..."
DB_HOST=$(terraform output -raw rds_endpoint | cut -d':' -f1)
DB_USER=$(terraform output -raw rds_username)
DB_NAME=$(terraform output -raw rds_database_name)
DB_PASSWORD="proyecto98765"  # Este valor lo definiste tú en main.tf

echo "🔧 Datos extraídos:"
echo "Host: $DB_HOST"
echo "Usuario: $DB_USER"
echo "Base de datos: $DB_NAME"

# Modificar db_config.py en la app
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

echo "🔧 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

sleep 5

echo "🐋 Ejecutando Docker Compose..."
docker-compose up -d --build

echo ""
echo "✅ La aplicación está en ejecución."
echo "🌐 Accede desde tu navegador a: http://$(curl -s http://checkip.amazonaws.com):5000"
