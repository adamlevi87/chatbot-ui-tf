variable "project_tag" {
  type        = string
  description = "Project tag for naming and tagging the ECS task execution role"
}

variable "environment" {
  description = "environment name for tagging resources"
  type        = string
}

# variable "secret_arns" {
#   type        = list(string)
#   description = "List of secret ARNs for IAM permissions"
# }