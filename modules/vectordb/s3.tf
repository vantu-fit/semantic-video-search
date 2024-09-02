
#################################
# Lambda Permission to Allow S3 to Invoke
#################################
resource "aws_lambda_permission" "allow_s3_invocation_embeddings" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.index.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}


#################################
# Embeddings Bucket Notification
#################################

resource "aws_s3_bucket_notification" "embeddings_bucket_notification" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.index.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".npy"
    filter_prefix       = "embeddings/"
  }

  lambda_function {
    lambda_function_arn = var.lambda_processing_data_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mp4"
    filter_prefix       = "video/"
  }

}
