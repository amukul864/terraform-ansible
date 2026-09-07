resource "aws_iam_policy" "app_secrets_read" {
  name        = "${var.environment}-app-secrets-read-policy"
  description = "Allows least-privilege read access to the app DB connection string SSM parameter and KMS decryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMGetParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = aws_ssm_parameter.db_connection_string.arn
      },
      {
        Sid    = "KMSDecryptAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.app_secrets.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  for_each   = toset(var.iam_role_names)
  role       = each.value
  policy_arn = aws_iam_policy.app_secrets_read.arn
}
