# ================================================================================================================
# IAM
# ================================================================================================================

resource "aws_iam_instance_profile" "app" {
  name = "fr-role-${local.tags["databricks:project"]}-${var.environment}"
  role = aws_iam_role.app.name
}

resource "aws_iam_role" "app" {
  name        = "fr-role-${local.tags["databricks:project"]}-${var.environment}"
  description = "IAM role for ${local.tags["databricks:project"]}-${var.environment}"

  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
    {
        "Action" : "sts:AssumeRole",
        "Principal" : {
        "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
    }
    ]
}
EOF

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-role-${var.environment}" })
}

resource "aws_iam_role_policy" "test_policy" {
  name = "fr-policy-s3-${local.tags["databricks:project"]}-${var.environment}"
  role = aws_iam_role.app.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.bucket_access.json
}

resource "aws_iam_role_policy_attachment" "ssmcore" {
  role       = aws_iam_role.app.name
  policy_arn = data.aws_iam_policy.ssmcore.arn
}



