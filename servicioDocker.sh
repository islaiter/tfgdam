ExecStart=/usr/bin/dockerd --host unix:///var/run/docker.sock --pidfile /var/run/docker.pid
ExecStart=/usr/bin/dockerd --userns-remap maniana --host unix:///var/run/docker-maniana.sock --pidfile /var/run/docker-maniana.pid
ExecStart=/usr/bin/dockerd --userns-remap tarde --host unix:///var/run/docker-tarde.sock --pidfile /var/run/docker-tarde.pid

sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.copy

sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker-maniana.service

sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker-tarde.service

sed -i "s/ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock/ExecStart=/usr/bin/dockerd --host unix:///var/run/docker.sock --pidfile /var/run/docker.pid" /lib/systemd/system/docker.service

sed -i "s/ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock/ExecStart=/usr/bin/dockerd --userns-remap maniana --host unix:///var/run/docker-maniana.sock --pidfile /var/run/docker-maniana.pid" /lib/systemd/system/docker-maniana.service

sed -i "s/ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock/ExecStart=/usr/bin/dockerd --userns-remap tarde --host unix:///var/run/docker-tarde.sock --pidfile /var/run/docker-tarde.pid " /lib/systemd/system/docker-tarde.service
