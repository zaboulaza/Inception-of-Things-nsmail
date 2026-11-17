#!/bin/bash
set -e

# 1. Docker : pour faire tourner les conteneurs
sudo apt-get update
sudo apt-get install -y docker.io curl
sudo usermod -aG docker "$USER"

# 2. kubectl : la télécommande de Kubernetes
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# 3. K3d : pour créer des clusters K3s dans Docker
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash