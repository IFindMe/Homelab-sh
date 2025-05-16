#!/bin/bash

# Stop and remove all running containers

containers=$(docker ps -q)
if [ -n "$containers" ]; then
    docker stop $containers
    docker rm $containers
else
    echo "No running containers to stop or remove."
fi