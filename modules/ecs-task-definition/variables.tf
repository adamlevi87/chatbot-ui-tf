variable "project_tag" {
  type        = string
  description = "Project tag for naming and tagging resources"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM role that ECS uses to pull images and manage logs"
}

variable "image_uri" {
  type        = string
  description = "Full URI of the container image in ECR"
}

variable "cpu" {
  type        = number
  description = "CPU units for the container (e.g. 256, 512, 1024)"
}

variable "memory" {
  type        = number
  description = "Memory (in MiB) for the container (e.g. 512, 1024, 2048)"
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
}

# variable "secrets_map" {
#   type        = map(string)
#   description = "Map of env var input names to Secrets Manager secret names"
# }

variable "task_role_arn" {
  type        = string
  description = "IAM role that the task assumes"
}

variable "environment" {
  description = "environment name for tagging resources"
  type        = string
}

variable "container_name" {
  type        = string
  description = "Name of the container to register with the ALB target group"
}