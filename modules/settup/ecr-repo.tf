#################################
# ECR Private Repository
#################################
resource "aws_ecr_repository" "private_repo" {
  name = "semantic-repo"
  
  tags = var.common_tags
}

output "ecr_repo_url" {
  value = aws_ecr_repository.private_repo.repository_url
}


