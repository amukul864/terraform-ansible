variable "asg_names" {
  description = "List or map of Auto Scaling Group names to monitor"
  type        = list(string)
  default     = []
}

variable "alert_email" {
  description = "Email address to receive SNS alert notifications"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU utilization percentage threshold for the alarm"
  type        = number
  default     = 85
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "dev"
}
