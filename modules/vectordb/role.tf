#################################
# Lambda Query Role
#################################
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "lambda_opensearch_sagemaker_role" {
  name = "LambdaOpenSearchSageMakerRoleQuery"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "opensearch_policy" {
  name        = "OpenSearchAccessPolicy"
  description = "Allow Lambda to access OpenSearch domains"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "es:ESHttpPost",
          "es:ESHttpGet",
          "es:ESHttpPut",
          "es:ESHttpDelete"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_policy" {
  name        = "SageMakerInvokePolicy"
  description = "Allow Lambda to invoke SageMaker endpoint"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "CloudWatchLogsPolicy"
  description = "Allow Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:ap-southeast-1:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_opensearch_policy" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role.name
  policy_arn = aws_iam_policy.opensearch_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_sagemaker_policy" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs_policy" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_query" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


#################################
# Lambda Index Role
#################################
resource "aws_iam_role" "lambda_opensearch_sagemaker_role_index" {
  name = "LambdaOpenSearchSageMakerRoleQueryIndex"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role_index.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_read_only_policy" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role_index.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "opensearch_access_policy" {
  role       = aws_iam_role.lambda_opensearch_sagemaker_role_index.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess" # Thay thế bằng chính sách tùy chỉnh nếu cần
}
