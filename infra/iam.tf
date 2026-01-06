resource "aws_iam_role" "ec2_role" {
  name = "csye6225-ec2-role-${var.profile}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "csye6225-ec2-profile-${var.profile}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "csye6225-s3-policy-${var.profile}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow",
      Action = ["s3:*"],
      Resource = [
        aws_s3_bucket.webapp_files.arn,
        "${aws_s3_bucket.webapp_files.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "csye6225-cloudwatch-agent-policy-${var.profile}-${random_id.policy_suffix.hex}"
  description = "Policy to allow CloudWatch agent to push logs and metrics"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogEventsByField",
          "logs:GetLogGroupFields",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  name = "SecretsManagerReadPolicy-${var.profile}"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = [aws_secretsmanager_secret.db_password_secret.arn]
    }]
  })
}

resource "aws_iam_role_policy" "ec2_kms_policy" {
  name = "EC2_KMS_Policy-${var.profile}"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant",
          "kms:DescribeKey",
          "kms:ReEncrypt*",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = [aws_kms_key.ec2_kms_key.arn]
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_access" {
  name = "SecretsManagerReadAccess-${var.profile}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.db_password_secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_policy" "rds_ec2_access" {
  name = "csye6225-rds-ec2-access-policy-${var.profile}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance",
          "rds:RebootDBInstance"
        ],
        Resource = "arn:aws:rds:us-east-1:${data.aws_caller_identity.current.account_id}:db:csye6225"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeSecurityGroups"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_rds_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.rds_ec2_access.arn
}