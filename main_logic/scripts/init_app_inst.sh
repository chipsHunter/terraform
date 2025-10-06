#!/bin/bash
set -e

curl -sfL https://get.k3s.io  | INSTALL_K3S_EXEC="--disable=traefik" sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
