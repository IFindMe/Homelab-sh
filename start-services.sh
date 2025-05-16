#!/bin/bash

# Script to start all homelab services

echo "=== Starting Homelab Services ==="
echo "Looking for homelab-network script homelab-network.sh"


#do search, if not found, exit
NETWORK_SCRIPT=$(find / -type f -name "homelab-network.sh" 2>/dev/null | head -n 1)
if [ -z "$NETWORK_SCRIPT" ]; then
    echo "homelab-network.sh not found! Exiting."
    exit 1
fi
chmod +x "$NETWORK_SCRIPT"
bash "$NETWORK_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Failed to create Docker network. Exiting."
    exit 1
fi

echo "looking for services scripts (srv-*.sh)..."
# Find all service scripts (dynamic path) 
SERVICE_SCRIPTS=$(find / -type f -name "srv-*.sh" 2>/dev/null | head -n 1)
SCRIPT_COUNT=$(echo "$SERVICE_SCRIPTS" | wc -l)

if [ -z "$SERVICE_SCRIPTS" ]; then
    echo "No service scripts found!"
    exit 1
fi

echo "Found $SCRIPT_COUNT service scripts."
echo "Starting services..."

# Make all scripts executable
for script in $SERVICE_SCRIPTS; do
    chmod +x "$script"
done

# Run each service script
for script in $SERVICE_SCRIPTS; do
    echo ""
    echo "=== Running $script ==="
    bash "$script"
    
    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        echo "✅ $script completed successfully"
    else
        echo "❌ $script failed with exit code $?"
    fi
done

echo ""
echo "=== All services started ==="
echo "Docker containers running:"
docker ps

echo ""
echo "Homelab startup complete!"