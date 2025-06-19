resource "aws_ecs_cluster" "this" {
  name = "${var.project_tag}-cluster"

  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_tag}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    # assign_public_ip = true
  }

  depends_on = [var.alb_listener_depends_on]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_tag}"
  retention_in_days = 7
  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}