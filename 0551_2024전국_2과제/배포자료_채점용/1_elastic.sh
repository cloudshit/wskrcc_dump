#!/bin/bash

echo ####################################
echo ####################################
echo ###
echo ###    Module 1 
echo ####################################
echo ####################################

aws configure set default.region ap-northeast-2

echo =====1-1=====
aws ec2 describe-instances --filter Name=tag:Name,Values=wsi-bastion \
	--query "Reservations[].Instances[].InstanceType"
echo

echo =====1-2=====
aws ec2 describe-instances --filter Name=tag:Name,Values=wsi-app \
	--query "Reservations[].Instances[].InstanceType"
echo

echo =====1-3=====
APP_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=wsi-app" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
curl $APP_PRIVATE_IP:5000/log
echo ""
curl $APP_PRIVATE_IP:5000/healthcheck
echo

echo =====1-4=====
aws opensearch list-domain-names | grep wsi-opensearch
echo

echo =====1-5=====
aws opensearch describe-domain --domain-name wsi-opensearch --query "DomainStatus.ClusterConfig.[InstanceCount, DedicatedMasterCount]"
echo "-----"
aws opensearch describe-domain --domain-name wsi-opensearch --query "DomainStatus.EngineVersion"
echo "-----"
OPENSEARCH_ENDPOINT=$(aws opensearch describe-domain --domain-name wsi-opensearch | jq -r '.DomainStatus.Endpoint')
curl -s -u admin:Password01! "https://$OPENSEARCH_ENDPOINT/_cat/indices?index=app-log"
echo "-----"
OPENSEARCH_ENDPOINT=$(aws opensearch describe-domain --domain-name wsi-opensearch | jq -r '.DomainStatus.Endpoint')
curl -s -u admin:Password01! https://$OPENSEARCH_ENDPOINT/app-log | jq '.["app-log"].mappings.properties | keys[]'
echo "-----"
echo

echo =====1-6=====
aws opensearch describe-domain --domain-name wsi-opensearch --output json | jq -r '.DomainStatus.Endpoint + "/_dashboards"'
echo "Manual Marking !!!"
echo
