import json
import boto3
import os

ecs_client = boto3.client("ecs")
s3_client = boto3.client("s3")

CLUSTER_NAME = os.environ.get("ECS_CLUSTER_NAME")
TASK_DEFINITION = os.environ.get("ECS_TASK_DEFINITION")
SUBNET_ID = os.environ.get("SUBNET_ID")
SECURITY_GROUP_ID = os.environ.get("SECURITY_GROUP_ID")
CONTAINER_NAME = os.environ.get("CONTAINER_NAME")


def lambda_handler(event, context):
    print(event)

    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    print(f"Bucket: {bucket}")
    print(f"Key: {key}")

    response = ecs_client.run_task(
        cluster=CLUSTER_NAME,
        taskDefinition=TASK_DEFINITION,
        launchType="FARGATE",
        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": [SUBNET_ID],
                "securityGroups": [SECURITY_GROUP_ID],
                "assignPublicIp": "ENABLED",
            }
        },
        overrides={
            "containerOverrides": [
                {
                    "name": CONTAINER_NAME,
                    "environment": [
                        {"name": "S3_BUCKET", "value": bucket},
                        {"name": "INPUT_VIDEO_KEY", "value": key},
                        {"name": "OUTPUT_FOLDER_PREFIX", "value": "keyframes/"},
                    ],
                }
            ]
        },
    )

    print("ECS task response: ")
    print(response)

    return {"statusCode": 200, "body": "ECS Task Invoked Successfully"}
