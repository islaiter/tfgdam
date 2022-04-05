:: Script que automatizara toda la infrasestructura del proyecto para Windows

:: Creamos los usuarios maniana y tarde con las contraseñas correspondientes

REM Creando los usuarios

net user maniana maniana1234 /ADD
net user maniana tarde1234 /ADD

:: Mostramos las cuentas ya creadas para comprobar que todo esta correcto

wmic useraccount get name

:: Queremos ahora descargar y actualizar Windows

UsoClient ScanInstallWait

:: Queremos ahora por powershell instalar el modulo de las actualizaciones de Windows

powershell -Command "& {Install-Module PSWindowsUpdate}"

:: Eliminamos la necesidad de la configuracion por defecto de explorer, para que no fallen los comandos despues

powershell -Command "& {Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main' -Name "DisableFirstRunCustomize" -Value 2}"

:: Añadimos la descarga de winget para obtener aplicaciones de windows store

powershell -Command "& {Start-BitsTransfer -Source 'https://github.com/microsoft/winget-cli/releases/download/v1.2.10271/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'  -Destination "C:\Users\admin\Desktop\winget.msixbundle";}"

:: Instalamos Ubuntu con winget

powershell -Command "& {Winget Install Ubuntu}"
