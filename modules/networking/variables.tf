variable "env_name" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "cidr_block" {
  type        = string
  description = "Base IPv4 CIDR block for the VPC"
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to spread subnets across"
  default     = null
}

variable "nat_strategy" {
  type        = string
  description = "single = 1 shared NAT GW for all private subnets; per_az = 1 NAT GW per AZ"
  default     = "single"

  validation {
    condition     = contains(["single", "per_az"], var.nat_strategy)
    error_message = "nat_strategy must be either \"single\" or \"per_az\"."
  }
}