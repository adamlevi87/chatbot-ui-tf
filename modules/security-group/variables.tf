variable "vpc_id" {
  type        = string
  description = "VPC ID to associate the security group with"
}

variable "project_tag" {
  type        = string
  description = "Project tag for resource naming and tagging"
}

variable "container_port" {
  type        = number
  default     = 3000
  description = "Port to open in the security group for ECS service"
}

variable "environment" {
  description = "environment name for tagging resources"
  type        = string
}