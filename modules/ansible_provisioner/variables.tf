variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod)"
  default     = "dev"
}

variable "triggers" {
  type        = map(string)
  description = "Map of arbitrary strings used to force re-execution of provisioners"
  default     = {}
}

variable "ansible_dir" {
  type        = string
  description = "Path to the Ansible root directory relative to the root module"
}
