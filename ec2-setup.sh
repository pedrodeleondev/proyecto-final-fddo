#!/bin/bash

# Salir al primer error
set -e

echo "🔄 Actualizando sistema..."
sudo yum update -y

echo "🔧 Instalando Git..."
sudo yum install git -y

echo "🐍 Instalando Python y pip..."
sudo yum install python3 -y
python3 -m pip install --upgrade --user pip

echo "🐳 Instalando Docker..."
sudo yum install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

echo "🔧 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.4/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "📦 Clonando el repositorio..."
cd /home/ec2-user
git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git || true
cd proyecto-final-fddo/aplicacionWeb

echo "✅ Levantando contenedores con Docker Compose..."
sudo docker-compose up -d

echo "🎉 La aplicación está en marcha. Accede con tu IP pública en el puerto 5000"
