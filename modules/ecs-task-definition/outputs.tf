output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN of the ECS Task Definition"
}

output "task_definition_family" {
  value       = aws_ecs_task_definition.this.family
  description = "family of the ECS Task Definition"
}

output "task_definition_container_name" {
  value       = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].name
  description = "family of the ECS Task Definition"
}