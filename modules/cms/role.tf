# locals {
#   region = "ap-southeast-1"
# }


# resource "aws_iam_policy" "PolicyAPIGWAuth1" {
#   name        = "PolicyAPIGWAuth1"
#   description = "API Gateway policy created using Amplify CLI"

#   depends_on = [ 
#     aws_api_gateway_rest_api.my_api,
#    ]

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "execute-api:Invoke"
#         ]
#         Resource = [
#           "arn:aws:execute-api:${local.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.my_api.id}/*/${local.route_path}/*",
#           "arn:aws:execute-api:${local.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.my_api.id}/*/${local.route_path}"
#         ]
#       }
#     ]
#   })

# }

# data "aws_caller_identity" "current" {}