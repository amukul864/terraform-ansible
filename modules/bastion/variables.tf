variable "env_name" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Bastion will reside"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID to deploy Bastion"
  type        = string
}

variable "public_key_path" {
  description = "Path to SSH public key for Bastion instance"
  type        = string
  default     = "~/.ssh/id_rsa_aws_dev.pub"
}

variable "ami_id" {
  description = "AMI ID for Bastion Host"
  type        = string
  default     = "ami-00d2dbb426772b03a" # Amazon Linux 2023
}

variable "instance_type" {
  description = "Instance type for Bastion"
  type        = string
  default     = "t3.micro"
}
