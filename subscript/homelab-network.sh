#!/bin/bash

# Script to create a Docker network named 'homelab-network'


echo "=== Creating Docker Network ==="
NETWORK_NAME="homelab-network"
# Ask user for subnet
read -p "Enter subnet for the Docker network (e.g., 172.25.0.0/16): " SUBNET

docker network create --subnet="$SUBNET" "$NETWORK_NAME"
echo "Docker network '$NETWORK_NAME' created with subnet $SUBNET."
