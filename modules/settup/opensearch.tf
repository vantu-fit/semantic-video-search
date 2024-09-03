
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
