#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFS="$SCRIPT_DIR/../confs"

# 0. Choisir le mot de passe root de GitLab (il n'est jamais écrit dans Git)
read -s -p "Mot de passe root de GitLab (lettres et chiffres, 12 caractères min) : " GITLAB_PASSWORD
echo

# 1. La base de la Partie 3 : cluster K3d, Argo CD, namespaces argocd et dev
bash "$SCRIPT_DIR/../../p3/scripts/setup.sh"

# 2. GitLab dans le namespace gitlab, avec son mot de passe dans un Secret
kubectl create namespace gitlab
kubectl create secret generic gitlab-root -n gitlab --from-literal=password="$GITLAB_PASSWORD"
kubectl apply -f "$CONFS/gitlab.yaml"

# 3. Attendre que GitLab soit vraiment prêt (5 à 15 minutes)
echo "Démarrage de GitLab, patience..."
kubectl wait --for=condition=available deployment/gitlab -n gitlab --timeout=900s
until kubectl exec -n gitlab deploy/gitlab -- curl -sf http://localhost:8181/-/readiness > /dev/null 2>&1; do
  sleep 15
done
echo "GitLab est prêt !"

# 4. Ouvrir une porte vers GitLab, en arrière-plan
kubectl port-forward -n gitlab svc/gitlab 8181:8181 > /dev/null 2>&1 &
PF_PID=$!
sleep 5

# 5. Créer le projet "playground" en y poussant l'appli v1
TMP=$(mktemp -d)
cp -r "$CONFS/app/." "$TMP/"
cd "$TMP"
git init -q -b main
git add .
git commit -q -m "v1"
git push -q "http://root:${GITLAB_PASSWORD}@localhost:8181/root/playground.git" main
cd - > /dev/null
rm -rf "$TMP"

# 6. Donner à Argo CD le droit de lire le projet
kubectl create secret generic gitlab-repo -n argocd \
  --from-literal=type=git \
  --from-literal=url=http://gitlab.gitlab.svc.cluster.local:8181/root/playground.git \
  --from-literal=username=root \
  --from-literal=password="$GITLAB_PASSWORD"
kubectl label secret gitlab-repo -n argocd argocd.argoproj.io/secret-type=repository

# 7. La mission d'Argo CD : surveiller GitLab au lieu de GitHub
kubectl apply -f "$CONFS/application.yaml"

# 8. Fermer la porte temporaire
kill $PF_PID
echo "Terminé ! Pour l'interface : kubectl port-forward -n gitlab svc/gitlab 8181:8181, puis http://localhost:8181 (root)"