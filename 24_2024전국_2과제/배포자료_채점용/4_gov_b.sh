#!/bin/bash

echo "######################"
echo "######################"
echo "### Module 4"
echo "####"
echo "######################"
echo "######################"

# 사전 설정
echo "----- 사전 설정 중 -----"
aws configure set default.region eu-central-1
aws configure set default.output json
echo "----- 사전 설정 완료 -----"

# 채점

# 4-1
echo "----- 4-1 -----"
aws ec2 describe-instances --filters "Name=tag:Name,Values=wsi-bastion-ec2" --query "Reservations[*].Instances[*].[InstanceId, InstanceType, IamInstanceProfile.Arn]" --output text \
 | awk '{print $1,$2,$3}' | xargs -I {} bash -c 'INSTANCE_PROFILE_NAME=$(echo {} | awk -F"/" "{print \$NF}") \
 ; ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --query "InstanceProfile.Roles[*].RoleName" --output text) \
 ; echo "Instance ID: $(echo {} | awk "{print \$1}")"; echo "Instance Type: $(echo {} | awk "{print \$2}")" \
 ; aws iam list-attached-role-policies --role-name $ROLE_NAME --query "AttachedPolicies[*].[PolicyName, PolicyArn]" --output text'
echo "---------------"

# 4-2
echo "----- 4-2 -----"
aws iam get-user --user-name wsi-project-user --query "User.UserName" --output text \
; aws iam list-attached-user-policies --user-name wsi-project-user --query 'AttachedPolicies[*].PolicyName' --output text \
; aws iam list-user-policies --user-name wsi-project-user --query 'PolicyNames' --output text
echo "---------------"

# 4-3
echo "----- 4-3 -----"
aws cloudtrail describe-trails --query 'trailList[?Name==`wsi-project-trail`].Name' --output json
echo "---------------"

# 4-4
echo "----- 4-4 -----"
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
IAM_USER=$(aws iam get-user --user-name wsi-project-user --query "User.UserName" --output text)
echo "아래 정보로 AWS 콘솔로 접속합니다."
echo "계정 ID(12자리): $ACCOUNT_ID"
echo "사용자 이름: $IAM_USER"
echo "암호: <설정 한 사용자 암호>"
echo "---------------"

# Prompt the user to confirm login
read -p "로그인하셨나요? 만약 그렇다면 'y'를 눌러 계속하십시오: " user_input

# Check the user's input
if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
    date "+%Y-%m-%d.%H.%M.%S"
    echo "4분 소요"
    sleep 240
    
    # 4-5
    echo "----- 4-5 -----"
    LOG_GROUP_NAME="wsi-project-login"
    aws logs describe-log-groups --log-group-name-prefix $LOG_GROUP_NAME --query 'logGroups[?logGroupName==`wsi-project-login`].logGroupName' --output json
    LATEST_LOG_STREAM=$(aws logs describe-log-streams --log-group-name $LOG_GROUP_NAME --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text)
    aws logs get-log-events --log-group-name $LOG_GROUP_NAME --log-stream-name $LATEST_LOG_STREAM --limit 1 --query 'events[-1].{timestamp:timestamp, message:message}' --output json | jq -r '"\(.timestamp)\t\(.message)"' | while IFS=$'\t' read -r timestamp message; do echo -e "$(date -d @$((timestamp / 1000)) '+%Y-%m-%d-%H:%M:%S')\t$message"; done
    echo "---------------"
else
    echo "다시 하기..."
    exit 1
fi

# 4-6
echo "----- 4-6 -----"
aws lambda get-function --function-name wsi-project-log-function --query 'Configuration.FunctionName' --output json
echo "---------------"
