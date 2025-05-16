#!/bin/bash

# Define source and destination directories
SRC_DIR=$(find /home/hk/tests/Homelab-sh/Homelab-sh -type d -name "HOMELAB-SH" -exec bash -c 'echo {}/config/*' \; | head -n1)
DEST_DIR="/srv/docker"

# List of folders to copy
FOLDERS=("pihole" "nginx")

for folder in "${FOLDERS[@]}"; do
    if [ -d "$SRC_DIR/$folder" ]; then
        cp -r "$SRC_DIR/$folder" "$DEST_DIR/"
        echo "Copied $folder to $DEST_DIR"
    else
        echo "Source folder $SRC_DIR/$folder does not exist."
    fi
done