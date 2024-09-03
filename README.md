# Semantic Video Search Vector Database Workshop

## 1. Overview

Introducing the "Semantic Video Search Vector Database" system! This system is designed to provide advanced video search capabilities using semantic search, which goes beyond traditional keyword-based search. By leveraging AWS services like SageMaker, S3, OpenSearch, ECS Fargate, and Lambda, this solution extracts deep semantic features from video content such as objects, actions, and context using machine learning models.ient and scalable video search solution.

![Semantic Video Search Vector Database](./images//semantic-architech.jpg)

## 2. Semantic Video Search Architecture Explanation

#### 1. Processing Data

This module handles the processing of video data uploaded by users.

- **Amazon S3**: 
  - Users upload videos to an S3 bucket, which serves as the storage for raw video files.
  
- **AWS Lambda**: 
  - A Lambda function is triggered when a new video is uploaded to S3. This function initiates the processing workflow.

- **Amazon ECS (Elastic Container Service)**: 
  - Lambda triggers an ECS task to process the video data. The ECS task can involve tasks like extracting keyframes, transcoding, or any other preprocessing required for the videos.

- **Task Output**: 
  - The output from the ECS task (e.g., processed keyframes) is stored back in another S3 bucket for further processing.

#### 2. Embedding

This module is responsible for generating embeddings (feature vectors) from the processed video frames for semantic search.

- **Amazon S3 (Keyframes Bucket)**: 
  - The keyframes generated from the video processing step are stored in another S3 bucket.

- **AWS Lambda**: 
  - A Lambda function is triggered when new keyframes are uploaded. This function orchestrates the embedding process.

- **Amazon SageMaker Processing**: 
  - The Lambda function triggers a SageMaker Processing Job that takes the keyframes from S3, runs them through a deep learning model to extract feature embeddings, and saves these embeddings (vectors) back to an S3 bucket designated for storing vector data.

#### 3. VectorDB (Index and Query)

This module handles indexing the feature vectors in a vector database and enables semantic search through queries.

- **Amazon S3 (Vector Bucket)**: 
  - The vector data generated from the embedding step is stored in another S3 bucket.

- **AWS Lambda**: 
  - A Lambda function is triggered when new vectors are uploaded to the S3 bucket. This function updates the vector database with new entries.

- **Amazon OpenSearch Service**: 
  - The Lambda function inserts the vectors into an Amazon OpenSearch Service cluster, which acts as the vector database. This service is configured to support k-nearest neighbors (k-NN) search to enable efficient and scalable similarity-based searches.

- **Querying**: 
  - When a user initiates a search query, it goes through API Gateway to another Lambda function that queries the OpenSearch Service for similar video embeddings. The results are returned to the user.

#### 4. CMS (Content Management System)

This module manages the user interface and access control for the video search system.

- **Amazon Cognito**: 
  - Provides user authentication and authorization services for secure access to the system. It manages user credentials, roles, and permissions.

- **Amazon S3 (Image Bucket)**: 
  - Stores images and other assets required for the front-end content delivery.

- **Amazon CloudFront**: 
  - A Content Delivery Network (CDN) that caches content from the S3 bucket to ensure fast delivery to users.

- **Amazon API Gateway**: 
  - Acts as the entry point for users to interact with the system's backend services. It routes user requests to various AWS Lambda functions that handle business logic.

- **AWS Lambda**: 
  - Several Lambda functions are invoked by API Gateway to handle different operations like searching videos, user management, etc.


## 2. Quick Start

### 2.1. Setup 
1. Create ECR repository
```bash
cd semantic-video-search
terraform init
```

2. provide the required variables in `terraform.tfvars` file
```bash
bucket_video_name = "bucket-video-tftftftftf"
opensearch_domain_name = "semantic-search-domain"
```
**Note:** You can see how to create opensearch domain in [here](https://vantu-fit.github.io/semantic-video-search/)


3. Create private ECR repository
```bash
make setup
```

4. Build and push the image to ECR
```bash
docker build -t ecs-video -f ./src/processing-data/ecs-task/Dockerfile ./src/processing-data/ecs-task

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <aws account id>.dkr.ecr.ap-southeast-1.amazonaws.com
docker tag ecs-video:latest <aws account id>.dkr.ecr.ap-southeast-1.amazonaws.com/semantic-repo:ecs-video
docker push <aws account id>.dkr.ecr.ap-southeast-1.amazonaws.com/semantic-repo:ecs-video
```

5. Create sagemaker endpoint
- Before running the following command, you need to create a role for sagemaker endpoint. You can see how to create a role and paste the arn of the role in `.env`. Example:
```bash
SAGEMAKER_ENDPOINT_ROLE_ARN=arn:aws:iam::<aws account id>:role/sagemaker-local
```
```bash
cd src/vectordb/sagemaker-endpoint && python setup.py && cd ../../..
```
### 2.2. Deploy
```bash
terraform apply
```

## 3. Usage

#### 3.1 Upload video to S3
```bash
aws s3 cp <video path> s3://<bucket_video_name>/video/
```
#### 3.2 Query by text
1. Sign up with temporary password
```bash
aws cognito-idp admin-create-user \
    --user-pool-id <user pool id> \
    --username admin \
    --user-attributes Name=email,Value=dotu50257@gmail.com \
    --temporary-password Admin@123
```
2. Set password for user
```bash
aws cognito-idp admin-set-user-password \
    --user-pool-id <user pool id> \
    --username admin \
    --password Admin@123 \
    --permanent	
```
3. Login to get access token
```bash
aws cognito-idp initiate-auth \
    --auth-flow USER_PASSWORD_AUTH \
    --auth-parameters USERNAME=admin,PASSWORD=Admin@123 \
    --client-id <client id>
```
- `user pool id` and `client id` can be found in the terraform output after running `terraform apply`
- You will get the access token (idToken) in the response. Use this token to access the APIs.

4. Query by text
```bash
curl --location --request POST 'https://<api gateway id>.execute-api.ap-southeast-1.amazonaws.com/dev/predict' \
--header 'Authorization: Bearer <access token>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "text" : "your query text",
    "top_k" : 5
}'
```
- `api gateway id` can be found in the terraform output after running `terraform apply`

4. TODO
- [ ] Develop UI for the system
- [ ] Hybrid search (text + image)
- [ ] Improve the performance of the system
- [ ] Setup CloudFront for the system












