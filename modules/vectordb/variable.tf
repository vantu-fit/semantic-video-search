variable "bucket_name" {
  description = "The name of the S3 bucket for videos"
  type        = string
  
}

variable "bucket_arn" {
  description = "The ARN of the S3 bucket for videos"
  type        = string
  
}

variable "lambda_processing_data_arn" {
  description = "The ARN of the Lambda function for processing data"
  type        = string
  
}


variable "sagemaker_endpoint_name" {
  description = "The name of the SageMaker endpoint"
  type        = string
  
}


variable "opensearch_domain_name" {
  description = "The name of the OpenSearch domain"
  type        = string
  
}

variable "opensearch_domain_arn" {
  description = "The ARN of the OpenSearch domain"
  type        = string
  
}


variable "opensearch_domain_endpoint" {
  description = "The endpoint of the OpenSearch domain"
  type        = string
  
}

variable "index_name" {
  description = "The name of the OpenSearch index"
  type        = string
  
}

variable "username" {
  description = "The username for the OpenSearch domain"
  type        = string
  
}

variable "password" {
  description = "The password for the OpenSearch domain"
  type        = string
  
}