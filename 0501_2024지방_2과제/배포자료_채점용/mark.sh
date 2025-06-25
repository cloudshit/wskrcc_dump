#!/bin/bash

echo =====1-1=====
aws ec2 describe-vpcs --filter Name=tag:Name,Values=skills-vpc --query "Vpcs[].CidrBlock"
echo

echo =====1-2=====
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-public-subnet-a --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-public-subnet-b --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-private-subnet-a --query "Subnets[].[AvailabilityZone, CidrBlock][]"
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-private-subnet-b --query "Subnets[].[AvailabilityZone, CidrBlock][]"
echo

echo =====1-3=====
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-public-rtb --query "RouteTables[].Routes[].GatewayId"
aws ec2 describe-internet-gateways --filter Name=tag:Name,Values=skills-igw --query "InternetGateways[].InternetGatewayId"
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-private-rtb-a --query "RouteTables[].Routes[].NatGatewayId"
aws ec2 describe-nat-gateways --filter Name=tag:Name,Values=skills-nat-a --query "NatGateways[].NatGatewayId"
aws ec2 describe-route-tables --filter Name=tag:Name,Values=skills-private-rtb-b --query "RouteTables[].Routes[].NatGatewayId"
aws ec2 describe-nat-gateways --filter Name=tag:Name,Values=skills-nat-b --query "NatGateways[].NatGatewayId"
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

echo =====3-1=====
aws codecommit get-repository --repository-name skills-frontend-code --query "repositoryMetadata.repositoryName"
echo

echo =====3-2=====
aws codecommit get-repository --repository-name skills-backend-code --query "repositoryMetadata.repositoryName"
echo

echo =====3-3=====
aws codecommit get-repository --repository-name skills-frontend-code --query "repositoryMetadata.defaultBranch"
echo

echo =====3-4=====
aws codecommit get-repository --repository-name skills-backend-code --query "repositoryMetadata.defaultBranch"
echo

echo =====4-1=====
aws codebuild batch-get-projects --names skills-backend-build --query "projects[*].name"
echo

echo =====4-2=====
aws codebuild batch-get-projects --names skills-backend-build --query "projects[*].logsConfig.cloudWatchLogs.status"
echo

echo =====5-1=====
aws deploy get-application --application-name skills-backend-app --query "application.applicationName"
echo

echo =====5-2=====
aws deploy get-deployment-group --application-name skills-backend-app --deployment-group-name skills-backend-dg --query "deploymentGroupInfo.ecsServices[0]"
echo

echo =====6-1=====
aws s3api list-buckets --query "Buckets[*].Name" | grep "skills-frontend-"
echo

echo =====6-2=====
aws resourcegroupstaggingapi get-resources --tag-filters Key=Name,Values=skills-frontend-cdn --resource-type-filters 'cloudfront' --region us-east-1 --query "ResourceTagMappingList[0].ResourceARN" --output text | sed 's:.*/::' | xargs -I {} aws cloudfront get-distribution --id {} --query "Distribution.DomainName"
echo

echo =====6-3=====
aws resourcegroupstaggingapi get-resources --tag-filters Key=Name,Values=skills-frontend-cdn --resource-type-filters 'cloudfront' --region us-east-1 --query "ResourceTagMappingList[0].ResourceARN" --output text | sed 's:.*/::' | xargs -I {} aws cloudfront get-distribution --id {} --query "Distribution.DistributionConfig.Origins.Items[*].DomainName" | grep "skills-frontend-"
echo

echo =====6-4=====
aws resourcegroupstaggingapi get-resources --tag-filters Key=Name,Values=skills-frontend-cdn --resource-type-filters 'cloudfront' --region us-east-1 --query "ResourceTagMappingList[0].ResourceARN" --output text | sed 's:.*/::' | xargs -I {} aws cloudfront get-distribution --id {} --query "Distribution.DistributionConfig.PriceClass"
echo

echo =====6-5=====
aws resourcegroupstaggingapi get-resources --tag-filters Key=Name,Values=skills-frontend-cdn --resource-type-filters 'cloudfront' --region us-east-1 --query "ResourceTagMappingList[0].ResourceARN" --output text | sed 's:.*/::' | xargs -I {} aws cloudfront get-distribution --id {} --query "Distribution.DomainName"
echo

echo =====7-1=====
aws codepipeline get-pipeline --name skills-frontend-pipeline --query "pipeline.stages[*].[name, actions[*].actionTypeId.provider]"
echo

echo =====7-2=====
aws codepipeline get-pipeline --name skills-backend-pipeline --query "pipeline.stages[*].[name, actions[*].actionTypeId.provider]"
echo

echo =====8-1=====
aws elbv2 describe-load-balancers --names skills-backend-alb --query "LoadBalancers[].LoadBalancerName"
echo

echo =====8-2=====
aws elbv2 describe-load-balancers --names skills-backend-alb --query "LoadBalancers[].Scheme"
echo

CLOUDFRONT_DNS=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Name,Values=skills-frontend-cdn --resource-type-filters 'cloudfront' --region us-east-1 --query "ResourceTagMappingList[0].ResourceARN" --output text | sed 's:.*/::' | xargs -I {} aws cloudfront get-distribution --id {} --query "Distribution.DomainName" --output text)

echo =====9-1=====
echo manual
echo
echo "https://$CLOUDFRONT_DNS/index.html"
echo

echo =====9-2=====
echo manual
echo
echo "https://$CLOUDFRONT_DNS/index.html"
echo

echo =====9-3=====
echo manual
echo
echo "https://$CLOUDFRONT_DNS/index.html"
echo

echo =====9-4=====
echo manual
echo
echo "https://$CLOUDFRONT_DNS/index.html"
echo