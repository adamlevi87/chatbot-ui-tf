# main/main.tf

data "aws_availability_zones" "available" {
  state = "available"
}

# # loop through the secret map to create data blocks for each secret
# data "aws_secretsmanager_secret" "secrets" {
#   for_each = var.secrets_map
#   name     = each.value
# }
# #loop through the data blocks to extract ARNs for all secrets to be passed to ecs_task_role later on
# locals {
#   secret_arns = [for s in data.aws_secretsmanager_secret.secrets : s.arn]
# }


module "github_oidc" {
  source = "../modules/iam-github-oidc"
  github_org         = var.github_org
  github_repo        = var.github_repo
  aws_iam_openid_connect_provider_github_arn = var.aws_iam_openid_connect_provider_github_arn
}

module "ecr" {
  source = "../modules/ecr"

  name = var.ecr_repository_name
  environment = var.environment
  project_tag  = var.project_tag
  
  # a differnt approach to setting tags
  # tags = {
  #   Project = var.project_tag
  # }
}

module "ecs" {
  source  = "../modules/ecs"
  environment         = var.environment
  project_tag         = var.project_tag
  # subnets ids for NAT
  subnet_ids          = module.vpc_network.private_subnet_ids
  
  security_group_id   = module.security_group.ecs_service_sg_id
  image_repo_url      = module.ecr.repository_url
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  target_group_arn    = module.alb.target_group_arn
  container_name      = var.container_name
  container_port      = var.container_port
  alb_listener_depends_on = module.alb.https_listener_arn  # output from ALB
}

module "ecs_task_role" {
  source = "../modules/ecs-task-role"
  #secret_arns = local.secret_arns
  project_tag = var.project_tag
  environment = var.environment
}

module "ecs_task_definition" {
  source = "../modules/ecs-task-definition"
  environment        = var.environment
  project_tag        = var.project_tag
  execution_role_arn = module.ecs_task_role.ecs_task_execution_role_arn
  task_role_arn      = module.ecs_task_role.ecs_task_execution_role_arn
  image_uri          = "${module.ecr.repository_url}:latest"
  cpu                = var.task_cpu
  memory             = var.task_memory
  container_port     = var.container_port
  container_name     = var.container_name
  # # pass the entire secret map to esc_task_definition
  # secrets_map        = var.secrets_map
}

module "vpc_network" {
  source = "../modules/vpc-network"

  vpc_cidr_block = var.vpc_cidr_block

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr_block, 8, 0),
    cidrsubnet(var.vpc_cidr_block, 8, 1)
  ]
  private_subnet_cidrs = [
  cidrsubnet(var.vpc_cidr_block, 8, 100),
  cidrsubnet(var.vpc_cidr_block, 8, 101)
]

  environment = var.environment
  project_tag   = var.project_tag
}

module "security_group" {
  source          = "../modules/security-group"
  project_tag     = var.project_tag
  environment     = var.environment
  vpc_id          = module.vpc_network.vpc_id
  container_port  = var.container_port
}

module "alb" {
  source                = "../modules/alb"
  project_tag           = var.project_tag
  environment           = var.environment
  vpc_id                = module.vpc_network.vpc_id
  public_subnet_ids     = module.vpc_network.public_subnet_ids
  alb_security_group_id = module.security_group.alb_sg_id
  target_port           = var.container_port
  acm_cert_arn          = module.acm.this_certificate_arn
  acm_depends_on        = module.acm.certificate_validation_status
}

module "route53" {
  source       = "../modules/route53"
  domain_name  = var.domain_name
  subdomain_name = var.subdomain_name
  project_tag  = var.project_tag
  environment  = var.environment
  alb_dns_name = module.alb.alb_dns_name
  allow_destroy_hosted_zone = var.allow_destroy_hosted_zone
}

module "acm" {
  source           = "../modules/acm"
  cert_domain_name  = "${var.subdomain_name}.${var.domain_name}"
  route53_zone_id  = module.route53.zone_id
  project_tag      = var.project_tag
  environment      = var.environment
  route53_depends_on = module.route53.zone_id   # this is just to create a dependency chain
}

module "github_repo_secrets" {
  source          = "../modules/github-repo-secrets"
  repository_name = var.github_repo
  github_secrets  = {
    AWS_ROLE_TO_ASSUME      = module.github_oidc.github_actions_role_arn
    ECS_EXECUTION_ROLE_ARN  = module.ecs_task_role.ecs_task_execution_role_arn
  }
  
  github_variables = {
    AWS_REGION              = var.aws_region
    ECS_CONTAINER_PORT      = var.container_port
    ECS_CPU                 = var.task_cpu
    ECS_MEMORY              = var.task_memory
    ECS_LOG_STREAM_PREFIX   = var.ecs_log_stream_prefix
    ECS_NETWORK_MODE        = var.ecs_network_mode
    ECS_PROTOCOL            = var.ecs_protocol
    ECS_REQUIRES_COMPATIBILITIES = var.ecs_requires_compatibilities

    ECS_CLUSTER_NAME       = module.ecs.cluster_name
    ECS_SERVICE_NAME        = module.ecs.service_name
    ECR_REPOSITORY          = module.ecr.repository_name
    ECS_TASK_FAMILY         = module.ecs_task_definition.task_definition_family
    ECS_CONTAINER_NAME      = module.ecs_task_definition.task_definition_container_name
    ECS_LOG_GROUP           = module.ecs.log_group_name
  }
}