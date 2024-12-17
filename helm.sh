#!/bin/bash
TAG=$1
NAMESPACE=sample
helm repo add bitnami https://charts.bitnami.com/bitnami
export KUBECONFIG=$HOME/.kube/config
result=$(eval helm ls -n $NAMESPACE| grep -w sample-app)
if [ $? -ne "0" ]; then
   helm dependency build charts/sample-app
   helm install sample-app ./charts/sample-app --version $TAG -n $NAMESPACE
else
   helm dependency update charts/sample-app
   helm upgrade sample-app ./charts/sample-app --version $TAG -n $NAMESPACE
fi
