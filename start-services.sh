#!/bin/bash

# Homelab service bootstrapper

echo "=== Initializing Homelab Services ==="
#run copy-config.sh
copy_config=$(find / -type f -name "copy-config.sh" 2>/dev/null | head -n 1)
if [ -z "$copy_config" ]; then
    echo "[!] 'copy-config.sh' not found. Aborting."
    exit 1
fi
chmod +x "$copy_config"
bash "$copy_config"


echo "[*] Searching for 'homelab-network.sh'..."

# Locate the homelab network setup script
NETWORK_SCRIPT=$(find / -type f -name "homelab-network.sh" 2>/dev/null | head -n 1)
if [ -z "$NETWORK_SCRIPT" ]; then
    echo "[!] 'homelab-network.sh' not found. Aborting."
    exit 1
fi

chmod +x "$NETWORK_SCRIPT"

#if network is already created, skip
if docker network ls --format '{{.Name}}' | grep -wq "homelab-network"; then
    echo "[+] Docker network 'homelab-network' already exists. Skipping creation."
else
    echo "[+] Creating Docker network 'homelab-network'..."
    bash "$NETWORK_SCRIPT"
    if [ $? -ne 0 ]; then
        echo "[!] Network creation failed. Aborting."
        exit 1
    fi
fi
if [ $? -ne 0 ]; then
    echo "[!] Network setup failed. Aborting."
    exit 1
fi

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
echo "Active Docker Containers:"
docker ps

echo ""
echo "✔️ Homelab Startup Complete"
