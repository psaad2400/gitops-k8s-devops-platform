#!/bin/bash

echo "🚀 Creating cluster..."
terraform -chdir=terraform apply -auto-approve

echo "📦 Installing Argo CD..."
kubectl create namespace argocd || true

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for Argo CD..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo "⚙️ Deploying apps via Argo CD..."
kubectl apply -f ../argocd/root-app.yaml

echo "✅ DONE!"