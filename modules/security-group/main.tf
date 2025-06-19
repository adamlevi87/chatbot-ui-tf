resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.project_tag}-ecs-service-sg"
  description = "Allow traffic from ALB to ECS container"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_tag}-ecs-sg"
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.project_tag}-alb-sg"
  description = "Allow HTTP inbound from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from public internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_tag}-alb-sg"
    Project     = var.project_tag
    Environment = var.environment
  }
}