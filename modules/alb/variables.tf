variable "project_tag" {
  type        = string
  description = "Name tag to associate with all ALB resources (e.g., chatbot-ui)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate the ALB and target group with"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to attach the ALB to"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID to attach to the ALB"
}

variable "target_port" {
  type        = number
  description = "Port on which the target container listens (e.g., 3000)"
  default     = 3000
}

variable "acm_cert_arn" {
  type        = string
  description = "ARN of the validated ACM certificate to use with HTTPS listener"
}

variable "acm_depends_on" {
  description = "Used to enforce dependency on ACM certificate validation"
  type        = string
}