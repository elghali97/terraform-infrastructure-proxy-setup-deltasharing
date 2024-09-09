# ================================================================================================================
# Data Sources
# ================================================================================================================

// ----------- INSTANCE AMI -----------
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]
}

// ----------- POLICIES FOR SSM -----------
data "aws_iam_policy" "ssmcore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "bucket_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.delta_sharing_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.delta_sharing_bucket.bucket}/*"
    ]
  }
}