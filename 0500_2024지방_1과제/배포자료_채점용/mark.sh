#!/bin/bash

echo =====1-1=====
aws ec2 describe-vpcs --filter Name=tag:Name,Values=skills-vpc --query "Vpcs[].CidrBlock"
echo

echo =====1-2=====
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-public-subnet-a --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-public-subnet-b --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-private-subnet-a --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-private-subnet-b --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-protected-subnet-a --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-protected-subnet-b --query "Subnets[].[AvailabilityZone, CidrBlock][]"
echo

echo =====1-3=====
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-public-rtb --query "RouteTables[].Routes[].GatewayId"
aws ec2 describe-internet-gateways --filter Name=tag:Name,Values=skills-igw --query "InternetGateways[].InternetGatewayId"
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-private-rtb-a --query "RouteTables[].Routes[].NatGatewayId"
aws ec2 describe-nat-gateways --filter Name=tag:Name,Values=skills-nat-a --query "NatGateways[].NatGatewayId"
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-private-rtb-b --query "RouteTables[].Routes[].NatGatewayId"
aws ec2 describe-nat-gateways --filter Name=tag:Name,Values=skills-nat-b --query "NatGateways[].NatGatewayId"
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-protected-rtb --query "RouteTables[0].Routes[*].DestinationCidrBlock"
echo

echo =====2-1=====
aws ec2 describe-instances --filter Name=tag:Name,Values=skills-bastion-ec2 --query "Reservations[].Instances[].InstanceType"
echo

echo =====2-2=====
aws ec2 describe-instances --filter Name=tag:Name,Values=skills-bastion-ec2 --query "Reservations[].Instances[].PublicIpAddress"
aws ec2 describe-addresses --query "Addresses[].PublicIp"
echo

echo =====2-3 [see only 5\)]=====
IMAGE_ID=$(aws ec2 describe-instances --filter Name=tag:Name,Values=skills-bastion-ec2 --query "Reservations[].Instances[].ImageId" --output text)
aws ec2 describe-images --image-ids $IMAGE_ID --query "Images[].Description"
echo

echo =====3-1 [see only 7\)]=====
SUBNET_GROUP=$(aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].DBSubnetGroup" --output text)
SUBNETS=$(aws docdb describe-db-subnet-groups --db-subnet-group-name $SUBNET_GROUP --query "DBSubnetGroups[].Subnets[].SubnetIdentifier" --output text)
aws ec2 describe-subnets --subnet-ids $SUBNETS --query "Subnets[].CidrBlock"
echo

echo =====3-2=====
aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].MultiAZ"
echo

echo =====3-3=====
aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].StorageEncrypted"
echo

echo =====3-4=====
aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].EnabledCloudwatchLogsExports"
echo

echo =====3-5=====
aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].BackupRetentionPeriod"
echo

echo =====3-6=====
aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].Port"
echo

echo =====3-7=====
aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].EngineVersion"
echo

echo =====3-8 [see only 5\)]=====
DB_INSTANCE_IDENTIFIER=$(aws docdb describe-db-clusters --db-cluster-identifier skills-mongodb-cluster --query "DBClusters[].DBClusterMembers[0].DBInstanceIdentifier" --output text)
aws docdb describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER --query "DBInstances[].DBInstanceClass"
echo

echo =====4-1 [see only 9\)]=====
CACHE_CLUSTER_ID=$(aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].NodeGroups[0].NodeGroupMembers[0].CacheClusterId" --output text)
CACHE_SUBNET_GROUP_NAME=$(aws elasticache describe-cache-clusters --cache-cluster-id $CACHE_CLUSTER_ID --query "CacheClusters[].CacheSubnetGroupName" --output text)
SUBNETS=$(aws elasticache describe-cache-subnet-groups --cache-subnet-group-name $CACHE_SUBNET_GROUP_NAME --query "CacheSubnetGroups[].Subnets[].SubnetIdentifier" --output text)
aws ec2 describe-subnets --subnet-ids $SUBNETS --query "Subnets[].CidrBlock"
echo

echo =====4-2=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].ClusterEnabled"
echo

echo =====4-3=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].AutomaticFailover"
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].MultiAZ"
echo

echo =====4-4=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].AtRestEncryptionEnabled"
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].TransitEncryptionEnabled"
echo

echo =====4-5=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].LogDeliveryConfigurations[].Status"
echo

echo =====4-6=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].SnapshotRetentionLimit"
echo

echo =====4-7=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].ConfigurationEndpoint.Port"
echo

echo =====4-8 [see only 5\)]=====
CACHE_CLUSTER_ID=$(aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].NodeGroups[0].NodeGroupMembers[0].CacheClusterId" --output text)
aws elasticache describe-cache-clusters --cache-cluster-id $CACHE_CLUSTER_ID --query "CacheClusters[].EngineVersion"
echo

echo =====4-9=====
aws elasticache describe-replication-groups --replication-group-id skills-redis-cluster --query "ReplicationGroups[].CacheNodeType"
echo

