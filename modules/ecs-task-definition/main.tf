# # loop through the values of each pair in the map (these are the actual secret names)
# data "aws_secretsmanager_secret" "secrets" {
#   for_each = toset(values(var.secrets_map))
#   name     = each.value
# }

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_tag}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = var.cpu
  memory                  = var.memory
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image_uri
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      # secrets = var.secret_arns
      
      #multiple methods on setting this up:
      #1: loop through var.secrets_map, for each key:pair, bind key to "key" & bind value to "secret_name"
      # then inject the container with a environmental variable which is the secret name (the value from key pairs (key:value) from the map, this will be the actual variable name) and its value should be
      # the ARN from the data block ran previously - called using the secret_name as a label (ex: data.aws_secretsmanager_secret.secrets[OPENAI_API_KEY].arn)
      # secrets = [
      #   for key, secret_name in var.secrets_map : {
      #     name      = secret_name
      #     valueFrom = data.aws_secretsmanager_secret.secrets[secret_name].arn
      #   }
      # ]
      #2: loop through the VALUES of the pairs in the map var.secrets_map, name the values secret_name
      # then inject the container with a environmental variable which is the secret name (the value from key pairs (key:value) from the map, this will be the actual variable name) and its value should be
      # the ARN from the data block ran previously - called using the secret_name as a label (ex: data.aws_secretsmanager_secret.secrets[OPENAI_API_KEY].arn)
      # secrets = [
      #   for secret_name in values(var.secrets_map) : {
      #     name      = secret_name
      #     valueFrom = data.aws_secretsmanager_secret.secrets[secret_name].arn
      #   }
      # ]
    }
  ])

  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}