variable "env_name" {
  type        = string
  description = "Environment name (e.g. dev)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Target Groups are created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to host the ALB"
}

