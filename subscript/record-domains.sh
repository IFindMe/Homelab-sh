#!/bin/bash

domain="$1"
ip="$2"

# add domain in pi-hole container
docker exec pihole pihole -a addcustomdomain "$domain" "$ip"


# example usage
# ./record-domains.sh "home.net" "172.16.0.1"