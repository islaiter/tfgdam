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
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
EOF
