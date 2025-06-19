# modules/ecr/variables.tf

variable "name" {
  type        = string
  description = "Name of the ECR repository"
}

# variable "tags" {
#   type        = map(string)
#   description = "Tags to apply to the ECR repository"
#   default     = {}
# }

variable "project_tag" {
  type        = string
  description = "Tag to identify the project"
}

variable "environment" {
  description = "environment name for tagging resources"
  type        = string
}