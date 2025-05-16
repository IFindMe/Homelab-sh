#!/bin/bash

CONF_DIR="/srv/docker/nginx/etc/nginx/conf.d"

read -p "Enter server name (e.g., myapp): " NAME
read -p "Enter backend IP: " IP
read -p "Enter backend port: " PORT

CONF_PATH="$CONF_DIR/$NAME.conf"

mkdir -p "$CONF_DIR"

cat > "$CONF_PATH" <<EOF
server {
    listen 443 ssl;
    server_name $NAME.home.net;

    ssl_certificate /etc/nginx/conf.d/keys/nginx.crt;
    ssl_certificate_key /etc/nginx/conf.d/keys/nginx.key;

    location / {
        proxy_pass http://$IP:$PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}

server {
    listen 80;
    server_name $NAME.home.net;

    return 301 https://\$host\$request_uri;
}
EOF

echo "✅ Config written to $CONF_PATH"
