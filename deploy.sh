#!/usr/bin/env bash
set -euo pipefail
KIND_CFG="kind-cluster.yaml"
MANIFESTS="manifests/all.yaml"

echo "1) Creating kind cluster..."
kind create cluster --name bank-sim --config "${KIND_CFG}"

echo "2) Waiting for nodes ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "3) Installing ingress-nginx (optional for Ingress rules)..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/kind/deploy.yaml

echo "Waiting for ingress pods..."
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=120s || true

echo "4) Applying manifests..."
kubectl apply -f "${MANIFESTS}"

echo "5) Wait for deployments and statefulset to be ready (this can take a minute)..."
kubectl -n dmz rollout status deployment/web-dmz --timeout=120s || true
kubectl -n internal-apps rollout status deployment/internal-app --timeout=120s || true
kubectl -n admin rollout status deployment/admin-svc-deploy --timeout=120s || true
kubectl -n core rollout status statefulset/viridian-db --timeout=180s || true
kubectl -n core rollout status deployment/core-mock --timeout=120s || true
kubectl -n external rollout status deployment/external-api --timeout=120s || true

echo
echo "=== CLUSTER STATUS ==="
kubectl get nodes
kubectl get ns
kubectl get pods --all-namespaces -o wide
kubectl get svc -A

echo
echo "Access examples:"
echo "- DMZ web (NodePort 30001): from the VM or any machine that can reach the VM's IP:"
echo "    curl <VM_IP>:30001"
echo "- Internal backend (NodePort 30000):"
echo "    curl <VM_IP>:30000"
echo "- If you installed ingress-nginx, you can port-forward ingress-controller or use NodePort 30001 for web-dmz as above."

echo
echo "If you run inside Vagrant VM, find the VM IP by 'ip addr' or on your host use port forwarding / VM networking."
echo "Done."
