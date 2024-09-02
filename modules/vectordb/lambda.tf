#################################
# AWS Lambda Function Query
#################################
resource "aws_lambda_function" "query" {
  function_name = "query-vectordb"
  role          = aws_iam_role.lambda_opensearch_sagemaker_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.root}/src/vectordb/lambda-query/lambda_function.zip"
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = var.sagemaker_endpoint_name
      OPENSEARCH_ENDPOINT = var.opensearch_domain_endpoint
      INDEX_NAME          = var.index_name
      USERNAME            = var.username
      PASSWORD            = var.password
    }
  }

  layers = [
    aws_lambda_layer_version.opensearch_numpy_layer.arn,
  ]

  depends_on = [
    aws_iam_role.lambda_opensearch_sagemaker_role,
  ]
}

output "lambda_function_name" {
  value = aws_lambda_function.query.function_name

}

output "lambda_invoke_arn" {
  value = aws_lambda_function.query.invoke_arn

}

#################################
# AWS Lambda Function Indexing
#################################
resource "aws_lambda_function" "index" {
  function_name = "index-vectordb"
  role          = aws_iam_role.lambda_opensearch_sagemaker_role_index.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.root}/src/vectordb/lambda-index/lambda_function.zip"
  timeout       = 300
  memory_size   = 1024
  layers = [
    aws_lambda_layer_version.opensearch_numpy_layer.arn,
  ]

  environment {
    variables = {
      OPENSEARCH_ENDPOINT = var.opensearch_domain_endpoint
      INDEX_NAME          = var.index_name
      USERNAME            = var.username
      PASSWORD            = var.password
    }
  }
}



resource "aws_s3_bucket_object" "opensearch_numpy_layer_zip" {
  bucket = var.bucket_name
  key    = "lambda-layer/lamda_layer.zip"
  source = "${path.root}/src/vectordb/lambda-index/lambda_layer.zip"
}

resource "aws_lambda_layer_version" "opensearch_numpy_layer" {
  layer_name          = "opensearch-numpy-layer"
  s3_bucket           = var.bucket_name
  s3_key              = aws_s3_bucket_object.opensearch_numpy_layer_zip.key
  compatible_runtimes = ["python3.8"]
  description         = "Lambda layer with numpy and opensearch-py"
}

