variable "env_name" {
  description = "Environment name (e.g., dev)"
  type        = string
}

variable "bastion_public_ip" {
  description = "Public IP of Bastion host for ProxyJump"
  type        = string
}

variable "private_key_path" {
  description = "Path to private SSH key used by Ansible"
  type        = string
  default     = "~/.ssh/id_rsa_aws_dev"
}

variable "region" {
  description = "AWS Region for dynamic inventory"
  type        = string
  default     = "ap-south-1"
}

variable "ansible_dir_path" {
  description = "Relative path to the ansible directory"
  type        = string
  default     = "../../ansible"
}
