locals {
  bucketName = "${var.infra_env}-demo-admin-frontend"
}


resource "aws_s3_bucket" "demo_s3_bucket" {
  bucket = local.bucketName
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  versioning {
    enabled = true
  }

  tags = {
    Name        = "${local.bucketName}"
    Environment = "${var.infra_env}"
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.demo_s3_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.demo_s3_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "demo_s3_bucket_public_access" {
  bucket                  = aws_s3_bucket.demo_s3_bucket.id
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true

}
