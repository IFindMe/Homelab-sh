#!/bin/bash

# Script to create a Docker network named 'homelab-network'

echo "=== Creating Functional Docker Network ==="
NETWORK_NAME="homelab-network"
SUBNET="172.25.0.0/24"
GATEWAY="172.25.0.1"

docker network create \
  --driver=bridge \
  --subnet="$SUBNET" \
  --gateway="$GATEWAY" \
  --opt com.docker.network.bridge.name=br-homelab \
  "$NETWORK_NAME"

echo "Docker network '$NETWORK_NAME' created with subnet $SUBNET and gateway $GATEWAY."
