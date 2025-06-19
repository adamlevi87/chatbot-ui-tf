variable "project_tag" {
  type        = string
  description = "Tag to identify the project"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for Fargate networking"
}

variable "security_group_id" {
  type        = string
  description = "Security group to attach to the service"
}

variable "image_repo_url" {
  type        = string
  description = "Base URL of the container image repo (without tag)"
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the ECS Task Definition"
}

variable "environment" {
  description = "environment name for tagging resources"
  type        = string
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group to attach the ECS service to"
}

variable "container_name" {
  type        = string
  description = "Name of the container to register with the ALB target group"
}

variable "container_port" {
  type        = number
  description = "Port on which the container listens and the ALB forwards traffic"
}

variable "alb_listener_depends_on" {
  type        = string
  description = "Used to enforce dependency on ALB listener before ECS service"
}