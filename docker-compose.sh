#!/bin/bash

cat /lib/systemd/system/docker-compose.yml
cat /lib/systemd/system/docker-compose-dam.yml
cat /lib/systemd/system/docker-compose-daw.yml

cat > /lib/systemd/system/docker.service <<EOF
[Unit]
Description=service with docker compose
PartOf=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/local/bin/docker-compose up 
ExecStart=/usr/bin/dockerd \
          --host unix:///var/run/docker.sock \
          --pidfile /var/run/docker.pid

[Install]
WantedBy=multi-user.target
EOF
