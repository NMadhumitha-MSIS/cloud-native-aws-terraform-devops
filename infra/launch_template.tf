resource "aws_launch_template" "webapp_lt" {
  name          = "csye6225-lt-${var.profile}"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Ensure required variables are set
  lifecycle {
    precondition {
      condition     = var.ami_id != "" && var.ami_id != null
      error_message = "AMI ID must be provided and cannot be empty."
    }
    precondition {
      condition     = var.instance_type != "" && var.instance_type != null
      error_message = "Instance type must be provided and cannot be empty."
    }
    precondition {
      condition     = var.key_name != "" && var.key_name != null
      error_message = "Key name must be provided and cannot be empty."
    }
    precondition {
      condition     = var.github_token != "" && var.github_token != null
      error_message = "GitHub token must be provided and cannot be empty."
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_kms_key.arn
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.tpl", {
    rds_endpoint   = aws_db_instance.webapp_db.address
    db_password    = "ignored"
    s3_bucket_name = aws_s3_bucket.webapp_files.bucket
    github_token   = var.github_token
    secret_arn     = aws_secretsmanager_secret.db_password_secret.arn
    region         = var.aws_region
    profile        = var.profile
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "csye6225-webapp-instance"
    }
  }
}

# Output the rendered user_data for debugging
output "user_data_script" {
  value       = base64decode(aws_launch_template.webapp_lt.user_data)
  description = "Rendered user_data script for debugging"
  sensitive   = true
}