provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc_virginia" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC - Proyecto"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw-virginia" {
  vpc_id = aws_vpc.vpc_virginia.id
  tags = {
    Name = "IGW - Proyecto"
  }
}

# Elastic IPs
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "Elastic IP para NAT Gateway"
  }
}

resource "aws_eip" "eip_web" {
  domain = "vpc"
  tags = {
    Name = "Elastic IP para Instancia Web"
  }
}

resource "aws_eip_association" "asociacion_web" {
  instance_id   = aws_instance.instancia_WebVirginia.id
  allocation_id = aws_eip.eip_web.id
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subred_publica_virginia_Web.id
  tags = {
    Name = "NAT Gateway - Proyecto"
  }
}

# Subredes
resource "aws_subnet" "subred_publica_virginia_Web" {
  vpc_id                  = aws_vpc.vpc_virginia.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subred Publica Web - Proyecto"
  }
}

resource "aws_subnet" "subred_privada_virginia_BD" {
  vpc_id            = aws_vpc.vpc_virginia.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "Subred Privada BD - Proyecto"
  }
}

resource "aws_subnet" "subred_privada_virginia_BD2" {
  vpc_id            = aws_vpc.vpc_virginia.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "Subred Privada BD2 - Proyecto"
  }
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [
    aws_subnet.subred_privada_virginia_BD.id,
    aws_subnet.subred_privada_virginia_BD2.id
  ]
  tags = {
    Name = "Grupo de subred BD - Proyecto"
  }
}

# Tablas de rutas
resource "aws_route_table" "tabla_rutas_virginia" {
  vpc_id = aws_vpc.vpc_virginia.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-virginia.id
  }
  tags = {
    Name = "Tabla Rutas Virginia"
  }
}

resource "aws_route_table" "tabla_rutas_privadas" {
  vpc_id = aws_vpc.vpc_virginia.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "Tabla Rutas Privadas con NAT"
  }
}

# Asociaciones de rutas
resource "aws_route_table_association" "publica_virginia_Web" {
  subnet_id      = aws_subnet.subred_publica_virginia_Web.id
  route_table_id = aws_route_table.tabla_rutas_virginia.id
}

resource "aws_route_table_association" "privada_virginia_BD" {
  subnet_id      = aws_subnet.subred_privada_virginia_BD.id
  route_table_id = aws_route_table.tabla_rutas_privadas.id
}

resource "aws_route_table_association" "privada_virginia_BD2" {
  subnet_id      = aws_subnet.subred_privada_virginia_BD2.id
  route_table_id = aws_route_table.tabla_rutas_privadas.id
}

# Security Group Web
resource "aws_security_group" "SG-WebVirginia" {
  vpc_id = aws_vpc.vpc_virginia.id
  name   = "SG-Proyecto-Web"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group Base de Datos - CORREGIDO
resource "aws_security_group" "SG-BD" {
  vpc_id = aws_vpc.vpc_virginia.id
  name   = "SG-BaseDeDatos"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-WebVirginia.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG Base de Datos - Proyecto"
  }
}

# EC2 Instancia Web
resource "aws_instance" "instancia_WebVirginia" {
  ami                         = "ami-0f88e80871fd81e91"
  instance_type               = "t2.large"
  subnet_id                   = aws_subnet.subred_publica_virginia_Web.id
  key_name                    = "vockey"
  vpc_security_group_ids      = [aws_security_group.SG-WebVirginia.id]
  associate_public_ip_address = true

  tags = {
    Name = "Linux Web - Proyecto"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              echo "🟡 Iniciando configuración de instancia EC2..." >> /var/log/userdata.log
              yum update -y >> /var/log/userdata.log
              yum install -y docker git >> /var/log/userdata.log
              service docker start
              systemctl enable docker
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              cd /home/ec2-user
              if [ ! -d "proyecto-final-fddo" ]; then
                git clone https://github.com/pedrodeleondev/proyecto-final-fddo.git >> /var/log/userdata.log
              fi
              cd proyecto-final-fddo/aplicacionWeb
              echo "DB_HOST=${replace(aws_db_instance.BD_MySQL.endpoint, ":3306", "")}" > db.env
              echo "DB_USER=admin" >> db.env
              echo "DB_PASSWORD=proyecto98765" >> db.env
              echo "DB_NAME=proyecto_db" >> db.env
              docker-compose down --volumes --remove-orphans || true
              docker-compose up -d --build >> /var/log/userdata.log
              echo "✅ Aplicación desplegada correctamente." >> /var/log/userdata.log
              EOF
}

# Base de Datos RDS
resource "aws_db_instance" "BD_MySQL" {
  identifier               = "bd-proyect-mysql"
  engine                   = "mysql"
  engine_version           = "8.0"
  instance_class           = "db.t3.micro"
  allocated_storage        = 20
  storage_type             = "gp2"
  username                 = "admin"
  password                 = "proyecto98765"
  db_name                  = "proyecto_db"
  db_subnet_group_name     = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.SG-BD.id]
  multi_az                 = false
  publicly_accessible      = false
  skip_final_snapshot      = true

  tags = {
    Name = "RDS MySQL - Proyecto"
  }
}

# Outputs
output "rds_endpoint" {
  description = "Endpoint DNS para conectar a la RDS"
  value       = aws_db_instance.BD_MySQL.endpoint
}

output "rds_port" {
  description = "Puerto de conexión de MySQL"
  value       = aws_db_instance.BD_MySQL.port
}

output "rds_username" {
  description = "Usuario administrador de MySQL"
  value       = aws_db_instance.BD_MySQL.username
}

output "rds_database_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.BD_MySQL.db_name
}
