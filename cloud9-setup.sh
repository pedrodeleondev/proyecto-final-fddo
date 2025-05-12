#!/bin/bash

set -e

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$BASE_DIR"

echo "🔧 Instalando Terraform 1.6.6 en /tmp..."
cd /tmp
wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip -o terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -version || { echo "❌ Terraform no se instaló correctamente."; exit 1; }

cd "$BASE_DIR"

# Verificar que el script se está ejecutando desde dentro del repositorio
if [ ! -d "./infraestructuraTF-AWS" ]; then
  echo "❌ Error: No se encuentra la carpeta infraestructuraTF-AWS. Asegúrate de estar en el repositorio correcto."
  exit 1
fi

echo "🚀 Ejecutando Terraform en infraestructuraTF-AWS..."
cd infraestructuraTF-AWS
terraform init -input=false
terraform plan -input=false -out=tfplan
terraform apply -auto-approve tfplan
rm -rf .terraform tfplan

echo "✅ Infraestructura creada con éxito."

echo ""
echo "📤 Extrayendo datos de RDS..."
DB_HOST=$(terraform output -raw rds_endpoint | cut -d':' -f1)
DB_USER=$(terraform output -raw rds_username)
DB_NAME=$(terraform output -raw rds_database_name)
DB_PASSWORD="proyecto98765"  # Asegúrate que coincida con main.tf

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_NAME" ]]; then
  echo "❌ Error al obtener los datos de conexión. Revisa los outputs de Terraform."
  exit 1
fi

echo ""
echo "📤 Datos de conexión a la base de datos:"
echo "HOST: $DB_HOST"
echo "USER: $DB_USER"
echo "DB:   $DB_NAME"
echo "PASS: $DB_PASSWORD"

echo ""
echo "✅ Todo listo. La instancia EC2 se encargará del resto automáticamente."
