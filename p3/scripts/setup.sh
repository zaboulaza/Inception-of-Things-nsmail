#!/bin/bash
set -e

# Le dossier où se trouve ce script (pour le lancer depuis n'importe où)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Le cluster K3d, avec la porte 8888 ouverte
k3d cluster create iot -p "8888:8888@loadbalancer"

# 2. Les 2 namespaces
kubectl create namespace argocd
kubectl create namespace dev

# 3. Argo CD, puis attendre qu'il soit prêt
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s

# 4. La fiche de mission d'Argo CD
kubectl apply -f "$SCRIPT_DIR/../confs/application.yaml"

# 5. Afficher le mot de passe de l'interface
echo "Mot de passe admin d'Argo CD :"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo