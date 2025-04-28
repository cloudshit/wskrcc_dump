#!/bin/bash

echo "######################"
echo "######################"
echo "### Module 8"
echo "####"
echo "######################"
echo "######################"

echo ================ 8-1 =====================
aws iam list-users --query "Users[?UserName=='myadmin'].UserName"
aws iam list-users --query "Users[?UserName=='Employee'].UserName"

echo ================ 8-2 =====================
aws iam list-attached-user-policies --user-name myadmin 
aws iam list-attached-user-policies --user-name Employee

echo ================ 8-3 =====================
aws iam get-role --role-name wsc2024-instance-role --query 'Role.RoleName'

echo ================ 8-4 =====================
aws iam list-attached-role-policies --role-name wsc2024-instance-role --query "AttachedPolicies[].PolicyArn"

echo ================ 8-5 =====================
aws cloudtrail describe-trails --trail-name-list wsc2024-CT --query "trailList[].Name"

echo ================ 8-6 =====================
aws cloudwatch describe-alarms --alarm-name-prefix wsc2024-gvn-alarm --query 'MetricAlarms[*].AlarmName'

echo ================ 8-7 =====================
aws logs describe-log-groups --log-group-name-prefix wsc2024-gvn-LG --query 'logGroups[].logGroupName' --output text

echo ================ 8-8 ===================== 
aws lambda list-functions --query "Functions[?FunctionName=='wsc2024-gvn-Lambda'].FunctionName"

echo ================ 8-9 ===================== 
USERNAME="Employee"
CREATED_KEYS=$(aws iam create-access-key --user-name "$USERNAME")
ACCESS_KEY_ID=$(echo "$CREATED_KEYS" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$CREATED_KEYS" | jq -r '.AccessKey.SecretAccessKey')
aws configure set aws_access_key_id "$ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY"
sleep 10
aws iam attach-role-policy --role-name wsc2024-instance-role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
rm -rf ~/.aws/*
timeout 180 bash -c 'while [ "$(aws cloudwatch describe-alarms --alarm-names "wsc2024-gvn-alarm" --query "MetricAlarms[0].StateValue" --output text)" != "ALARM" ]; do echo "Waiting for alarm to enter ALARM state..."; sleep 30; done; echo "Alarm is now in ALARM state."'

echo ================ 8-10 =====================
aws iam list-attached-role-policies --role-name wsc2024-instance-role

echo ================ 8-11 =====================
USERNAME="myadmin"
CREATED_KEYS=$(aws iam create-access-key --user-name "$USERNAME")
ACCESS_KEY_ID=$(echo "$CREATED_KEYS" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$CREATED_KEYS" | jq -r '.AccessKey.SecretAccessKey')
aws configure set aws_access_key_id "$ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY"

sleep 10
aws iam attach-role-policy --role-name wsc2024-instance-role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
sleep 180 && aws cloudwatch describe-alarms --alarm-names "wsc2024-gvn-alarm" --query "MetricAlarms[0].StateValue" --output text

echo ================ 8-12 =====================
aws iam list-attached-role-policies --role-name wsc2024-instance-role