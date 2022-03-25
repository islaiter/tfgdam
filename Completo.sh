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

# Creamos los usuarios, con contraseña

echo “Creando usuarios…”

# Creando los usuarios con useradd en vez de con adduser crea los usuarios para que sean compatibles con Samba por si hiciese falta por lo que sea, que lo dudo

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

echo “Usuarios creados correctamente”

# Ahora queremos instalar docker

echo “Instalando docker…”

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

echo “Docker instalado correctamente”

# Ahora queremos configurar el namespace para distintos sockets

“Empezando a configurar la seguridad de docker…”

“Configurando el archivo sudoers…”

# echo 'foobar ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo

echo 'maniana ALL=(ALL:ALL) NOPASSWD: /usr/bin/docker -H unix\:///var/run/docker-maniana.sock *, ! /usr/bin/docker *--priviledged*, ! /usr/bin/docker *host*' | sudo EDITOR='tee -a' visudo
echo 'tarde ALL=(ALL:ALL) NOPASSWD: /usr/bin/docker -H unix\:///var/run/docker-tarde.sock *, ! /usr/bin/docker *--priviledged*, ! /usr/bin/docker *host*' | sudo EDITOR='tee -a' visudo
echo 'maniana ALL=(ALL:ALL) NOPASSWD: /usr/bin/docker-compose -H unix\:///var/run/docker-maniana.sock * *' | sudo EDITOR='tee -a' visudo
echo 'tarde ALL=(ALL:ALL) NOPASSWD: /usr/bin/docker-compose -H unix\:///var/run/docker-tarde.sock * *' | sudo EDITOR='tee -a' visudo

# Esto hay que automatizarlo
# Para obtener el id de un usuario: echo $(sudo id -u usuario)
# Para obtener el grupo de un usuario: echo $(sudo id -g usuario)

echo “Archivo sudoers configurado correctamente”

echo “Configurando el archivo subuid…”


#echo “maniana:165536:65536” >> /etc/subuid
#echo “tarde:231072:65536” >> /etc/subuid

echo "maniana:$(sudo id -g maniana):1" | sudo tee -a /etc/subuid
echo "tarde:$(sudo id -g tarde):1" | sudo tee -a /etc/subuid


echo “subuid configurado correctamente”

echo “Configurando el archivo subgid…”

#echo “maniana:165536:65536” >> /etc/subgid 
#echo “tarde:231072:65536” >> /etc/subgid

echo "maniana:$(sudo id -g maniana):1" | sudo tee -a /etc/subgid
echo "tarde:$(sudo id -g tarde):1" | sudo tee -a /etc/subgid

echo “subgid configurado correctamente”
echo “Creando y configurando archivo para el socket de docker…”

touch /etc/systemd/system/docker@.service

cat > etc/systemd/system/docker@.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker-containerd.service
Wants=docker-storage-setup.service
Requires=docker-containerd.service rhel-push-plugin.socket registries.service

[Service]
Type=notify
EnvironmentFile=/run/containers/registries.conf
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
Environment=GOTRACEBACK=crash
ExecStart=/usr/bin/dockerd-current \
          --add-runtime oci=/usr/libexec/docker/docker-runc-current \
          --default-runtime=oci \
          --authorization-plugin=rhel-push-plugin \
          --containerd /run/containerd.sock \
          --exec-opt native.cgroupdriver=systemd \
          --userland-proxy-path=/usr/libexec/docker/docker-proxy-current \
          --init-path=/usr/libexec/docker/docker-init-current \
          --seccomp-profile=/etc/docker/seccomp.json \
          --userns-remap %i \
          --host unix:///var/run/docker-%i.sock \
          --pidfile /var/run/docker-%i.pid \
          $OPTIONS \
          $DOCKER_STORAGE_OPTIONS \
          $DOCKER_NETWORK_OPTIONS \
          $ADD_REGISTRY \
          $BLOCK_REGISTRY \
          $INSECURE_REGISTRY \
          $REGISTRIES
ExecReload=/bin/kill -s HUP $MAINPID
TasksMax=8192
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TimeoutStartSec=0
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

echo “Archivo de socket docker rellenado correctamente”

echo “Aplicando cambio a dockerd”

systemctl daemon-reload
systemctl restart docker

echo “Cambios aplicados con exito”

echo “Configurando el archivo bashrc…”

echo “alias docker="sudo docker -H unix:///var/run/docker-$(whoami).sock"” >> ~/.bashrc

source ~/.bashrc

echo “Archivo bashrc configurado correctamente”

# systemctl start docker@USER.service → no es necesario de momento

echo “Ya hemos terminado de configurar todo”
