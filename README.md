# Proyecto final para Fundamentos de DevOps
Proyecto de tienda en línea de audífonos. El sitio web será desplegado en AWS utilizando servicios como EC2 y VPC, con la infraestructura definida mediante Terraform. Este repositorio contiene el código necesario para automatizar el aprovisionamiento de recursos en la nube y facilitar el despliegue del sitio.

## Integrantes del equipo
- [Pedro Francisco De León Salazar](https://github.com/pedrodeleondev) - **INGENIERO DE SOFTWARE**
- [Frida Sarahi Garza Galvez](https://github.com/FridaGarzaG) - **INGENIERA DE INFRAESTRUCTURA**
- [Paola Guadalupe Urdiales Luna](https://github.com/PaolaUrdiales) - **INGENIERA DE QA / IMPLEMENTACIÓN**

## Infraestructura AWS
Diagrama generado en Lucid, plataforma que nos facilita el generar diagramas para este tipo de proyectos, en ese diagrama podremos obtener de forma visual la distribución de instancias, VPC, grupos de seguridad y base de datos que nos son relevantes para la funcionalidad del proyecto.
- [Link de diagrama en Lucid](https://lucid.app/lucidchart/a0f93e7d-2e5d-4ecd-a80a-d849d5a7e55e/edit?viewport_loc=-1905%2C-660%2C2270%2C1346%2C0_0&invitationId=inv_ee29050c-9381-48f5-ad0d-21d71866cd73)

## Diseño de pagina
Se manejo un diseño por parte de nuestra integrante Paola Urdiales, en donde nos dio una muestra del diseño que se espera ofrezca nuestra pagina, dando asi diseños para las paginas de Inicio, Compras, Login, Registro y Carrito, pueden ver estos diseños en el siguiente link:
- [Link de diseños en Figma](https://www.figma.com/design/C5JObP2Vf4ttap1RI5ZaEo/Proyecto-Final_DevOps?node-id=13-201&t=Y6E3B1TAePUo9xeh-1)

## Pasos para instalar nuestro proyecto mediante Cloud9
Primero que nada, hay que crear un Cloud9 completamente nuevo, donde únicamente esté instalado Terraform. 

1.- Primero, tienes que abrir el Cloud9 que creaste y en la terminal ingresas el siguiente comando "_**git clone https://github.com/pedrodeleondev/proyecto-final-fddo**_".

2.- Posteriormente hay que dirigirse a la carpeta con el comando "_**cd proyecto-final-fddo**_", para despues ingresar el comando "_**cd infraestructuraTF-AWS**_".

3.- Debes ejecutar la secuencia de codigos: "_**terraform init - terraform plan - terraform apply**_".


4.- Cuando la infraestructura esté lista, te debes conectar a la instancia creada, para volver a clonar el repositorio hay que instalar git con el comando _*sudo yum install -y git*_, clonas el repositorio y entras de nuevo a la carpeta del repositorio, una vez dentro te debes dirigir a la carpeta _**aplicacionWeb**_.

5.- Por último, ejecutas el comando "_**chmod +x setup.sh**_" y posteriormente ejecutas el comando "_**./setup.sh**_".

6.- Ya está todo trabajando de manera correcta, para entrar a la página debes poner en el navegador: ip_de_la_instancia:5000.
