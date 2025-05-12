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
Primero que nada, hay que crear un Cloud9 completamente nuevo, que no tenga nada instalado anteriormente. 

1.- Primero, tienes que abrir el Cloud9 que creasye y en la terminal ingresas el siguiente comando "_**git clone https://github.com/pedrodeleondev/proyecto-final-fddo**_".

2.- Posteriormente hay que dirigirse a la carpeta con el comando "_**cd proyecto-final-fddo**_".

3.- Ejecutas el comando "_**chmod +x cloud9-setup.sh**_", para darle permisos al archivo "_**cloud9-setup.sh**_".

4.- Por último, debes ejecutar el archivo "_**cloud9-setup.sh**_" con el comando "_**./cloud9-setup.sh**_".

Solo hará falta verificar cual es la IP pública de la instancia que se creo para entrar en la página web. De esta manera se habra instalado Terraform y Docker de manera automática.
