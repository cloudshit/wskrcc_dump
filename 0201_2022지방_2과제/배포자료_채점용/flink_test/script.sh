
sudo yum update -y
sudo yum -y install java-1.8.0-openjdk.x86_64
mkdir kda-flink-benchmarking-utility
mkdir dynamodb_local
mkdir logs

#Install DynamoDB Local
cd dynamodb_local/
curl https://s3.us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.zip --output dynamodb_local_latest.zip
unzip dynamodb_local_latest.zip
nohup java -jar DynamoDBLocal.jar -sharedDb &

cd ~
mv amazon-kinesis-data-analytics-flink-benchmarking-utility-0.1.jar kda-flink-benchmarking-utility/
mv benchmarking_specs.json kda-flink-benchmarking-utility/
mv create_table_child_job_summary.json kda-flink-benchmarking-utility/
mv create_table_parent_job_summary.json kda-flink-benchmarking-utility/
mv create_table_kinesis_stream.json kda-flink-benchmarking-utility/

cd kda-flink-benchmarking-utility

#Create local dynamdb table
aws dynamodb create-table \
--cli-input-json file://create_table_kinesis_stream.json \
--region us-east-1 \
--endpoint-url http://localhost:8000
aws dynamodb create-table \
--cli-input-json file://create_table_parent_job_summary.json \
--region us-east-1 \
--endpoint-url http://localhost:8000
aws dynamodb create-table \
--cli-input-json file://create_table_child_job_summary.json \
--region us-east-1 \
--endpoint-url http://localhost:8000

#Runs Kinesis Data Analytics Flink Benchmarking Utility

export TZ='Asia/Seoul'
echo 'Running Kinesis Data Generator Application' @ $(date)
java -jar /home/ec2-user/kda-flink-benchmarking-utility/amazon-kinesis-data-analytics-flink-benchmarking-utility-0.1.jar \
	/home/ec2-user/kda-flink-benchmarking-utility/benchmarking_specs.json

