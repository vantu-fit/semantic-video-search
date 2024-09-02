#################################
# AWS Lambda Function
#################################
resource "aws_lambda_function" "processing_data" {
  function_name = "processing_data"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.root}/src/processing-data/lambda/lambda_function.zip"
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      ECS_CLUSTER_NAME = aws_ecs_cluster.video_processing.name
      ECS_TASK_DEFINITION = aws_ecs_task_definition.video_processing.family
      SUBNET_ID = var.subnet_ids[0]
      CONTAINER_NAME = local.container_name
      SECURITY_GROUP_ID = var.security_group_id
    }
  }

  depends_on = [
    aws_iam_role.lambda_role,
    aws_ecs_cluster.video_processing,
    aws_ecs_task_definition.video_processing
  ]
}

#################################
# Lambda Permission to Allow S3 to Invoke
#################################
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processing_data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.video.arn
}


output "lambda_processing_data_arn" {
  value = aws_lambda_function.processing_data.arn
  
}