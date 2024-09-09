# ================================================================================================================
# INSTANCES
# ================================================================================================================

// ----------- Security Group -----------
resource "aws_security_group" "main_instance_sg" {
  name        = "fr-${local.tags["databricks:project"]}-sg-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTPS user access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ingress_ips, var.subnet_cidr_block]
  }

  ingress {
    description = "HTTP user access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ingress_ips, var.subnet_cidr_block]
  }

  ingress {
    description = "HTTP Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.ingress_ips, var.subnet_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-sg-${var.environment}" })
}

// ------------- Servers ---------------
resource "aws_instance" "delta_sharing_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"

  iam_instance_profile   = aws_iam_instance_profile.app.name
  vpc_security_group_ids = [aws_security_group.main_instance_sg.id]
  subnet_id              = aws_subnet.main_subnet.id

  user_data = templatefile(
    "./scripts/install-delta-share.tpl",
    {
      bucket_name  = aws_s3_bucket.delta_sharing_bucket.bucket,
      bearer_token = "eBhh@"
      s3_proxy_url = aws_instance.reverse_proxy_delta_storage.public_dns
    }
  )

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-vm-${var.environment}" })

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_instance" "reverse_proxy_delta_share" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"

  iam_instance_profile   = aws_iam_instance_profile.app.name
  vpc_security_group_ids = [aws_security_group.main_instance_sg.id]
  subnet_id              = aws_subnet.main_subnet.id

  user_data = templatefile(
    "./scripts/install-nginx-delta-share.tpl",
    {
       NGINX_SERVER_NAME = "nginx-deltashare",
       DELTA_SHARE_VM_URL = aws_instance.delta_sharing_instance.public_dns
    }
  )

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-nginx-deltashare-vm-${var.environment}" })

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_instance" "reverse_proxy_delta_storage" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"

  iam_instance_profile   = aws_iam_instance_profile.app.name
  vpc_security_group_ids = [aws_security_group.main_instance_sg.id]
  subnet_id              = aws_subnet.main_subnet.id

  user_data = templatefile(
    "./scripts/install-nginx-storage.tpl",
    {
       NGINX_SERVER_NAME = "nginx-storage",
       NGINX_S3_BUCKET = aws_s3_bucket.delta_sharing_bucket.bucket
    }
  )

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-nginx-s3-vm-${var.environment}" })

  lifecycle {
    ignore_changes = [user_data]
  }
}