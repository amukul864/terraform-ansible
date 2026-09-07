output "kms_key_arn" {
  description = "ARN of the KMS key used for secret encryption"
  value       = aws_kms_key.app_secrets.arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.app_secrets.key_id
}

output "ssm_parameter_arn" {
  description = "ARN of the SSM parameter"
  value       = aws_ssm_parameter.db_connection_string.arn
}

output "ssm_parameter_name" {
  description = "Name of the SSM parameter"
  value       = aws_ssm_parameter.db_connection_string.name
}

output "secrets_read_policy_arn" {
  description = "ARN of the IAM policy granting read access to app secrets"
  value       = aws_iam_policy.app_secrets_read.arn
}
