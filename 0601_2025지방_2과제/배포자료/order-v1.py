import os
import boto3
from datetime import datetime

from time import sleep

QUEUE_URL = os.environ["QUEUE_URL"]
REGION_NAME = os.environ["REGION_NAME"]

client = boto3.client("sqs", region_name=REGION_NAME)

while True:
    print(datetime.now())
    try:
        response = client.receive_message(QueueUrl=QUEUE_URL, MaxNumberOfMessages=1)
    except Exception as e:
        print(e)
        print(flush=True)
        sleep(30)
        continue

    messages = response.get("Messages", [])
    if not messages:
        print("There's nothing in a queue...")

    for message in messages:
        client.delete_message(
            QueueUrl=QUEUE_URL, ReceiptHandle=message["ReceiptHandle"]
        )
        print(message["Body"])

    print(flush=True)
    sleep(30)

