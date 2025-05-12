#!/bin/bash

set -e

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
cd proyecto-final-fddo/infraestructuraTF-AWS

echo "🚀 Ejecutando Terraform..."
terraform init -input=false
terraform plan -input=false -out=tfplan
terraform apply -auto-approve tfplan
rm -rf .terraform tfplan

echo "✅ Infraestructura creada con éxito."

# Extraer datos RDS
DB_HOST=$(terraform output -raw rds_endpoint | cut -d':' -f1)
DB_USER=$(terraform output -raw rds_username)
DB_NAME=$(terraform output -raw rds_database_name)
DB_PASSWORD="proyecto98765"  # Debe coincidir con lo definido en main.tf

echo ""
echo "📤 Datos de conexión a la base de datos:"
echo "HOST: $DB_HOST"
echo "USER: $DB_USER"
echo "DB: $DB_NAME"

# Crear archivo .env
echo "📝 Generando archivo db.env..."
cat <<EOF > db.env
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
EOF

echo ""
read -p "🌍 Ingresa la IP pública de tu instancia EC2 (ej. 44.201.12.34): " EC2_IP

echo "📦 Enviando archivo db.env a la instancia EC2..."
scp -i vockey.pem db.env ec2-user@$EC2_IP:/home/ec2-user/db.env

echo "✅ Archivo enviado con éxito. Ahora corre ec2-setup.sh en tu instancia EC2."
