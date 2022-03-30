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
