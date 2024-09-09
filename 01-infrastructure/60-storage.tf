# ================================================================================================================
# Storage
# ================================================================================================================

resource "aws_s3_bucket" "delta_sharing_bucket" {
  bucket        = "fr-bucket-${local.tags["databricks:project"]}-${var.environment}"
  force_destroy = true

  tags = merge(local.tags, { "Name" = "fr-bucket-${local.tags["databricks:project"]}-${var.environment}" })

}