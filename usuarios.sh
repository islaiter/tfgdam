#!/bin/bash
sudo useradd -m -p maniana1234 maniana
sudo useradd -m -p tarde1234 tarde

# Le asignamos contraseña en linux, ya que los creamos compatibles con samba

sudo echo "maniana:maniana1234" | sudo chpasswd
sudo echo "tarde:tarde1234" | sudo chpasswd

sudo chsh -s /bin/bash maniana
sudo chsh -s /bin/bash tarde

# Añadimos los usuarios al grupo docker para que ejecuten comandos

sudo gpasswd -a maniana docker
sudo gpasswd -a tarde docker
