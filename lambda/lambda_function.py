import boto3
import os
import json
from datetime import datetime, timezone


EC2_INSTANCE_ID = os.environ.get("EC2_INSTANCE_ID", "")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN", "")
REGION = os.environ.get("REGION", "")


sns_client = boto3.client('sns', region_name=REGION)
ec2_client = boto3.client('ec2', region_name=REGION)



def lambda_handler(event, context):
    print(f"Recieved Event{event}")

    try:
        if EC2_INSTANCE_ID:
            response = ec2_client.reboot_instances(
                InstanceIds=[EC2_INSTANCE_ID,]
            )

            print("successfully rebooted instance")
            
        if SNS_TOPIC_ARN:
            payload = {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "status": "success",
                "action_taken": "ec2_reboot_initiated",
                "instance_id": EC2_INSTANCE_ID
            }

            response = sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="Rebooting instance id due to slower response on api/data",
                Message=json.dumps(payload, indent=2, default=str)
            )

            print(f"successfully sent notification to users/developers {response}")

            return {
                "statusCode": 200,
                "response": "Succesfully rebooted ec2 instance {EC2_INSTANCE}"
            }

    except Exception as e:
        print(f"failed to reboot ec2 instance ${EC2_INSTANCE_ID}: {e}")
        return {
            "statusCode": 200,
            "response": f"Failed {e}"
        }