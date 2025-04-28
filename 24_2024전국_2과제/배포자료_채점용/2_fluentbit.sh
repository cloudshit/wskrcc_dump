echo "######################"
echo "######################"
echo "### Module 2"
echo "####"
echo "######################"
echo "######################"

echo -e "========2-1-A========"
kubectl get deployment service-a -n app -o=json | jq '.spec.template.spec.containers' | grep '"image"' \
; kubectl get deployment service-b -n app -o=json | jq '.spec.template.spec.containers' | grep '"image"' \
; kubectl get deployment service-c -n app -o=json | jq '.spec.template.spec.containers' | grep '"image"'

echo -e "\n========2-1-B========"
NODE_COUNT=$(kubectl get nodes | grep Ready | wc -l) \
; DAEMONSET_COUNT=$(kubectl get daemonsets -n fluentd | tail -n 1 | awk {'print $4'}) \
; echo $(expr $NODE_COUNT - $DAEMONSET_COUNT) \
; kubectl describe -n fluentd daemonset fluentd | grep Image | grep fluent

echo -e "\n========2-2-A========"
cd /tmp
kubectl get daemonset fluentd -n fluentd -o yaml > fluentd.yaml
kubectl delete daemonset fluentd -n fluentd
date
kubectl exec -it -n app deployment.apps/service-a -- curl localhost:8080 > /dev/null 2>&1
kubectl exec -it -n app deployment.apps/service-b -- curl localhost:8080 > /dev/null 2>&1
kubectl exec -it -n app deployment.apps/service-c -- curl localhost:8080 > /dev/null 2>&1
sleep 30;
aws logs get-log-events --log-group-name /gwangju/eks/application/logs --log-stream-name service-a-logs --limit 1 --query 'events[*].message' --output json \
; aws logs get-log-events --log-group-name /gwangju/eks/application/logs --log-stream-name service-b-logs --limit 1 --query 'events[*].message' --output json \
; aws logs get-log-events --log-group-name /gwangju/eks/application/logs --log-stream-name service-c-logs --limit 1 --query 'events[*].message' --output json
kubectl apply -f fluentd.yaml

echo -e "\n========2-3-A========"
date
kubectl exec -it -n app deployment.apps/service-a -- curl localhost:8080 > /dev/null 2>&1
kubectl exec -it -n app deployment.apps/service-b -- curl localhost:8080 > /dev/null 2>&1
kubectl exec -it -n app deployment.apps/service-c -- curl localhost:8080 > /dev/null 2>&1
sleep 30;
aws logs get-log-events --log-group-name /gwangju/eks/application/logs --log-stream-name service-a-logs --limit 1 --query 'events[*].message' --output json \
; aws logs get-log-events --log-group-name /gwangju/eks/application/logs --log-stream-name service-b-logs --limit 1 --query 'events[*].message' --output json \
; aws logs get-log-events --log-group-name /gwangju/eks/application/logs --log-stream-name service-c-logs --limit 1 --query 'events[*].message' --output json