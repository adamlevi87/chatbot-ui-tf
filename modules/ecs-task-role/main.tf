resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_tag}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = var.project_tag
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.project_tag}-ecs-task-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow pulling images from ECR
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      # Allow writing logs to CloudWatch
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }# ,
      # # Allow reading secrets from Secrets Manager
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "secretsmanager:GetSecretValue",
      #     "secretsmanager:DescribeSecret"
      #   ]
      #   Resource = var.secret_arns
      # }
    ]
  })
}