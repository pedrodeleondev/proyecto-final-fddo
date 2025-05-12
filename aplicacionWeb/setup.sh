#!/bin/bash

# Salir al primer error
set -e

echo "Actualizando sistema..."
sudo yum update -y

echo "Instalando Git..."
sudo yum install git -y

echo "Instalando Python y pip..."
sudo yum install python3 -y

# Asegurarse de que pip esté instalado
if ! command -v pip3 &> /dev/null
then
    echo "pip3 no encontrado. Instalando..."
    sudo yum install python3-pip -y
fi

# Asegurar que pip está actualizado
echo "Actualizando pip..."
python3 -m pip install --upgrade pip --user

echo "Instalando Docker..."
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

echo "Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.4/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Clonando el repositorio si no existe..."
cd /home/ec2-user
if [ ! -d "proyecto-final-fddo" ]; then
    git clone https://github.com/tu_usuario/proyecto-final-fddo.git
fi

cd proyecto-final-fddo/aplicacionWeb

echo "Levantando contenedores con Docker Compose..."
sudo docker-compose up -d

echo "La aplicación está en marcha. Accede con tu IP pública en el puerto 5000"
