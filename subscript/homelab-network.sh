#!/bin/bash

# Script to create a Docker network named 'homelab-network'

NETWORK_NAME="homelab-network"

# Ask user for subnet
read -p "Enter subnet for the Docker network (e.g., 172.25.0.0/16): " SUBNET

# Check if the network already exists
if docker network ls --format '{{.Name}}' | grep -wq "$NETWORK_NAME"; then
    echo "Docker network '$NETWORK_NAME' already exists."
else
    docker network create --subnet="$SUBNET" "$NETWORK_NAME"
    echo "Docker network '$NETWORK_NAME' created with subnet $SUBNET."
fi