locals {
  username                = "admin"
  password                = "admin"
  index_name              = "semantic-index-test"
  opensearch_domain_name  = var.opensearch_domain_name
  sagemaker_endpoint_name = "clip-model-2024-08-31-15-38-39"
}

#################################
# Settup Module
#################################
module "settup" {
  source = "./modules/settup"

  opensearch_domain_name          = local.opensearch_domain_name
  opensearch_master_user_name     = local.username
  opensearch_master_user_password = local.password

  common_tags = local.common_tags
}

#################################
# Processing Data Module
#################################

module "processing_data" {
  source = "./modules/processing-data"

  # Create ECS Task Definition
  bucket_video_name = var.bucket_video_name
  common_tags       = local.common_tags
  ecs_video_image   = "${module.settup.ecr_repo_url}:ecs-video"

  # VPC Information for ECS Task
  vpc_id            = module.settup.vpc_id
  subnet_ids        = module.settup.public_subnet_ids
  security_group_id = module.settup.security_group_id
}

#################################
# Embedding Module
#################################
module "embedding" {
  source = "./modules/embedding"

  bucket_id = module.processing_data.video_bucket_id

}

#################################
# VectorDB Module
#################################


module "vectordb" {
  source = "./modules/vectordb"

  bucket_name             = module.processing_data.video_bucket_id
  bucket_arn              = module.processing_data.video_bucket_arn
  sagemaker_endpoint_name = local.sagemaker_endpoint_name

  lambda_processing_data_arn = module.processing_data.lambda_processing_data_arn

  opensearch_domain_name     = module.settup.opensearch_domain_name
  opensearch_domain_endpoint = module.settup.opensearch_domain_endpoint
  opensearch_domain_arn      = module.settup.opensearch_domain_arn
  index_name                 = local.index_name
  username                   = local.username
  password                   = local.password
}

#################################
# CMS Module
#################################
module "cms" {
  source = "./modules/cms"

  function_name     = module.vectordb.lambda_function_name
  lambda_invoke_arn = module.vectordb.lambda_invoke_arn
}

