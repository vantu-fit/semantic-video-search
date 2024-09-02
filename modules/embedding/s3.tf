resource "aws_s3_bucket_object" "script" {
  bucket = var.bucket_id
  key    = "code/script.py"
  source = "${path.root}/src/embedding/sagemaker-processing/script.py"
}

resource "aws_s3_bucket_object" "requirements" {
  bucket = var.bucket_id
  key    = "code/requirements.txt"
  source = "${path.root}/src/embedding/sagemaker-processing/requirements.txt"
}
