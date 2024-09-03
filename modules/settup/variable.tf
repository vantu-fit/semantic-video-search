variable "common_tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
    default     = {
       Environment = "dev"
       ManagedBy   = "Terraform"
    }
  
}

variable "opensearch_domain_name" {
    description = "The name of the OpenSearch domain"
    type        = string
  
  
}

variable "opensearch_master_user_name" {
    description = "The master user name for the OpenSearch domain"
    type        = string
  
}

variable "opensearch_master_user_password" {
    description = "The master user password for the OpenSearch domain"
    type        = string
}

