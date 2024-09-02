# fecth data current
# data "aws_caller_identity" "current" {}

# resource "aws_opensearch_domain" "semantic_search_domain" {
#   domain_name = "semantic-domain"

#   engine_version = "OpenSearch_2.13"

#   cluster_config {
#     instance_type                 = "t3.small.search"
#     instance_count                = 1
#     multi_az_with_standby_enabled = false
#   }

#   advanced_security_options {
#     enabled                        = true
#     anonymous_auth_enabled         = true
#     internal_user_database_enabled = true
#     master_user_options {
#       master_user_name     = var.opensearch_master_user_name
#       master_user_password = var.opensearch_master_user_password
#     }
#   }


#   encrypt_at_rest {
#     enabled = true
#   }

#   domain_endpoint_options {
#     enforce_https       = true
#     tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
#   }

#   node_to_node_encryption {
#     enabled = true
#   }

#   ebs_options {
#     ebs_enabled = true
#     volume_size = 10
#   }

#   access_policies = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "*"
#         },
#         "Action" : "es:*",
#         "Resource" : "arn:aws:es:ap-southeast-1:${data.aws_caller_identity.current.account_id}:domain/semantic-domain/*"
#       }
#     ]
#   })

# }

# fecth opensearch
data "aws_opensearch_domain" "semantic_search_domain" {
  domain_name = var.opensearch_domain_name
}


output "opensearch_domain_name" {
  value = data.aws_opensearch_domain.semantic_search_domain.domain_name
  
}

output "opensearch_domain_endpoint" {
  value = data.aws_opensearch_domain.semantic_search_domain.endpoint

}

output "opensearch_domain_arn" {
  value = data.aws_opensearch_domain.semantic_search_domain.arn
}

output "opensearch_dashboard_endpoint" {
  value = "${data.aws_opensearch_domain.semantic_search_domain.endpoint}/_dashboards"

}
