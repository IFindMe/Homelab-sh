#!/bin/bash

NGINX_CONF_DIR="/srv/docker/nginx/etc/nginx/conf.d"
SSL_CERT="/etc/nginx/conf.d/keys/nginx.crt"
SSL_KEY="/etc/nginx/conf.d/keys/nginx.key"


docker ps --format '{{.ID}} {{.Names}}' | while read -r CONTAINER_ID CONTAINER_NAME; do
    CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_ID")
    CONTAINER_PORT=$(docker port "$CONTAINER_ID" | head -n1 | cut -d':' -f2)

    if [[ -z "$CONTAINER_IP" || -z "$CONTAINER_PORT" ]]; then
        echo "Skipping $CONTAINER_NAME – missing IP or port."
        continue
    fi

    CONF_PATH="$NGINX_CONF_DIR/$CONTAINER_NAME.conf"
    cat > "$CONF_PATH" <<EOF
server {
    listen 443 ssl;
    server_name $CONTAINER_NAME.home.net;

    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;

    location / {
        proxy_pass http://$CONTAINER_IP:$CONTAINER_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}

server {
    listen 80;
    server_name $CONTAINER_NAME.home.net;

    return 301 https://\$host\$request_uri;
}
EOF

    echo "Generated config for $CONTAINER_NAME at $CONF_PATH"
done

nginx -s reload
