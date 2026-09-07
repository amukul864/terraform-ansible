resource "aws_kms_key" "app_secrets" {
  description             = "KMS key for encrypting ${var.environment} application secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.environment}-app-secrets-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "app_secrets_alias" {
  name          = "alias/${var.environment}-app-secrets"
  target_key_id = aws_kms_key.app_secrets.key_id
}

resource "aws_ssm_parameter" "db_connection_string" {
  name        = "/${var.environment}/app/db_connection_string"
  description = "Database connection string for ${var.environment} application"
  type        = "SecureString"
  value       = var.db_connection_string_value
  key_id      = aws_kms_key.app_secrets.arn

  tags = {
    Environment = var.environment
  }
}
