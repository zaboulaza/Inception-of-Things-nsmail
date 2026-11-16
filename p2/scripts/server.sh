#!/bin/bash

# Installe K3s en mode server, sur la bonne carte réseau
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=192.168.56.110 \
  --flannel-iface=eth1 \
  --write-kubeconfig-mode=644" sh -

# Attend que Kubernetes soit prêt à recevoir des ordres
until kubectl get nodes > /dev/null 2>&1; do sleep 2; done

# Donne à Kubernetes tous les fichiers du dossier confs
kubectl apply -f /vagrant/confs/