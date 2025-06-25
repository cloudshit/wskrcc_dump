#!/bin/bash

# 사전 작업
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws configure set region ap-northeast-2

echo $ACCOUNT_ID

# 1-1
echo ====================
echo "       1-1        "
echo ====================

aws ec2 describe-vpcs --filters Name=tag:Name,Values=[Lambda-VPC] --query Vpcs[].CidrBlock
aws ec2 describe-vpcs --filters Name=tag:Name,Values=[App-VPC] --query Vpcs[].CidrBlock
aws ec2 describe-vpcs --filters Name=tag:Name,Values=[Data-VPC] --query Vpcs[].CidrBlock

# 1-2
echo ====================
echo "       1-2        "
echo ====================

echo "All VPCs: "
aws ec2 describe-vpcs --query Vpcs[].VpcId --output text

echo
echo "VPCs with flow logs: "
aws ec2 describe-flow-logs --query FlowLogs[].ResourceId --output text

# 1-3
echo ====================
echo "       1-3        "
echo ====================

aws ec2 describe-internet-gateways --query InternetGateways[].InternetGatewayId

# 1-4
echo ====================
echo "       1-4        "
echo ====================

aws ec2 describe-nat-gateways --query NatGateways[].NatGatewayId

# 1-5
echo ====================
echo "       1-5        "
echo ====================

aws ec2 describe-vpc-peering-connections --query VpcPeeringConnections[] | head -n 10

# 1-6
echo ====================
echo "       1-6        "
echo ====================

aws ec2 describe-vpc-endpoint-services --query ServiceNames[] | grep vpce

# 1-7
echo ====================
echo "       1-7        "
echo ====================

aws ec2 describe-vpc-endpoints --query VpcEndpoints[] | head -n 10

# 2-1
echo ====================
echo "       2-1        "
echo ====================

lambda_functions=$(aws lambda list-functions --query Functions[].FunctionName --output text)

for lambda_function in $lambda_functions
do
    aws lambda get-function-configuration --function-name $lambda_function --query VpcConfig.VpcId
done

# 2-2
echo ====================
echo "       2-2        "
echo ====================

for lambda_function in $lambda_functions
do
    aws lambda list-tags --resource arn:aws:lambda:ap-northeast-2:$ACCOUNT_ID:function:$lambda_function
done

# 2-3
echo ====================
echo "       2-3        "
echo ====================

api_gateway_ids=$(aws apigateway get-rest-apis --query items[].id --output text)

for api_gateway_id in $api_gateway_ids
do
    aws apigateway get-stages --rest-api-id $api_gateway_id --query "item[].methodSettings.*.metricsEnabled"
done

# 2-4
echo ====================
echo "       2-4        "
echo ====================

for api_gateway_id in $api_gateway_ids
do
    aws apigateway get-stages --rest-api-id $api_gateway_id --query "item[].methodSettings.*.loggingLevel"
done

# 2-5
echo ====================
echo "       2-5        "
echo ====================

for api_gateway_id in $api_gateway_ids
do
    aws apigateway get-stages --rest-api-id $api_gateway_id --query "item[].tracingEnabled"
done

# 2-6
echo ====================
echo "       2-6        "
echo ====================

for api_gateway_id in $api_gateway_ids
do
    aws apigateway get-tags --resource-arn arn:aws:apigateway:ap-northeast-2::/restapis/$api_gateway_id
done

# 3-1
echo ====================
echo "       3-1        "
echo ====================

aws autoscaling describe-auto-scaling-groups --query AutoScalingGroups[].AutoScalingGroupName --output text

# 3-2
echo ====================
echo "       3-2        "
echo ====================

aws ec2 describe-instances --query Reservations[].Instances[].Monitoring.State

# 3-3
echo ====================
echo "       3-3        "
echo ====================

aws ec2 describe-volumes --query Volumes[].Encrypted

# 3-4
echo ====================
echo "       3-4        "
echo ====================

aws ec2 describe-security-groups --query SecurityGroups[].IpPermissions[].IpRanges[].CidrIp

# 4-1
echo ====================
echo "       4-1        "
echo ====================

aws logs describe-log-groups --query logGroups[].logGroupName

# 4-2
echo ====================
echo "       4-2        "
echo ====================

aws cloudwatch list-dashboards --query DashboardEntries[].DashboardName

# 5-1
echo ====================
echo "       5-1        "
echo ====================

aws secretsmanager list-secrets --query SecretList[].Name

# 5-2
echo ====================
echo "       5-2        "
echo ====================

aws secretsmanager describe-secret --secret-id unicorn --query RotationEnabled

# 5-3
echo ====================
echo "       5-3        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].StorageEncrypted

# 5-4
echo ====================
echo "       5-4        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].BackupRetentionPeriod

# 6-1
echo ====================
echo "       6-1        "
echo ====================

aws dynamodb list-tables --query TableNames

# 7-1
echo ====================
echo "       7-1        "
echo ====================

aws codepipeline list-pipelines --query pipelines[].name

# 7-2
echo ====================
echo "       7-2        "
echo ====================

aws deploy list-applications --query applications

# 7-3
echo ====================
echo "       7-3        "
echo ====================

echo "Manual test required"

# 8-1
echo ====================
echo "       8-1        "
echo ====================

echo "Manual test required"

# 8-2
echo ====================
echo "       8-2        "
echo ====================

echo "Manual test required"

# 8-3
echo ====================
echo "       8-3        "
echo ====================

echo "Manual test required"

# 8-4
echo ====================
echo "       8-4        "
echo ====================

echo "Manual test required"
