resource "aws_s3_bucket" "devternity_images" {
  bucket = "devternity-images"
  acl    = "private"
}

resource "aws_s3_bucket" "devternity_code" {
  bucket = "devternity-code"
  acl    = "private"
}

