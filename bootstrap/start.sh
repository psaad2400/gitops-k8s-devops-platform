#!/bin/bash
set -e

echo "🚀 Creating cluster..."
terraform -chdir=terraform apply -auto-approve

echo "📦 Installing Argo CD..."
kubectl create namespace argocd || true
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "🌐 Applying custom Argo CD Service..."
kubectl apply -f argocd/argocd-server-nodeport.yaml -n argocd

echo "⏳ Waiting for Argo CD Server to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Argo CD manages apps
echo "⚙️ Deploying apps via Argo CD..."
kubectl apply --server-side -f argocd/root-app.yaml

echo "⏳ Waiting for monitoring stack (Grafana) to be ready..."
sleep 30

# 🔑 Argo CD Password
echo "🔑 Fetching Argo CD Admin Password..."
ARGOPASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode)

# 🔑 Grafana Password
echo "🔑 Fetching Grafana Admin Password..."
GRAFANAPASS=$(kubectl -n monitoring get secret monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode 2>/dev/null || echo "Grafana not ready yet")

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