echo =====5-1=====
aws ecr describe-repositories --repository-names user token --query "repositories[].repositoryName"
echo

echo =====5-2=====
aws ecr describe-repositories --repository-names user token --query "repositories[].encryptionConfiguration[].encryptionType"
echo

echo =====5-3=====
aws ecr describe-repositories --repository-names user token --query "repositories[].imageScanningConfiguration.scanOnPush"
echo

echo =====5-4=====
aws ecr describe-repositories --repository-names user token --query "repositories[].imageTagMutability"
echo

echo =====6-1=====
aws eks describe-cluster --name skills-eks-cluster --query "cluster.logging.clusterLogging"
aws eks describe-cluster --name skills-eks-cluster --query "cluster.encryptionConfig[].provider.keyArn"
aws eks describe-cluster --name skills-eks-cluster --query "cluster.resourcesVpcConfig.[endpointPublicAccess, endpointPrivateAccess]"
echo

echo =====6-2=====
aws eks describe-nodegroup --cluster-name skills-eks-cluster --nodegroup-name skills-eks-addon-nodegroup --query "nodegroup.nodegroupName"
kubectl get no -l "eks.amazonaws.com/nodegroup=skills-eks-addon-nodegroup" --output json | jq ".items[].metadata.labels | .\"eks.amazonaws.com/nodegroup\" + \" \" + .\"topology.kubernetes.io/zone\""
kubectl get no -l "eks.amazonaws.com/nodegroup=skills-eks-addon-nodegroup" --output json | jq ".items[].metadata.labels.\"node.kubernetes.io/instance-type\""
echo

echo =====6-3=====
aws eks describe-nodegroup --cluster-name skills-eks-cluster --nodegroup-name skills-eks-app-nodegroup --query "nodegroup.nodegroupName"
kubectl get no -l "eks.amazonaws.com/nodegroup=skills-eks-app-nodegroup" --output json | jq ".items[].metadata.labels | .\"eks.amazonaws.com/nodegroup\" + \" \" + .\"topology.kubernetes.io/zone\""
kubectl get no -l "eks.amazonaws.com/nodegroup=skills-eks-app-nodegroup" --output json | jq ".items[].metadata.labels.\"node.kubernetes.io/instance-type\""
echo

echo =====6-4=====
aws eks describe-fargate-profile --cluster-name skills-eks-cluster --fargate-profile-name skills-eks-app-profile --query "fargateProfile.fargateProfileName"
echo

echo =====7-1=====
aws elbv2 describe-load-balancers --names skills-user-alb --query "LoadBalancers[].Scheme"
echo

echo =====8-1=====
kubectl get pod -n skills | grep user
NODE_ID=$(kubectl get pod -n skills -o json | jq '.items[]' | jq 'select(.metadata.name | startswith("user"))' | jq -r '.spec.nodeName' | head -n 1)
kubectl get node $NODE_ID -o json | jq -r '.metadata.labels."eks.amazonaws.com/nodegroup"'
echo

echo =====8-2=====
kubectl get pod -n skills | grep token
NODE_ID=$(kubectl get pod -n skills -o json | jq '.items[]' | jq 'select(.metadata.name | startswith("token"))' | jq -r '.spec.nodeName' | head -n 1)
kubectl get pod -n skills -o json | jq '.items[]' | jq 'select(.metadata.name | startswith("token"))' | jq -r '.metadata.annotations.CapacityProvisioned' | head -n 1
echo

echo =====8-3 [see only 5\), 7\)]=====
ALB_DNS=$(aws elbv2 describe-load-balancers --names skills-user-alb --query "LoadBalancers[].DNSName" --output text)
POST_RESULT=$(curl http://$ALB_DNS/api/v1/user -X POST -H 'Content-Type: application/json' -d '{"id": "test9999", "name": "test9999", "password": "test9999"}' --silent)
echo $POST_RESULT
echo
TOKEN=$(echo $POST_RESULT | jq -r '.token')
curl http://$ALB_DNS/api/v1/user?token=$TOKEN --silent
echo
echo

echo =====9-1=====
aws logs tail /aws/app/user | tail -n 1
echo

echo =====9-2=====
aws logs tail /aws/app/token | tail -n 1
echo

echo =====10-1=====
echo manual
echo
echo "./load-user.sh"
echo "kubectl get pod -n skills | grep user"
echo "kubectl get node -o json | jq '.items[].metadata.labels' | jq -c 'select(.\"eks.amazonaws.com/nodegroup\" == \"skills-eks-app-nodegroup\")' | wc -l"
echo

echo =====10-2=====
echo manual
echo
echo "kubectl get pod -n skills | grep user"
echo "kubectl get node -o json | jq '.items[].metadata.labels' | jq -c 'select(.\"eks.amazonaws.com/nodegroup\" == \"skills-eks-app-nodegroup\")' | wc -l"
echo

echo =====10-3=====
echo manual
echo
echo "./load-token.sh"
echo "kubectl get pod -n skills | grep token"
echo

echo =====10-4=====
echo manual
echo
echo "kubectl get pod -n skills | grep token"
echo