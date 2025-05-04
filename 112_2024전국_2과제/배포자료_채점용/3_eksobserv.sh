#!/bin/bash
echo "######################"
echo "######################"
echo "### Module 3"
echo "####"
echo "######################"
echo "######################"

# Export
aws configure set default.region us-west-1
aws configure set default.output json

echo =====3-1=====
aws eks describe-cluster --name wsi-eks-cluster --query "cluster.name"
aws eks describe-cluster --name wsi-eks-cluster --query "cluster.version"
echo

echo =====3-2=====
kubectl get ns -o json | jq '.items[] | select(.metadata.name == "wsi-ns") | .metadata.name'
echo

echo =====3-3====
    aws logs describe-log-groups --query "logGroups[?contains(logGroupName, '/wsi/eks/log/')].logGroupName"
echo

echo =====3-4=====
kubectl get deploy -n wsi-ns -o json | jq '.items[].metadata.name'
echo

echo =====3-5=====
kubectl get po -n wsi-ns -o json | jq '.items[].spec.containers[].name'
echo

echo =====3-6=====
POD_ID=$(kubectl get po -n wsi-ns -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_ID -n wsi-ns -- curl localhost:8080/2xx
kubectl exec -it $POD_ID -n wsi-ns -- curl localhost:8080/3xx
kubectl exec -it $POD_ID -n wsi-ns -- curl localhost:8080/4xx
kubectl exec -it $POD_ID -n wsi-ns -- curl localhost:8080/5xx
kubectl exec -it $POD_ID -n wsi-ns -- curl localhost:8080/healthz
echo

echo =====3-7=====
CW_LOG_STREAM_NAME=$(aws logs describe-log-streams --log-group-name /wsi/eks/log/ --query "logStreams[].logStreamName" --output text)
POD_ID=$(kubectl get po -n wsi-ns -o jsonpath='{.items[0].metadata.name}')
MATCHING_LOG_STREAM_NAME="log-$POD_ID"
[ "$CW_LOG_STREAM_NAME" == "$MATCHING_LOG_STREAM_NAME" ] && aws logs describe-log-streams --log-group-name /wsi/eks/log/ --query "logStreams[].logStreamName"
echo

echo =====3-8=====
aws logs tail /wsi/eks/log/ | tail -n 1 | awk '{print substr($0,index($0,"{"))}' | jq .
echo 