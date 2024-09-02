locals {
  user_pool_name = "semantic-user-pool"
}

resource "aws_cognito_user_pool" "user_pool" {
  name = local.user_pool_name

}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name            = "semantic-client"
  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = false

  depends_on = [
    aws_cognito_user_pool.user_pool
  ]

  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH",
    "USER_PASSWORD_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "semantic-domain"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  depends_on = [
    aws_cognito_user_pool.user_pool
  ]
}


output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id

  
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}