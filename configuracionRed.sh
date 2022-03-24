#!/bin/bash

# Script para que el administrador haga toda la configuración de la máquina desde 0
# Con este script configuramos la red, los usuarios, instalamos docker, lo configuramos
# con namespaces, lo recargamos y está listo para funcionar

# Primero configuramos la red

echo “Comenzamos, configurando la red…”

# Creamos un backup del archivo primero

cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bk_`date +%Y%m%d%H%M`

# Desactivamos el dhcp

sed -i "s/dhcp4: yes/dhcp4: no/g" /etc/netplan/01-netcfg.yaml

# Obtenemos la informacion de la tarjeta de red

nic=`ip addr | awk 'NR==7{print $2}'`

# Pedimos por teclado la configuracion de red

read -p "Introduce la direccion IP estatica en formato CIDR, ejemplo: 192.168.2.20/22: " staticip 
read -p "Introduce la IP de la puerta de enlace: " gatewayip
read -p "Introduce la IP de los DNS (separados por comas si es mas de uno, ej: 8.8.8.8,8.8.4.4): " nameserversip
echo
cat > /etc/netplan/01-netcfg.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic
      addresses:
        - $staticip
      gateway4: $gatewayip
      nameservers:
          addresses: [$nameserversip]
EOF
sudo netplan apply
echo “-----------------”
echo “La configuracion de red se aplico correctamente”
echo “-----------------”
