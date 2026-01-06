resource "aws_secretsmanager_secret" "db_password_secret" {
  name                    = "csye6225-db-password-v2"
  description             = "RDS password stored securely in Secrets Manager"
  kms_key_id              = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window_in_days = 0

  tags = {
    Name        = "csye6225-db-password"
    Environment = "dev"
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = random_password.db_password.result
}

output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.db_password_secret.arn
}
