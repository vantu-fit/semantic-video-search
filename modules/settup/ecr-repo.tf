locals {
  repo_name = "semantic-repo"
}

#################################
# ECR Private Repository
#################################
resource "aws_ecr_repository" "private_repo" {
  name = local.repo_name
  
  tags = var.common_tags
}

output "ecr_repo_url" {
  value = aws_ecr_repository.private_repo.repository_url
}


