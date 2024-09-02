import json
import boto3
import os
import time

sagemaker = boto3.client('sagemaker')
role_arn = os.environ.get('SAGEMAKER_ROLE_ARN')
output_prefix = os.environ.get('S3_OUTPUT_PREFIX')


def lambda_handler(event, context):
    bucket_name = event['bucket_name']
    input_prefix = "keyframes/" +  event['video_name'] + "/"
    s3_outdir = input_prefix.split('/')[1]

    print(f"Bucket Name: {bucket_name}")
    print(f"Input Prefix: {input_prefix}")

    processing_job_name = f"processing-job-{int(time.time())}"

    print(f"Processing Job Name: {processing_job_name}")
    
    
    response = sagemaker.create_processing_job(
        ProcessingJobName=processing_job_name,
        RoleArn=role_arn,
        AppSpecification={
            'ImageUri': "763104351884.dkr.ecr.ap-southeast-1.amazonaws.com/pytorch-training:1.9-cpu-py38",
            'ContainerEntrypoint': ['python3', '/opt/ml/processing/code/script.py']
        },
        ProcessingInputs=[
            {
                'InputName': 'input',
                'S3Input': {
                    'S3Uri': f's3://{bucket_name}/{input_prefix}',
                    'LocalPath': '/opt/ml/processing/input',
                    'S3DataType': 'S3Prefix',
                    'S3InputMode': 'File',
                },
            },
            {
                'InputName': 'code',
                'S3Input': {
                    'S3Uri': f's3://{bucket_name}/code/',
                    'LocalPath': '/opt/ml/processing/code',
                    'S3DataType': 'S3Prefix',
                    'S3InputMode': 'File',
                },
            }
        ],
        ProcessingOutputConfig={
            'Outputs': [
                {
                    'OutputName': 'output',
                    'S3Output': {
                        'S3Uri': f's3://{bucket_name}/{output_prefix}',
                        'LocalPath': '/opt/ml/processing/output',
                        'S3UploadMode': 'EndOfJob'
                    },
                },
            ],
        },
        ProcessingResources={
            'ClusterConfig': {
                'InstanceCount': 1,
                'InstanceType': 'ml.m5.xlarge',
                'VolumeSizeInGB': 30,
            },
        },
        Environment={
            'S3_OUTDIR': s3_outdir
        }
    )

    print(response)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'SageMaker Processing Job created successfully',
            'jobName': processing_job_name,
            'response': response
        })
    }
    

    
if __name__ == '__main__':
    lambda_handler({}, {})
