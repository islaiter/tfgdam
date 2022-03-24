#!/bin/bash

sudo useradd -m -p maniana1234 maniana
sudo useradd -m -p tarde1234 tarde

# Como los creamos para samba, le asignamos una contraseña en linux

sudo echo "maniana:maniana1234" | sudo chpasswd
sudo echo "tarde:tarde1234" | sudo chpasswd

# Ahora les tenemos que asignar una shell en linux

sudo chsh -s /bin/bash maniana
sudo chsh -s /bin/bash tarde
