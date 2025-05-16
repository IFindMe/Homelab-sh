#!/bin/bash

# Homelab service bootstrapper

echo "=== Initializing Homelab Services ==="
echo "[*] Searching for 'homelab-network.sh'..."

# Locate the homelab network setup script
NETWORK_SCRIPT=$(find / -type f -name "homelab-network.sh" 2>/dev/null | head -n 1)
if [ -z "$NETWORK_SCRIPT" ]; then
    echo "[!] 'homelab-network.sh' not found. Aborting."
    exit 1
fi

chmod +x "$NETWORK_SCRIPT"
bash "$NETWORK_SCRIPT"
if [ $? -ne 0 ]; then
    echo "[!] Network setup failed. Aborting."
    exit 1
fi

echo "[+] Network initialized."

# Locate service scripts
echo "[*] Searching for service scripts (srv-*.sh)..."
SERVICE_SCRIPTS=$(find / -type f -name "srv-*.sh" 2>/dev/null | head -n 1)
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
    echo ">>> Executing: $script"
    bash "$script"
    
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
