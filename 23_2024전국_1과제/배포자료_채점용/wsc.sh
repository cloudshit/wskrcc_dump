#!/bin/bash
######### Paramters ##############################
STATIC_BUCKET_NAME="wsc2024-s3-static-<random 4words>"
HOSTZONE=""  # p1xx.cloudhrdkx.com
PNUMBER="" # 101
OLDCDN_ID=""  # not additional test project
OLDCDN_DNS=""

echo "========== 2024년 경상북도 전국기능경기대회 =========="
echo "-"
echo "-"
echo "-"

echo "===== 사전준비 : 0 ====="
rm -rf ~/.aws
mkdir -p ~/.aws
cat << EOF > ~/.aws/config
[default]
region = us-east-1
EOF
echo "사전준비 완료! 채점 시작!"

echo ""

echo "===== Network Configuration : 1-1-A (VPC) ====="
aws ec2 describe-vpcs --filter Name=tag:Name,Values=wsc2024-ma-vpc --query "Vpcs[0].CidrBlock" \
; aws ec2 describe-vpcs --filter Name=tag:Name,Values=wsc2024-prod-vpc --query "Vpcs[0].CidrBlock" \
; aws ec2 describe-vpcs --filter Name=tag:Name,Values=wsc2024-storage-vpc --query "Vpcs[0].CidrBlock"

echo ""

echo "===== Network Configuration : 1-2-A (Subnet) ====="
aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-ma-mgmt-sn-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-ma-mgmt-sn-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-prod-load-sn-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-prod-load-sn-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-prod-app-sn-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-prod-app-sn-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-storage-db-sn-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=wsc2024-storage-db-sn-b --query "Subnets[0].CidrBlock"

echo ""

echo "===== Network Configuration : 1-3-A (Routing Table) ====="
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=wsc2024-ma-mgmt-rt" --query "RouteTables[].Routes[?GatewayId != null && starts_with(GatewayId, 'igw')].GatewayId" --output text \
; aws ec2 describe-route-tables --filters "Name=tag:Name,Values=wsc2024-prod-load-rt" --query "RouteTables[].Routes[?GatewayId != null && starts_with(GatewayId, 'igw')].GatewayId" --output text \
; aws ec2 describe-route-tables --filters "Name=tag:Name,Values=wsc2024-prod-app-rt-a" --query "RouteTables[].Routes[?NatGatewayId != null].NatGatewayId" --output text \
; aws ec2 describe-route-tables --filters "Name=tag:Name,Values=wsc2024-prod-app-rt-b" --query "RouteTables[].Routes[?NatGatewayId != null].NatGatewayId" --output text \
; aws ec2 describe-route-tables --filters "Name=tag:Name,Values=wsc2024-storage-db-rt-a" --query "RouteTables[].Associations[].SubnetId" --output text | xargs -I {} aws ec2 describe-subnets --subnet-ids {} --query "Subnets[].Tags[?Key=='Name'].Value" --output text \
; aws ec2 describe-route-tables --filters "Name=tag:Name,Values=wsc2024-storage-db-rt-b" --query "RouteTables[].Associations[].SubnetId" --output text | xargs -I {} aws ec2 describe-subnets --subnet-ids {} --query "Subnets[].Tags[?Key=='Name'].Value" --output text

echo ""

echo "===== Network Configuration : 1-4-A (Flow Logs) ====="
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=wsc2024-ma-vpc" --query "Vpcs[*].VpcId" --output text)
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=$VPC_ID" --query "FlowLogs[*].FlowLogId" --output text

echo ""

echo "===== Network Configuration : 1-5-A (VPC Endpoint) ====="
aws ec2 describe-vpc-endpoints --query "VpcEndpoints[].ServiceName" 

echo ""

