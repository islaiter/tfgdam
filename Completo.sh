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

# Comando para cambiar los permisos por defecto cuando se crea un usuario, de 755 a 700 para que el resto de 
#usuarios no se puedan meter en el directorio personal de otros usuarios

sudo sed -i "s/DIR_MODE=0755/DIR_MODE=0700/g" /etc/adduser.conf

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

sudo chmod 700 -R /home/maniana
sudo chmod 700 -R /home/tarde

# Configurando xhost para que funcione cuando se bootea el SO

echo "xhost +" | sudo tee -a /etc/profile

echo “Usuarios creados correctamente”

# Ahora queremos instalar docker

echo “Instalando docker…”

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo “Docker instalado correctamente”

# Ahora queremos configurar el namespace para distintos sockets

“Configurando la seguridad de docker…”

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
echo “Creando y configurando archivos para los sockets de docker”

#
sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.copy
touch /lib/systemd/system/docker-maniana.service
touch /lib/systemd/system/docker-tarde.service

cat > /lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
#ExecStart=
#ExecStart=/usr/bin/dockerd
ExecStart=/usr/bin/dockerd \
          --host unix:///var/run/docker.sock \
          --pidfile /var/run/docker.pid
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3
# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500
[Install]
WantedBy=multi-user.target
EOF

echo "Docker prueba"

cat > /lib/systemd/system/docker-maniana.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
#ExecStart=
#ExecStart=/usr/bin/dockerd
ExecStart=/usr/bin/dockerd \
          --userns-remap maniana \
          --host unix:///var/run/docker-maniana.sock \
          --pidfile /var/run/docker-maniana.pid
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3
# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500
[Install]
WantedBy=multi-user.target
EOF

cat > /lib/systemd/system/docker-tarde.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
#ExecStart=
#ExecStart=/usr/bin/dockerd
ExecStart=/usr/bin/dockerd \
          --userns-remap tarde \
          --host unix:///var/run/docker-tarde.sock \
          --pidfile /var/run/docker-tarde.pid
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3
# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500
[Install]
WantedBy=multi-user.target
EOF
echo "Archivos de sockets para docker configurados correctamente"

echo “Aplicando cambio a dockerd”

systemctl daemon-reload
systemctl restart docker

echo “Cambios aplicados con exito”

echo “Configurando el archivo bashrc…”

cat >> /home/maniana/.bashrc <<EOF
alias docker="sudo docker -H unix:///var/run/docker-maniana.sock"
EOF

cat >> /home/tarde/.bashrc <<EOF
alias docker="sudo docker -H unix:///var/run/docker-tarde.sock"
EOF

echo “Archivo bashrc configurado correctamente”

echo “Automatizando los servicios para que se ejecuten al iniciarse la maquina”

systemctl enable docker-maniana
systemctl enable docker-tarde
systemctl start docker-maniana
systemctl start docker-tarde

echo “Servicios automatizados correctamente”

echo “Dando permisos a la carpeta de directorios de docker”
chmod 755 /var/lib/docker
echo “Permisos de docker configurados correctamente”

echo “Instalador Docker compose”
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo “Docker compose instalado correctamente”

echo “Ya hemos terminado de configurar todo”
