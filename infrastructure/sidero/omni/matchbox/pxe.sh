#!/bin/bash

path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

mkdir -p "$path/volumes/matchbox/var/lib/matchbox/assets"

echo -n "Downloading initramfs..."
wget -q -O "$path/volumes/matchbox/var/lib/matchbox/assets/initramfs.xz" https://github.com/siderolabs/talos/releases/download/v1.5.5/initramfs-amd64.xz
echo "done"

echo -n "Downloading vmlinuz..."
wget -q -O "$path/volumes/matchbox/var/lib/matchbox/assets/vmlinuz" https://github.com/siderolabs/talos/releases/download/v1.5.5/vmlinuz-amd64
echo "done"

echo -n "Cloning matchbox repo..."
git clone -q --depth 1 https://github.com/poseidon/matchbox.git
echo "done"

cd matchbox/scripts/tls/

export SAN=DNS.1:matchbox.localdomain,IP.1:192.168.8.254
./cert-gen

mkdir -p "$path/etc/matchbox"
cp ca.crt server.crt server.key "$path/etc/matchbox/"

cd $path

rm -rf matchbox

echo "Starting containers..."
docker compose -f "$path/docker-compose.yml" up -d
echo "done"