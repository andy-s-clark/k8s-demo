#!/bin/bash

kind create cluster --name demo --config kind/demo-cluster.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

kubectl apply -f kind/localhost-ingress-master.yaml

kubectl apply -f kind/echo-test.yaml

echo Starting Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

kubectl apply -f kind/dashboard-admin-user.yaml

echo Dashboard token
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
echo

echo Starting Kubernetes API proxy
kubectl proxy &

echo Building and starting applications
docker build -t demo/gc-thrasher:0.1 services/gc-thrasher
kind --name demo load docker-image demo/gc-thrasher:0.1
kind --name demo load docker-image demo/node-api:0.1
kubectl apply -f kind/demo-workload.yaml

docker build -t demo/node-api:0.1 services/node-api
kind --name demo load docker-image demo/node-api:0.1
kubectl apply -f kind/demo-workload.yaml

echo Demo workload started. Ready for the datadog agent to be started.
