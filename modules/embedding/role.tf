#################################
# SageMaker processing role
#################################

resource "aws_iam_role" "sagemaker_processing_role" {
  name = "sagemaker-processing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_processing_policy" {
  name        = "sagemaker-processing-policy"
  description = "Policy for SageMaker Processing to access S3, ECR, and logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          # TODO: Replace with your bucket name
          "arn:aws:s3:::${var.bucket_id}",
          "arn:aws:s3:::${var.bucket_id}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
          "ecr:GetAuthorizationToken"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_processing_policy_attachment" {
  policy_arn = aws_iam_policy.sagemaker_processing_policy.arn
  role       = aws_iam_role.sagemaker_processing_role.name
}

output "sagemaker_processing_role_arn" {
  value = aws_iam_role.sagemaker_processing_role.arn
  
}

#################################
# Role for lambda function
#################################
resource "aws_iam_role" "lambda_role" {
  name = "lambda-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-sagemaker-policy"
  description = "Policy for Lambda to invoke SageMaker and access S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:CreateProcessingJob",
          "sagemaker:DescribeProcessingJob",
          "sagemaker:ListProcessingJobs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_id}",
          "arn:aws:s3:::${var.bucket_id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role     = aws_iam_role.lambda_role.name
}

# add basic execution policy to the role
resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "lambda-sagemaker-execution-policy-${var.bucket_id}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

#################################
# IAM Policy for Lambda to Pass SageMaker Role
#################################

resource "aws_iam_policy" "pass_role_policy" {
  name = "lambda-pass-sagemaker-role-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = aws_iam_role.sagemaker_processing_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pass_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.pass_role_policy.arn
}

