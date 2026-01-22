variable "aws_region" {
  description = "AWS region for the example resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "example"
}

variable "enable_datadog" {
  description = "Whether to enable Datadog APM logging"
  type        = bool
  default     = false
}
