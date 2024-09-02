import os
import boto3
import subprocess
from botocore.exceptions import NoCredentialsError
import json

S3_BUCKET = os.environ.get('S3_BUCKET')
INPUT_VIDEO_KEY = os.environ.get('INPUT_VIDEO_KEY') 
OUTPUT_FOLDER_PREFIX = os.environ.get('OUTPUT_FOLDER_PREFIX', 'output/')
OUTPUT_MAP_FOLDER = 'mapkeyframes'

s3 = boto3.client('s3')
lambda_client = boto3.client('lambda')

def download_from_s3(bucket, key, download_path):
    try:
        s3.download_file(bucket, key, download_path)
        print(f"Downloaded {key} from {bucket}")
    except NoCredentialsError:
        print("Error: Not authorized")
        raise

def upload_to_s3(bucket, file_path, s3_key):
    try:
        s3.upload_file(file_path, bucket, s3_key)
        print(f"Uploaded {file_path} to {bucket}/{s3_key}")
    except NoCredentialsError:
        print("Error: Not authorized")
        raise

def extract_keyframes(video_path, output_folder):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    cmd = [
        'ffmpeg', '-i', video_path, '-vf', 'select=eq(pict_type\\,I)', 
        '-vsync', 'vfr', '-q:v', '2', f'{output_folder}/%03d.jpg'
    ]
    subprocess.run(cmd)

def generate_map_csv(keyframes_folder, csv_path, video_name):
    with open(csv_path, 'w') as f:
        f.write('FrameNumber,ImagePath\n')
        for image in sorted(os.listdir(keyframes_folder)):
            if image.endswith('.jpg'):
                frame_number = int(image.split('.')[0])
                image_path = os.path.join(keyframes_folder, image)
                f.write(f"{frame_number},{image_path}\n")
    print(f"Created {csv_path}")

def invoke_second_lambda(bucket_name, video_name):
    payload = {
        'bucket_name': bucket_name,
        'video_name': video_name
    }
    print(f"Invoke second lambda with payload: {payload}")
    response = lambda_client.invoke(
        FunctionName="embedding_data",
        InvocationType='Event',  
        Payload=json.dumps(payload)
    )
    print(f"Start Embedding ....: {response}")

def main():
    # Download video
    video_name = os.path.basename(INPUT_VIDEO_KEY)
    video_path = f'/tmp/{video_name}'
    download_from_s3(S3_BUCKET, INPUT_VIDEO_KEY, video_path)

    output_folder_name = os.path.splitext(video_name)[0]
    output_folder = f'/tmp/{output_folder_name}'

    extract_keyframes(video_path, output_folder)

    csv_filename = f'map-keyframe-{output_folder_name}.csv'
    csv_path = f'/tmp/{csv_filename}'
    generate_map_csv(output_folder, csv_path, output_folder_name)

    # Upload keyframes and csv to S3
    for image in os.listdir(output_folder):
        upload_to_s3(S3_BUCKET, os.path.join(output_folder, image), f'{OUTPUT_FOLDER_PREFIX}{output_folder_name}/{image}')
    
    upload_to_s3(S3_BUCKET, csv_path, f'{OUTPUT_MAP_FOLDER}/{csv_filename}')

    # Invoke second lambda
    invoke_second_lambda(S3_BUCKET, output_folder_name)

if __name__ == "__main__":
    main()
