# import .env
include .env

setup:
	terraform apply -target=module.settup

build-ecs-video:
	@echo "Building ECS Video"
	docker build -t ecs-video -f ./src/processing-data/ecs-task/Dockerfile ./src/processing-data/ecs-task

push-ecs-video:
	@echo "Pushing ECS Video to ECR"
	aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 308764189237.dkr.ecr.ap-southeast-1.amazonaws.com
	docker tag ecs-video:latest 308764189237.dkr.ecr.ap-southeast-1.amazonaws.com/semantic-repo:ecs-video
	docker push 308764189237.dkr.ecr.ap-southeast-1.amazonaws.com/semantic-repo:ecs-video
	@echo "Pushed ECS Video to ECR"

setup-sagemaker-endpoint:
	@echo "Setting up Sagemaker Endpoint..."
	@echo "Wait for 30 minutes to setup Sagemaker Endpoint..."
	cd src/vectordb/sagemaker-endpoint && python setup.py && cd ../../..
	@echo "Sagemaker Endpoint is ready..."



build: 
	docker build -t sagemaker-processing -f ./src/embedding/sagemaker-processing/Dockerfile ./src/embedding/sagemaker-processing

zip-query:
	cd src/vectordb/lambda-query  && zip -r lambda_function.zip lambda_function.py && cd ../../..

zip-index:
	cd src/vectordb/lambda-index  && zip -r lambda_function.zip lambda_function.py && cd ../../..

zip-embedding:
	cd src/embedding/lambda  && zip -r lambda_function.zip lambda_function.py && cd ../../..

zip-processing:
	cd src/processing-data/lambda  && zip -r lambda_function.zip lambda_function.py && cd ../../..

update-query: zip-query
	aws lambda update-function-code --function-name query-vectordb --zip-file fileb://src/vectordb/lambda-query/lambda_function.zip

update-index: zip-index
	aws lambda update-function-code --function-name index-vectordb --zip-file fileb://src/vectordb/lambda-index/lambda_function.zip

update-embedding: zip-embedding
	aws lambda update-function-code --function-name embedding_data --zip-file fileb://src/embedding/lambda/lambda_function.zip

update-processing: zip-processing
	aws lambda update-function-code --function-name processing_data --zip-file fileb://src/processing-data/lambda/lambda_function.zip

update-all: update-query update-index update-embedding update-processing

sign-up:
	aws cognito-idp admin-create-user \
    --user-pool-id ap-southeast-1_NMAVkHOHj \
    --username admin \
    --user-attributes Name=email,Value=dotu50257@gmail.com \
    --temporary-password Dotu30257@

set-password:
	aws cognito-idp admin-set-user-password \
	--user-pool-id ap-southeast-1_NMAVkHOHj \
	--username admin \
	--password Dotu30257@ \
	--permanent	


login:
	aws cognito-idp initiate-auth \
    --auth-flow USER_PASSWORD_AUTH \
    --auth-parameters USERNAME=admin,PASSWORD=Dotu30257@ \
    --client-id 2u2knjm0pnevcvmih9jojakg64

create-user: sign-up set-password