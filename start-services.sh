#!/bin/bash

# Homelab service bootstrapper

echo "=== Initializing Homelab Services ==="



# Check if /srv/docker/nginx/etc/nginx/conf.d exists
if [ ! -d "/srv/docker/nginx/etc/nginx/conf.d" ]; then
    echo "[!] Directory '/srv/docker/nginx/etc/nginx/conf.d' not found."
    #run copy-config.sh
    copy_config=$(find / -type f -name "copy-config.sh" 2>/dev/null | head -n 1)
    if [ -z "$copy_config" ]; then
        echo "[!] 'copy-config.sh' not found. Aborting."
        exit 1
    fi
    chmod +x "$copy_config"
    bash "$copy_config"
fi


echo "[*] Searching for 'homelab-network.sh'..."

# Check if homelab-network in docker exists
if docker network ls --format '{{.Name}}' | grep -wq "homelab-network"; then
    echo "[+] Docker network 'homelab-network' already exists."
else
    echo "[!] Docker network 'homelab-network' not found."
    # Locate the homelab network setup script
    NETWORK_SCRIPT=$(find / -type f -name "homelab-network.sh" 2>/dev/null | head -n 1)
    if [ -z "$NETWORK_SCRIPT" ]; then
        echo "[!] 'homelab-network.sh' not found. Aborting."
        exit 1
    fi
fi
chmod +x "$NETWORK_SCRIPT"

    echo "[+] Creating Docker network 'homelab-network'..."
    bash "$NETWORK_SCRIPT"

echo "[+] Network initialized."

# Locate service scripts
echo "[*] Searching for service scripts (srv-*.sh)..."
SERVICE_SCRIPTS=$(find / -type f -name "srv-*.sh" 2>/dev/null)
SCRIPT_COUNT=$(echo "$SERVICE_SCRIPTS" | wc -l)

if [ -z "$SERVICE_SCRIPTS" ]; then
    echo "[!] No service scripts found. Aborting."
    exit 1
fi

echo "[+] Found $SCRIPT_COUNT service script(s). Launching..."

# Make service scripts executable
for script in $SERVICE_SCRIPTS; do
    chmod +x "$script"
done

# Execute each service script
for script in $SERVICE_SCRIPTS; do
    echo ""
    echo ">>> Ready to execute: $script"
    read -p "Proceed with this service? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        bash "$script"
    else
        echo "Skipped: $script"
        continue
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Success: $script"
    else
        echo "❌ Failure: $script (Exit Code $?)"
    fi
done

echo ""
echo "=== All Services Launched ==="

#ask if user wants to set pihole password if pihole name is found in the list "SERVICE_SCRIPTS"
if echo "$SERVICE_SCRIPTS" | grep -q "pihole"; then
    echo "[*] Pi-hole service detected."
    read -p "Do you want to set the Pi-hole admin password? [y/N]: " set_pihole_pass
    if [[ "$set_pihole_pass" =~ ^[Yy]$ ]]; then
        # Locate the Pi-hole password script
        PIHOLE_SCRIPT=$(find / -type f -name "change-pihole-password.sh" 2>/dev/null | head -n 1)
        if [ -z "$PIHOLE_SCRIPT" ]; then
            echo "[!] 'change-pihole-password.sh' not found. Aborting."
            exit 1
        fi

        chmod +x "$PIHOLE_SCRIPT"
        
        # Execute the Pi-hole password script
        bash "$PIHOLE_SCRIPT"
    else
        echo "Skipped setting Pi-hole password."
    fi
else
    echo "No Pi-hole service detected."
fi
echo ""

#ask user if they want to build nginx configs
read -p "Do you want to build nginx configs? [y/N]: " build_nginx
if [[ "$build_nginx" =~ ^[Yy]$ ]]; then
    # Locate the nginx config script
    NGINX_SCRIPT=$(find / -type f -name "generate_nginx_configs.sh" 2>/dev/null | head -n 1)
    if [ -z "$NGINX_SCRIPT" ]; then
        echo "[!] 'generate_nginx_configs.sh' not found. Aborting."
        exit 1
    fi

    chmod +x "$NGINX_SCRIPT"
    
    # Execute the nginx config script
    bash "$NGINX_SCRIPT"
else
    echo "Skipped nginx config generation."
fi
echo ""

#ask user if they want to startup with tailscale
read -p "Do you want to start Tailscale and set up a MagicDNS search domain (home.net) pointing to your nginx subnet IP? [y/N]: " start_tailscale
if [[ "$start_tailscale" =~ ^[Yy]$ ]]; then
    # Locate the Tailscale startup script
    TAILSCALE_SCRIPT=$(find / -type f -name "tailscale-setup.sh" 2>/dev/null | head -n 1)
    if [ -z "$TAILSCALE_SCRIPT" ]; then
        echo "[!] 'start-tailscale.sh' not found. Aborting."
        exit 1
    fi

    chmod +x "$TAILSCALE_SCRIPT"
    
    # Execute the Tailscale startup script
    bash "$TAILSCALE_SCRIPT"
else
    echo "Skipped Tailscale startup."
fi

echo "✔️ Homelab Startup Complete"