echo "===== Network Configuration : 1-6-A (Endpoint Preparation Process) ====="
POLICY_ARNS=$(aws iam list-attached-role-policies --role-name wsc2024-bastion-role --query "AttachedPolicies[].PolicyArn" --output text)
for POLICY_ARN in $POLICY_ARNS; do
POLICY_VERSION=$(aws iam get-policy --policy-arn $POLICY_ARN --query "Policy.DefaultVersionId" --output text)
POLICY_DOCUMENT=$(aws iam get-policy-version --policy-arn $POLICY_ARN --version-id $POLICY_VERSION --query "PolicyVersion.Document" --output json)
echo "$POLICY_DOCUMENT"
done
echo "===== Network Configuration : 1-6-B (Endpoint Preparation Process) ====="
export BUCKET_NAME="tesfsdfklsqwerlksdf${PNUMBER}"
export REGION="us-east-1"
export FILE_NAME="test_upload.txt"
export DOWNLOADED_FILE_NAME="downloaded_test_upload.txt"
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION > /dev/null 2>&1
echo "This is a test file for S3 upload and download." > $FILE_NAME
aws s3 cp $FILE_NAME s3://$BUCKET_NAME/ > /dev/null 2>&1
aws s3 cp s3://$BUCKET_NAME/$FILE_NAME $DOWNLOADED_FILE_NAME
aws s3 rm s3://$BUCKET_NAME/$FILE_NAME
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION > /dev/null

echo ""

echo "===== Network Configuration : 1-7-A (Bastion Access to ECR | 1-6 오답 시 진행 X) ====="
AWS_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
docker rmi -f $(docker images) 2>/dev/null \
; aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com" > /dev/null 2>&1 \
; docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/customer-repo:latest

echo ""

echo "===== Transit Between VPC : 2-1-A (Transit Gateway Configure) ====="
TGWS=$(aws ec2 describe-transit-gateways --query "TransitGateways[*].{Name:Tags[?Key=='Name'].Value|[0]}" --output json)
TGW_NAMES=$(echo $TGWS | jq -r '.[].Name')
for TGW_NAME in $TGW_NAMES; do
echo "$TGW_NAME"
TGW_ID=$(aws ec2 describe-transit-gateways --filters "Name=tag:Name,Values=$TGW_NAME" --query "TransitGateways[0].TransitGatewayId" --output text)
ATTACHMENTS=$(aws ec2 describe-transit-gateway-attachments --filters "Name=transit-gateway-id,Values=$TGW_ID" --query "TransitGatewayAttachments[*].{Name:Tags[?Key=='Name'].Value|[0]}" --output json)
ATTACHMENT_NAMES=$(echo $ATTACHMENTS | jq -r '.[].Name')
for ATTACHMENT_NAME in $ATTACHMENT_NAMES; do
    echo "$ATTACHMENT_NAME"
done
ROUTE_TABLES=$(aws ec2 describe-transit-gateway-route-tables --filters "Name=transit-gateway-id,Values=$TGW_ID" --query "TransitGatewayRouteTables[*].{Name:Tags[?Key=='Name'].Value|[0]}" --output json)
ROUTE_TABLE_NAMES=$(echo $ROUTE_TABLES | jq -r '.[].Name')
for ROUTE_TABLE_NAME in $ROUTE_TABLE_NAMES; do
    echo "$ROUTE_TABLE_NAME"
done    
done

echo ""

echo "===== Transit Between VPC : 3-1-A (Bastion Configure) ====="
INSTANCE_NAME_TAG="wsc2024-bastion-ec2"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_TAG" --query "Reservations[0].Instances[0].InstanceId" --output text)
AMI_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].ImageId" --output text)
AMI_DESCRIPTION=$(aws ec2 describe-images --image-ids "$AMI_ID" --query "Images[0].Description" --output text)
INSTANCE_TYPE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].InstanceType" --output text)
echo "$AMI_DESCRIPTION"
echo "$INSTANCE_TYPE"

echo ""

