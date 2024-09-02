variable "bucket_video_name" {
  description = "The name of the S3 bucket to store video files"
  type        = string

}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

}

variable "ecs_video_image" {
  description = "The Docker image to use for the video processing ECS task"
  type        = string

}


variable "vpc_id" {
  description = "The ID of the VPC to deploy the ECS cluster into"
  type        = string
  
}

variable "subnet_ids" {
  description = "The IDs of the subnets to deploy the ECS cluster into"
  type        = list(string)
  
}

variable "security_group_id" {
  description = "The ID of the security group to assign to the ECS cluster"
  type        = string
  
}


