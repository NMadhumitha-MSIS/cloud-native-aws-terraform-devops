resource "aws_kms_key" "ec2_kms_key" {
  description             = "EC2 encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableRootAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key",
        Effect = "Allow",
        Principal = {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}

resource "null_resource" "kms_rotation_ec2" {
  triggers = {
    rotation_period_in_days = 90
  }
}

resource "aws_kms_alias" "ec2_alias" {
  name          = "alias/ec2-key"
  target_key_id = aws_kms_key.ec2_kms_key.key_id
}

resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow RDS Use"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS" }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "rds-kms-key"
    Purpose = "RDS encryption"
  }
}
resource "aws_kms_alias" "rds_alias" {
  name          = "alias/rds-key"
  target_key_id = aws_kms_key.rds_kms_key.key_id
}

resource "null_resource" "kms_rotation_rds" {
  triggers = {
    rotation_period_in_days = 90
  }
}

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 bucket encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow S3 Use"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.ec2_role.arn }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "s3-kms-key"
    Purpose = "S3 encryption"
  }
}

resource "null_resource" "kms_rotation_s3" {
  triggers = {
    rotation_period_in_days = 90
  }
}

resource "aws_kms_alias" "s3_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3_kms_key.key_id
}

resource "aws_kms_key" "secretsmanager_kms_key" {
  description             = "KMS key for Secrets Manager encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow EC2 Use"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.ec2_role.arn }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "secretsmanager-kms-key"
    Purpose = "Secrets encryption"
  }
}

resource "null_resource" "kms_rotation_secretsmanager" {
  triggers = {
    rotation_period_in_days = 90
  }
}

resource "aws_kms_alias" "secrets_manager_alias" {
  name          = "alias/secrets_manager-key"
  target_key_id = aws_kms_key.secretsmanager_kms_key.key_id
}