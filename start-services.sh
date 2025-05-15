#!/bin/bash

# Script to start all homelab services

echo "=== Starting Homelab Services ==="
echo "Looking for service scripts (srv-*.sh)..."

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Find all service scripts
SERVICE_SCRIPTS=$(find . -name "srv-*.sh" -type f)
SCRIPT_COUNT=$(echo "$SERVICE_SCRIPTS" | wc -l)

if [ -z "$SERVICE_SCRIPTS" ]; then
    echo "No service scripts found!"
    exit 1
fi

echo "Found $SCRIPT_COUNT service scripts."
echo "Starting services..."

# Make all scripts executable
chmod +x srv-*.sh

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