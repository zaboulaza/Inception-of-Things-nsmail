#!/bin/bash

# Jette l'ancien badge s'il traîne encore
rm -f /vagrant/token

# Installe K3s en mode server, sur la bonne carte réseau
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=192.168.56.110 \
  --flannel-iface=eth1 \
  --write-kubeconfig-mode=644" sh -

# Dépose le nouveau badge dans la boîte aux lettres
cp /var/lib/rancher/k3s/server/node-token /vagrant/token