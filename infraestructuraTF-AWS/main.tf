#Proveedor de nube
provider "aws" {
  region = "us-east-1"
}

#VPC Proyecto Final
resource "aws_vpc" "vpc_virginia" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC - Proyecto"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw-virginia" {
  vpc_id = aws_vpc.vpc_virginia.id
  tags = {
    Name = "IGW - Proyecto"
  }
}

#Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "Elastic IP para NAT Gateway"
  }
}

# Elastic IP para Web
resource "aws_eip" "eip_web" {
  vpc = true
  tags = {
    Name = "Elastic IP para Instancia Web"
  }
}

# Asociación de Elastic IP con la instancia
resource "aws_eip_association" "asociacion_web" {
  instance_id   = aws_instance.instancia_WebVirginia.id
  allocation_id = aws_eip.eip_web.id
}

#NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subred_publica_virginia_Web.id
  tags = {
    Name = "NAT Gateway - Proyecto"
  }
}

#Subred Publica Web
resource "aws_subnet" "subred_publica_virginia_Web" {
  vpc_id                  = aws_vpc.vpc_virginia.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subred Publica Web - Proyecto"
  }
}

#Subred Privada BaseDatos
resource "aws_subnet" "subred_privada_virginia_BD" {
  vpc_id            = aws_vpc.vpc_virginia.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "Subred Privada BD - Proyecto"
  }
}
resource "aws_subnet" "subred_privada_virginia_BD2" {
  vpc_id                  = aws_vpc.vpc_virginia.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1d"
  tags = {
    Name = "Subred Privada BD2 - Proyecto"
  }
}

#Grupo de subred RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.subred_privada_virginia_BD.id, aws_subnet.subred_privada_virginia_BD2.id]
  tags = {
    Name = "Grupo de subred BD - Proyecto"
  }
}

#Tabla de rutas Pública
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

#Tabla de rutas Privadas
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

#Asociaciones de tabla de rutas
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

#Grupo de Seguridad Web
resource "aws_security_group" "SG-WebVirginia" {
  vpc_id = aws_vpc.vpc_virginia.id
  name = "SG-Proyecto-Web"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security Group BaseDeDatos
resource "aws_security_group" "SG-BD" {
  vpc_id = aws_vpc.vpc_virginia.id
  name   = "SG-BaseDeDatos"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [format("%s/32", aws_instance.instancia_WebVirginia.private_ip)]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Instancia Web
resource "aws_instance" "instancia_WebVirginia" {
  ami = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subred_publica_virginia_Web.id
  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.SG-WebVirginia.id]
  associate_public_ip_address = true
  tags = {
    Name = "Linux Web - Proyecto"
  }
}

#Base de Datos
resource "aws_db_instance" "BD_MySQL" {
  identifier = "bd-proyect-mysql"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  username = "admin"
  password = "proyecto98765"
  db_name = "proyecto_db"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.SG-BD.id]
  multi_az = false
  publicly_accessible = false
  skip_final_snapshot = true
  tags = {
    Name = "RDS MySQL - Proyecto"
  }
}

#Outputs 
output "rds_endpoint" {
  description = "Endpoint DNS para conectar a la RDS"
  value = aws_db_instance.BD_MySQL.endpoint
}
output "rds_port" {
  description = "Puerto de conexión de MySQL"
  value = aws_db_instance.BD_MySQL.port
}
output "rds_username" {
  description = "Usuario administrador de MySQL"
  value = aws_db_instance.BD_MySQL.username
}
output "rds_database_name" {
  description = "Nombre de la base de datos"
  value = aws_db_instance.BD_MySQL.db_name
}
