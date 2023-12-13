
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "devops-360-demo-localstack"
  tags = {
    Name        = "devops-360-demo-localstack"
    Environment = "local"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "cat.png"
  source = "resources/cat.png"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("resources/cat.png")
  content_type = "image/png"
}