echo "===== Transit Between VPC : 3-2-A (Bastion Security) ====="
aws ec2 describe-security-groups --filter Name=group-name,Values=wsc2024-bastion-sg --query "SecurityGroups[0].IpPermissions[].{FromPort:FromPort,ToPort:ToPort,IpRanges:IpRanges}"
echo "===== Transit Between VPC : 3-2-B (Bastion Security) ====="
INSTANCE_NAME_TAG="wsc2024-bastion-ec2"
INSTANCE_DESC=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_TAG" --query "Reservations[0].Instances[0]" --output json)
IAM_INSTANCE_PROFILE_ARN=$(echo $INSTANCE_DESC | jq -r '.IamInstanceProfile.Arn')
ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $(echo $IAM_INSTANCE_PROFILE_ARN | awk -F'/' '{print $NF}') --query "InstanceProfile.Roles[0].RoleName" --output text)
ROLE_POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query "AttachedPolicies[].PolicyName" --output text)
echo "$ROLE_POLICIES"

echo ""

echo "===== Application Access Control : 4-1-A (VPC Lattice Configure) ====="
aws vpc-lattice list-service-networks --query "items[?name=='wsc2024-lattice-svc-net'].name" --output text
SERVICE_NETWORK_ID=$(aws vpc-lattice list-service-networks --query "items[?name=='wsc2024-lattice-svc-net'].id" --output text)
SVC_ASSOCIATION=$(aws vpc-lattice list-service-network-service-associations --service-network-identifier "$SERVICE_NETWORK_ID" --query items[*].id --output text)
VPC_ASSOCIATION=$(aws vpc-lattice list-service-network-vpc-associations --service-network-identifier "$SERVICE_NETWORK_ID" --query 'items[*].id' --output text)
echo "$SVC_ASSOCIATION"
echo "$VPC_ASSOCIATION"

echo ""

echo "===== Application Access Control : 4-2-A (Healthcheck) ====="
TARGET_GROUP_ID=$(aws vpc-lattice list-target-groups --target-group-type IP | jq -r '.items[].id')
aws vpc-lattice list-targets --target-group-identifier "$TARGET_GROUP_ID"

echo ""

echo "===== Application Access Control : 4-3-A (Healthcheck Access) ====="
SERVICE_NETWORK_ID=$(aws vpc-lattice list-service-networks --query "items[?name=='wsc2024-lattice-svc-net'].id" --output text)
aws vpc-lattice list-service-network-service-associations --service-network-identifier "$SERVICE_NETWORK_ID" --query items[*].id --output text

echo ""

echo "===== Application Access Control : 4-3-B (Healthcheck Access) ====="
echo "수 동 채 점 으 로 진 행 합 니 다 ."

echo ""

echo "===== RDBMS : 5-1-A (RDS Configure) ====="
aws rds describe-db-clusters --db-cluster-identifier wsc2024-db-cluster --query 'DBClusters[0].EngineVersion' --output text \
; aws rds describe-db-clusters --db-cluster-identifier wsc2024-db-cluster --query 'DBClusters[0].MasterUsername' --output text \
; aws rds describe-db-instances  --query "DBInstances[?DBClusterIdentifier=='wsc2024-db-cluster'].DBInstanceClass" --output text

echo ""

echo "===== RDBMS : 5-2-A (DB RollBack) ====="
aws rds describe-db-clusters --db-cluster-identifier wsc2024-db-cluster --query "DBClusters[0].BacktrackWindow" --output text

echo ""

echo "===== NoSQL : 6-1-A (Table Configure) ====="
aws dynamodb describe-table --table-name order --query 'Table.KeySchema[?KeyType == `HASH`].AttributeName' --output text

echo ""

echo "===== Container Registry : 7-1-A (ECR Configure) ====="
aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text

echo ""

echo "===== Container Orchestartion : 8-1-A (EKS Configure) ====="
aws eks update-kubeconfig --region us-east-1 --name wsc2024-eks-cluster
aws eks describe-cluster --name wsc2024-eks-cluster --query 'cluster.version' --output text \
; aws eks describe-cluster --name wsc2024-eks-cluster --query 'cluster.logging.clusterLogging[].types' | jq .

