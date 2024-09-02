#################################
# AWS Lambda Function
#################################
resource "aws_lambda_function" "processing_data" {
  function_name = "embedding_data"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.root}/src/embedding/lambda/lambda_function.zip"
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      SAGEMAKER_ROLE_ARN = aws_iam_role.sagemaker_processing_role.arn
      S3_BUCKET_NAME     = var.bucket_id
      S3_OUTPUT_PREFIX   = "embeddings/"

    }
  }

  depends_on = [
    aws_iam_role.lambda_role,
  ]
}

resource "aws_lambda_permission" "allow_ecs" {
  statement_id  = "AllowECSTaskInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processing_data.arn
  principal     = "ecs.amazonaws.com"
}

