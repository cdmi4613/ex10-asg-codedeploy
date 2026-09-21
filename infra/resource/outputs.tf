# ==========================================
# Network
# ==========================================

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "db_subnet_ids" {
  value = module.network.db_subnet_ids
}


# ==========================================
# ALB
# ==========================================

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}


# ==========================================
# ECR
# ==========================================

output "ecr_repository_url" {
  value = module.ecr.repository_url
}


# ==========================================
# ASG
# ==========================================

output "autoscaling_group_name" {
  value = module.asg.autoscaling_group_name
}

output "launch_template_id" {
  value = module.asg.launch_template_id
}


# ==========================================
# CodeDeploy
# ==========================================

output "codedeploy_application_name" {
  value = module.codedeploy.application_name
}

output "codedeploy_deployment_group_name" {
  value = module.codedeploy.deployment_group_name
}


# ==========================================
# CodePipeline
# ==========================================

output "codepipeline_name" {
  value = module.pipeline.pipeline_name
}

output "github_connection_arn" {
  value = module.pipeline.github_connection_arn
}

output "github_connection_status" {
  value = module.pipeline.github_connection_status
}
