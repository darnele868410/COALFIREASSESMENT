
#  1 S3 bucket with lifecycle policies
# o Images folder move to glacier after 90 days
# o Logs folder cleared after 90 days 


resource "aws_s3_bucket" "COALFIRE_Buckets" {
  bucket = "testcoalfirebucketforassesment1104558112"
  acl    = "private"

  lifecycle_rule {
    id      = "Images_LFC_GLCR"
    enabled = true

    prefix = "Images/"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

lifecycle_rule {
     id      = "Logs_LFC_CLEAN"
    enabled = true

    prefix = "Logs/"

expiration {
      days = 90
  }


  }
}