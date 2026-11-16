#!/bin/bash

# Attend que le badge soit dans la boîte aux lettres
while [ ! -f /vagrant/token ]; do sleep 2; done

# Rejoint le bureau avec son adresse + le badge
curl -sfL https://get.k3s.io | \
  K3S_URL="https://192.168.56.110:6443" \
  K3S_TOKEN="$(cat /vagrant/token)" \
  INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --flannel-iface=eth1" sh -