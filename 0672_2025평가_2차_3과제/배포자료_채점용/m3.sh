#!/bin/bash

# 사전 작업
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 1-1
echo ====================
echo "       1-1        "
echo ====================

aws s3 ls | grep dragons-very-secure-website-

# 1-2
echo ====================
echo "       1-2        "
echo ====================

aws cloudfront list-distributions --query DistributionList.Items[].Comment

# 1-3
echo ====================
echo "       1-3        "
echo ====================

echo "Manual test required"

# aws s3api get-bucket-encryption --bucket dragons-very-secure-website-1 --query ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.KMSMasterKeyID
# aws s3api get-bucket-encryption --bucket dragons-very-secure-website-backup-1 --query ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.KMSMasterKeyID

# 1-4
echo ====================
echo "       1-4        "
echo ====================

echo "Manual test required"

cat << EOF > index9091.html
<h1>Dragons are happy!!!</h1>
EOF

# aws s3 cp index9091.html s3://dragons-very-secure-website-1/index9091.html

# check using loops for 3 minutes
# for i in {1..18}; do date; aws s3 ls s3://dragons-very-secure-website-backup-1; echo; sleep 10; done


# 1-5
echo ====================
echo "       1-5        "
echo ====================

echo "Manual test required"

# curl -v https://DRAGONS_CLOUDFRONT_DNS_NAME/index9091.html

# 2-1
echo ====================
echo "       2-1        "
echo ====================

ALB_ARN=$(aws elbv2 describe-load-balancers --names unicorn-alb --query LoadBalancers[].LoadBalancerArn --output text --region ap-northeast-2)
LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --query Listeners[].ListenerArn --output text --region ap-northeast-2)
aws elbv2 describe-rules --listener-arn $LISTENER_ARN --query Rules[].Conditions[].[Field,Values[0],HttpHeaderConfig.HttpHeaderName,HttpHeaderConfig.Values[]] --region ap-northeast-2

# 2-2
echo ====================
echo "       2-2        "
echo ====================

aws secretsmanager describe-secret --secret-id unicorn-password --query RotationEnabled --region ap-northeast-2

# 2-3
echo ====================
echo "       2-3        "
echo ====================

echo "Manual test required"

# # check Last rotated date first
# aws secretsmanager describe-secret --secret-id unicorn-password --query LastRotatedDate --region ap-northeast-2
# # rotate secret
# aws secretsmanager rotate-secret --secret-id unicorn-password --region ap-northeast-2
# # wait until rotation is done
# for i in {1..18}; do date; aws secretsmanager describe-secret --secret-id unicorn-password --query LastRotatedDate --region ap-northeast-2; echo; sleep 10; done

# 2-4
echo ====================
echo "       2-4        "
echo ====================

echo "Manual test required"

# curl -v https://UNICORN_CLOUDFRONT_DNS_NAME/echo?mark=h3110

# 3-1
echo ====================
echo "       3-1        "
echo ====================

aws stepfunctions list-state-machines --region eu-west-1

# 3-2
echo ====================
echo "       3-2        "
echo ====================

aws dynamodb list-tables --region eu-west-1

# 3-3
echo ====================
echo "       3-3        "
echo ====================

aws dynamodb put-item --table-name phoenix --item '{"name": {"S": "balance"}, "value": {"N": "1000"}}' --region eu-west-1
aws dynamodb put-item --table-name phoenix --item '{"name": {"S": "stock"}, "value": {"N": "50"}}' --region eu-west-1

aws stepfunctions start-execution --state-machine-arn arn:aws:states:eu-west-1:$ACCOUNT_ID:stateMachine:phoenix-state-machine --input '{"sales": 20}' --region eu-west-1
sleep 5
aws dynamodb get-item --table-name phoenix --key '{"name": {"S": "balance"}}' --query Item.value.N --output text --region eu-west-1
aws dynamodb get-item --table-name phoenix --key '{"name": {"S": "stock"}}' --query Item.value.N --output text --region eu-west-1

# 3-4
echo ====================
echo "       3-4        "
echo ====================

aws stepfunctions start-execution --state-machine-arn arn:aws:states:eu-west-1:$ACCOUNT_ID:stateMachine:phoenix-state-machine --input '{"sales": 30}' --region eu-west-1
sleep 5
aws dynamodb get-item --table-name phoenix --key '{"name": {"S": "balance"}}' --query Item.value.N --output text --region eu-west-1
aws dynamodb get-item --table-name phoenix --key '{"name": {"S": "stock"}}' --query Item.value.N --output text --region eu-west-1

# 4-1
echo ====================
echo "       4-1        "
echo ====================

aws events list-rules --query Rules[].Name --region eu-west-2

# 4-2
echo ====================
echo "       4-2        "
echo ====================

aws lambda list-functions --query Functions[].FunctionName --region eu-west-2

# 4-3
echo ====================
echo "    4-3, 4-4      "
echo ====================

aws ec2 create-default-vpc --region eu-west-2 --no-cli-pager
GROUP_ID=$(aws ec2 create-security-group --group-name wyvern-security-group-marking --description "wyvern-security-group-marking" --query GroupId --output text --region eu-west-2)

# authorize security group ingress 21 ~ 23 port
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 21-23 --cidr 0.0.0.0/0 --region eu-west-2 --no-cli-pager
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region eu-west-2 --no-cli-pager
aws ec2 describe-security-groups --group-ids $GROUP_ID --query SecurityGroups[].IpPermissions[].[FromPort,ToPort] --region eu-west-2 --no-cli-pager

for i in {1..30}; do date; aws ec2 describe-security-groups --group-ids $GROUP_ID --query SecurityGroups[].IpPermissions[].[FromPort,ToPort] --region eu-west-2 --no-cli-pager; echo; sleep 10; done


