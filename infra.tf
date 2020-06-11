provider "aws" {
  version = "~> 2.65"
  region  = "us-east-1"
  profile = "sparsh"
}


resource "aws_key_pair" "infra1006-key" {
  key_name   = "infra1006-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCh3VRW+VhUYiHhncTVuN4jtYelnnFNZCbKtpScSH9MO4wl3K3fXWfmOfh4057Wf6S5OfnxlwxjTP6ipg7Gmy21QrgrTDnm/xRU+0gNxEegwNnr2KSEanyS7eDOFiqwxz+QtgKM/cGX3qqkWN24gZ/jIOW/kerr8b5v4QXPfSAjMIy9GvT1f/m7TQdvAjd/vTJ3wSneMasJFvSuhkg0RawIAdtHpCrERTbnMad4nfRg7XH2ZiXR/b0YoMU9JCG20IMP5exYrRh0DXLR7ZpqfOiqLcTsdPLLvbolHy3wpaRNL92mEzAjy4Funbq9aoNv780R+rRz9czjsS883gyYfp1h"
}


resource "aws_security_group" "infra1006-sg" {
  name        = "infra1006-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-c15d32bb"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infra1006-sg"
  }
}


resource "aws_ebs_volume" "infra1006-ebs" {
  availability_zone = "us-east-1a"
  size              = 2

  tags = {
    Name = "infra1006-ebs"
  }
}


resource "aws_volume_attachment" "infra1006-volumeattach" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.infra1006-ebs.id}"
  instance_id = "${aws_instance.infra1006-instance.id}"
}


resource "aws_instance" "infra1006-instance" {
  ami               = "ami-09d95fab7fff3776c"
  instance_type     = "t2.micro"
  key_name          = "infra1006-key"
  security_groups   = [ "infra1006-sg" ]
  availability_zone = "us-east-1a"  
  user_data         = <<-EOF
		#! /bin/bash
		sudo yum install httpd -y
		sudo systemctl start httpd
		sudo systemctl enable httpd
		sudo yum install git -y
		mkfs.ext4 /dev/xvdf1
		mount /dev/xvdf1 /var/www/html
		cd /var/www/html
		git clone https://github.com/Sparsh-Agrawal/Terraform-AWS-1.git .
	EOF

  tags = {
    Name = "infra1006-instance"
  }
}


resource "aws_s3_bucket" "infra1006-s3" {
  bucket = "infra1006-s3"
}


resource "aws_s3_bucket_policy" "infra1006-s3" {
  bucket = "${aws_s3_bucket.infra1006-s3.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
    "Id": "Policy1591793565800",
    "Statement": [
        {
            "Sid": "Stmt1591793552657",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::infra1006-s3/*"
        }
    ]
}
POLICY
}


locals {
  s3_origin_id = "myS3Origin"
}


resource "aws_cloudfront_distribution" "infra1006-cloudfront" {
  origin {
    domain_name = "${aws_s3_bucket.infra1006-s3.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E2S08P3MENZA9K"
    }
  }

  enabled             = true
  comment             = "Some comment"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["DE","CA"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

