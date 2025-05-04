#!/bin/bash

echo "kubectl get pod -n skills | grep token"
echo
echo "Copy it! this script will begin after 10 seconds..."
sleep 11

ALB_DNS=$(aws elbv2 describe-load-balancers --names skills-user-alb --query "LoadBalancers[].DNSName" --output text)

while true :
do
    curl --silent http://$ALB_DNS/api/v1/stress/token
    sleep 0.001
done