#!/bin/bash

# 사전 작업
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws configure set region ap-northeast-2

# 1-1
echo ====================
echo "       1-1        "
echo ====================

echo "All VPCs: "
aws ec2 describe-vpcs --query Vpcs[].VpcId --output text

echo
echo "VPCs with flow logs: "
aws ec2 describe-flow-logs --query FlowLogs[].ResourceId --output text

# 1-2
echo ====================
echo "       1-2        "
echo ====================

vpc_ids=$(aws ec2 describe-vpcs --query Vpcs[].VpcId --output text)

for vpc_id in $vpc_ids
do
    aws ec2 describe-vpcs --vpc-id $vpc_id --query Vpcs[].Tags
done

# 2-1
echo ====================
echo "       2-1        "
echo ====================

buckets=$(aws s3api list-buckets --query Buckets[].Name --output text)

for bucket in $buckets
do
    aws s3api get-bucket-policy --bucket $bucket --output text
done

# 2-2
echo ====================
echo "       2-2        "
echo ====================

for bucket in $buckets
do
    aws s3api get-bucket-tagging --bucket $bucket
done

# 3-1
echo ====================
echo "       3-1        "
echo ====================

distributions=$(aws cloudfront list-distributions --query DistributionList.Items[].Id --output text)

for distribution in $distributions
do
    aws cloudfront get-distribution --id $distribution --query Distribution.DistributionConfig.DefaultCacheBehavior.ViewerProtocolPolicy --output text
done

# 3-2
echo ====================
echo "       3-2        "
echo ====================

for distribution in $distributions
do
    aws cloudfront get-distribution --id $distribution --query Distribution.DistributionConfig.Logging.Enabled
done

# 3-3
echo ====================
echo "       3-3        "
echo ====================

for distribution in $distributions
do
    aws cloudfront get-distribution --id $distribution --query Distribution.DistributionConfig.WebACLId
done

# 3-4
echo ====================
echo "       3-4        "
echo ====================

for distribution in $distributions
do
    aws cloudfront list-tags-for-resource --resource arn:aws:cloudfront::$ACCOUNT_ID:distribution/$distribution
done

# 4-1
echo ====================
echo "       4-1        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].StorageEncrypted

# 4-2
echo ====================
echo "       4-2        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].MasterUserSecret

# 4-3
echo ====================
echo "       4-3        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].MonitoringInterval

# 4-4
echo ====================
echo "       4-4        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].EnabledCloudwatchLogsExports

# 4-5
echo ====================
echo "       4-5        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].BackupRetentionPeriod

# 4-6
echo ====================
echo "       4-6        "
echo ====================

rds_clusters=$(aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].DBClusterIdentifier --output text)

for rds_cluster in $rds_clusters
do
    aws rds describe-db-cluster-snapshots --db-cluster-identifier $rds_cluster --no-cli-pager
done

# 4-7
echo ====================
echo "       4-7        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].DeletionProtection

# 4-8
echo ====================
echo "       4-8        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[aurora-mysql] --query DBClusters[].TagList

# 5-1
echo ====================
echo "       5-1        "
echo ====================

tables=$(aws dynamodb list-tables --query TableNames --output text)

for table in $tables
do
    aws dynamodb describe-table --table-name $table --query Table.SSEDescription.SSEType --output text
done

# 5-2
echo ====================
echo "       5-2        "
echo ====================

for table in $tables
do
    aws dynamodb describe-continuous-backups --table-name $table --query ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus --output text
done

# 5-3
echo ====================
echo "       5-3        "
echo ====================

for table in $tables
do
    aws dynamodb list-backups --table-name $table
done

# 5-4
echo ====================
echo "       5-4        "
echo ====================

for table in $tables
do
    aws dynamodb describe-table --table-name $table --query Table.DeletionProtectionEnabled
done

# 5-5
echo ====================
echo "       5-5        "
echo ====================

for table in $tables
do
    aws dynamodb list-tags-of-resource --resource-arn arn:aws:dynamodb:ap-northeast-2:$ACCOUNT_ID:table/$table
done


# 6-1
echo ====================
echo "       6-1        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[docdb] --query DBClusters[].StorageEncrypted

# 6-2
echo ====================
echo "       6-2        "
echo ====================

docdb_clusters=$(aws rds describe-db-clusters --filters Name=engine,Values=[docdb] --query DBClusters[].DBClusterIdentifier --output text)

for docdb_cluster in $docdb_clusters
do
    aws rds describe-db-cluster-snapshots --db-cluster-identifier $docdb_cluster --no-cli-pager
done

# 6-3
echo ====================
echo "       6-3        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[docdb] --query DBClusters[].DeletionProtection

# 6-4
echo ====================
echo "       6-4        "
echo ====================

aws rds describe-db-clusters --filters Name=engine,Values=[docdb] --query DBClusters[].TagList

# 7-1
echo ====================
echo "       7-1        "
echo ====================

aws ecr describe-repositories --query repositories[].imageTagMutability

# 7-2
echo ====================
echo "       7-2        "
echo ====================

aws ecr describe-repositories --query repositories[].encryptionConfiguration.encryptionType

# 7-3
echo ====================
echo "       7-3        "
echo ====================
repositories=$(aws ecr describe-repositories --query repositories[].repositoryArn --output text)

for repository in $repositories
do
    aws ecr list-tags-for-resource --resource-arn $repository
done
