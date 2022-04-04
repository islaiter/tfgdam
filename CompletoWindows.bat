:: Script que automatizara toda la infrasestructura del proyecto para Windows

:: Creamos los usuarios maniana y tarde con las contraseñas correspondientes

REM Creando los usuarios

net user maniana maniana1234 /ADD
net user maniana tarde1234 /ADD

:: Mostramos las cuentas ya creadas para comprobar que todo esta correcto

wmic useraccount get name
