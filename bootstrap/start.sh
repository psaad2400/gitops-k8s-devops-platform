#!/bin/bash
set -e


ENV_FILE="../.env"
if [ -f "$ENV_FILE" ]; then
    echo "🔑 Loading credentials from $ENV_FILE..."
    # Set permissions to 600 (Owner Read/Write Only) for extra safety
    chmod 600 "$ENV_FILE"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "⚠️  $ENV_FILE not found!"
    read -p "Enter GitHub Username: " GITHUB_USER
    read -sp "Enter GitHub PAT (Input hidden): " GITHUB_TOKEN
    echo ""
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GitHub Token is required for Image Updater."
    exit 1
fi
# --------------------------------

echo "🚀 Creating cluster..."
terraform -chdir=../terraform apply -auto-approve

echo "📦 Installing Argo CD..."
kubectl create namespace argocd || true
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# # (Optional) Install Image Updater
# echo "📦 Installing Argo CD Image Updater..."
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml

# echo "📦 Installing Image Updater via Helm..."
# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# # We use Helm to avoid 404s and ensure the Controller (not Operator) is installed
# helm upgrade --install argocd-image-updater argo/argocd-image-updater \
#   --namespace argocd \
#   --set rbac.enabled=true

# echo "🔐 Creating Git credentials for Image Updater..."

# We use --from-literal but since it's in a variable in the script, it's not in history.
# We also use --dry-run=client to avoid logging it to stdout.
kubectl create secret generic git-creds \
  -n argocd \
  --from-literal=username="$GITHUB_USER" \
  --from-literal=password="$GITHUB_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -


echo "🌐 Applying custom Argo CD Service..."
kubectl apply -f ../argocd/argocd-server-nodeport.yaml -n argocd

echo "⏳ Waiting for Argo CD Server to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Argo CD manages apps
echo "⚙️ Deploying apps via Argo CD..."
kubectl apply --server-side -f ../argocd/root-app.yaml

echo "⏳ Waiting for monitoring stack (Grafana) to be ready..."
sleep 30

# 🔑 Argo CD Password
echo "🔑 Fetching Argo CD Admin Password..."
ARGOPASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode)

# # 🔑 Grafana Password
# echo "🔑 Fetching Grafana Admin Password..."
# GRAFANAPASS=$(kubectl -n monitoring get secret monitoring-grafana \
#   -o jsonpath="{.data.admin-password}" | base64 --decode 2>/dev/null || echo "Grafana not ready yet")


echo "------------------------------------------------------"
echo "✅ SETUP COMPLETE!"
echo ""
echo "📍 Argo CD URL: http://localhost:30008"
echo "👤 Argo Username: admin"
echo "🔐 Argo Password: $ARGOPASS"
echo ""
echo "📍 Grafana URL: http://localhost:30009"
echo "👤 Grafana Username: admin"
echo "🔐 Grafana Password: $GRAFANAPASS"
echo "------------------------------------------------------"

