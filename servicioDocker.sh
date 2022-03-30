ExecStart=/usr/bin/dockerd --host unix:///var/run/docker.sock --pidfile /var/run/docker.pid
ExecStart=/usr/bin/dockerd --userns-remap maniana --host unix:///var/run/docker-maniana.sock --pidfile /var/run/docker-maniana.pid
ExecStart=/usr/bin/dockerd --userns-remap tarde --host unix:///var/run/docker-tarde.sock --pidfile /var/run/docker-tarde.pid

sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.copy

sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker-maniana.service

sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker-tarde.service

ExecStart=/usr/bin/dockerd \
          --host unix:///var/run/docker.sock \
          --pidfile /var/run/docker.pid \
          

ExecStart=/usr/bin/dockerd \
          --userns-remap maniana \
          --host unix:///var/run/docker-maniana.sock \
          --pidfile /var/run/docker-maniana.pid \
        
ExecStart=/usr/bin/dockerd \
          --userns-remap tarde \
          --host unix:///var/run/docker-tarde.sock \
          --pidfile /var/run/docker-tarde.pid \

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
          --pidfile /var/run/docker.pid \

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
