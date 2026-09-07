variable "env_name" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
}

variable "role" {
  type        = string
  description = "Role name (e.g. ubuntu)"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where security groups will be created"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances (e.g. Amazon Linux 2023 or Ubuntu 22.04)"
}

variable "public_key_path" {
  type        = string
  description = "Path to local SSH public key file"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where ASG instances will launch"
}

variable "desired_capacity" {
  type        = number
  description = "Override ASG desired capacity"
  default     = null
}

variable "min_size" {
  type        = number
  description = "Override ASG minimum capacity"
  default     = null
}

variable "max_size" {
  type        = number
  description = "Override ASG maximum capacity"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "Override EC2 instance type"
  default     = null
}

variable "target_group_arns" {
  type        = list(string)
  description = "List of ALB Target Group ARNs to attach to the ASG"
  default     = []
}

variable "alb_security_group_id" {
  type        = string
  description = "Security Group ID attached to the ALB"
}

variable "bastion_security_group_id" {
  description = "Security Group ID of the Bastion host allowed to SSH into instances"
  type        = string
  default     = null
}