echo ""

echo "===== Container Orchestartion : 8-2-A (EKS KMS Encryption) ====="
aws eks describe-cluster --name wsc2024-eks-cluster --query "cluster.encryptionConfig[].provider.keyArn" --output text

echo ""

echo "===== Container Orchestartion : 8-3-A (DB Application Node Configure) ====="
kubectl get node -l app=db -o json | jq -r '.items[].metadata.labels."eks.amazonaws.com/nodegroup"'
kubectl get nodes -l app=db -o json | jq -r '.items[].metadata.name'
kubectl get nodes -l app=db -o json | jq -r '.items[] | .metadata.labels["beta.kubernetes.io/instance-type"]'

echo ""

echo "===== Container Orchestartion : 8-4-A (Other Application Node Configure) ====="
kubectl get node -l app=other -o json | jq -r '.items[].metadata.labels."eks.amazonaws.com/nodegroup"'
kubectl get nodes -l app=other -o json | jq -r '.items[].metadata.name'
kubectl get nodes -l app=other -o json | jq -r '.items[] | .metadata.labels["beta.kubernetes.io/instance-type"]'

echo ""

echo "===== Container Orchestartion : 8-5-A (Application Pods) ====="
kubectl get deploy -n wsc2024

echo ""

echo "===== Ingress : 9-1-A (ALB Configure) ====="
aws elbv2 describe-load-balancers --names wsc2024-alb --query "LoadBalancers[].Scheme" --output text
aws elbv2 describe-load-balancers --names wsc2024-alb --query "LoadBalancers[].Type" --output text

echo ""

echo "===== Ingress : 9-2-A (Customer POST Test) ====="
LBDNS=$(aws elbv2 describe-load-balancers --names wsc2024-alb --query "LoadBalancers[].DNSName" --output text)
curl http://$LBDNS/v1/customer -X POST -H 'Content-Type: application/json' -d '{"id": "3101", "name": "Lee", "gender": "18"}'

echo ""
echo ""

echo "===== Ingress : 9-3-A (Product POST Test) ====="
LBDNS=$(aws elbv2 describe-load-balancers --names wsc2024-alb --query "LoadBalancers[].DNSName" --output text)
curl http://$LBDNS/v1/product -X POST -H 'Content-Type: application/json' -d '{"id": "3201", "name": "kim", "category": "stduent"}'

echo ""
echo ""

echo "===== Ingress : 9-4-A (Order POST Test) ====="
LBDNS=$(aws elbv2 describe-load-balancers --names wsc2024-alb --query "LoadBalancers[].DNSName" --output text)
curl http://$LBDNS/v1/order -X POST -H 'Content-Type: application/json' -d '{"id": "3301", "customerid": "3101", "productid": "3201"}'

echo ""
echo ""

echo "===== Static Page : 10-1-A (S3 Bucket Configure) ====="
aws s3 ls

echo ""

echo "===== Static Page : 10-2-A (S3 Objects) ====="
###for bucket in $(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'wsc2024-s3-static')].Name" --output text); do
aws s3 ls "s3://$STATIC_BUCKET_NAME" --recursive
###done

echo ""

echo "===== Static Page : 10-3-A (S3 Access) ====="
###BUCKET_NAME=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'wsc2024-s3-static')].Name" --output text)
curl https://s3.us-east-1.amazonaws.com/$STATIC_BUCKET_NAME/index.html

echo ""
echo ""

echo "===== CDN : 11-1-A (CloudFront Configure) ====="
aws cloudfront list-distributions --query "DistributionList.Items[].Origins.Items[].DomainName" --output text
aws cloudfront list-distributions --query "DistributionList.Items[].IsIPV6Enabled" --output text
#ID=$(aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text)
aws cloudfront get-distribution-config --id $OLDCDN_ID --query 'DistributionConfig.PriceClass' --output text

echo ""

