variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod)"
}

variable "db_connection_string_value" {
  type        = string
  description = "Sensitive database connection string to store in SSM"
  default     = "Server=db.internal;Database=appdb;User=app_user;Password=SuperSecretPass123!;"
  sensitive   = true
}

variable "iam_role_names" {
  type        = list(string)
  description = "List of EC2 instance IAM role names that need access to SSM and KMS secrets"
}
