#################################
# Video Bucket
#################################
resource "aws_s3_bucket" "video" {
  bucket = var.bucket_video_name
  tags   = var.common_tags
}


#################################
# Create folder in S3 bucket
#################################
locals {
  folder_names = ["video", "keyframes", "embeddings", "metadata"]
}

resource "aws_s3_bucket_object" "create_folders" {
  for_each = { for idx, folder_name in local.folder_names : idx => folder_name }

  bucket = aws_s3_bucket.video.id
  key    = "${each.value}/"
}

output "video_bucket_id" {
  value = aws_s3_bucket.video.id
  
}

output "video_bucket_arn" {
  value = aws_s3_bucket.video.arn
  
}