echo "===== CDN : 11-2-A (Redirect HTTPS) ====="
aws cloudfront list-distributions --query "DistributionList.Items[].DefaultCacheBehavior.ViewerProtocolPolicy" --output text
aws cloudfront list-distributions --query "DistributionList.Items[].CacheBehaviors.Items[].ViewerProtocolPolicy" --output text

echo ""

echo "===== CDN : 11-3-A (Static Page Test) ====="
#DOMAIN=$(aws cloudfront list-distributions --query "DistributionList.Items[].DomainName" --output text)
curl https://$OLDCDN_DNS 2>/dev/null | grep -oP '(?<=<h1>).*?(?=</h1>)'

echo ""

echo "===== CDN : 11-4-A (S3 Caching) ====="
#DOMAIN=$(aws cloudfront list-distributions --query "DistributionList.Items[].DomainName" --output text)
curl -s -I https://$OLDCDN_DNS | grep -i x-cache

echo ""

echo "===== CDN : 11-5-A (Customer API Test) ====="
#DOMAIN=$(aws cloudfront list-distributions --query "DistributionList.Items[].DomainName" --output text)
curl https://${OLDCDN_DNS}/v1/customer?id=3101
echo "-"

echo ""
echo ""

echo "===== CDN : 11-6-A (Product API Test) ====="
#DOMAIN=$(aws cloudfront list-distributions --query "DistributionList.Items[].DomainName" --output text)
curl https://${OLDCDN_DNS}/v1/product?id=3201
echo "-"

echo ""
echo ""

echo "===== CDN : 11-7-A (Order API Test) ====="
#DOMAIN=$(aws cloudfront list-distributions --query "DistributionList.Items[].DomainName" --output text)
curl https://${OLDCDN_DNS}/v1/order?id=3301
echo "-"

echo""
echo""

echo "===== DNS Sec : 12-1 (Public zone) ====="
aws route53 list-hosted-zones --region us-east-1 | grep Name

echo ""
echo ""

echo "===== DNS Sec : 12-2 (Access from extenal) ====="
nslookup q1.${HOSTZONE} 8.8.8.8

echo ""
echo ""

echo "===== DNS Sec : 12-3 (Access from intenal) ====="
cat /etc/hosts
echo "---"
aws route53 list-hosted-zones --region us-east-1 --hosted-zone-type PrivateHostedZone
echo "---"
nslookup q1.${HOSTZONE}

echo ""
echo ""

echo "===== CDN Sec : 13-1 (DNS Lookup) ====="
nslookup cf.${HOSTZONE}

echo ""
echo ""

echo "===== CDN Sec : 13-2 (Certificate) ====="
echo -n "Q" | openssl s_client -connect cf.${HOSTZONE}:443 2> /dev/null | grep i:

echo ""
echo ""

echo "===== CDN Sec : 13-3 (HTTPS) ====="
curl https://cf.${HOSTZONE}/index.html


echo ""
echo ""

echo "===== K8s Sec : Cluster setup ====="
aws eks update-kubeconfig --region us-east-1 --name prod-${PNUMBER}
kubectl apply -f beta.yaml
kubectl apply -f prod.yaml
kubectl apply -f prod-pos.yaml
kubectl apply -f prod-neg.yaml
kubectl apply -f beta-pos.yaml
kubectl apply -f beta-neg.yaml
sleep 10

echo "===== K8s Sec : 14-1 (latest) ====="
echo "!!! NOT pos and neg !!!"
kubectl get pods -n beta | grep day1-beta
echo "---"
kubectl get pods -n prod | grep day1-prod

echo ""
echo ""

echo "===== K8s Sec : 14-2 (prod label) ====="
kubectl get pods -n prod | grep day1-prod-pos
echo "---"
kubectl get pods -n prod | grep day1-prod-neg

echo ""
echo ""


echo "===== K8s Sec : 14-3 (beta label) ====="
kubectl get pods -n beta | grep day1-beta-pos
echo "---"
kubectl get pods -n beta | grep day1-beta-neg
