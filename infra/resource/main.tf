# ==========================================
# 1. Network
# ==========================================

module "network" {
  source = "./modules/network"

  tag_header = local.tag_header
  vpc_cidr   = "10.10.0.0/16"
}


# ==========================================
# 2. ALB
# ==========================================

module "alb" {
  source = "./modules/alb"

  tag_header = local.tag_header

  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids

  alb_security_group_id = module.network.alb_security_group_id
}


# ==========================================
# 3. ECR
# ==========================================

module "ecr" {
  source = "./modules/ecr"

  repository_name = "${local.tag_header}nginx"
}


# ==========================================
# 4. ASG
# Network 전체(NAT/Route 포함) 완료 후 생성
# ==========================================

module "asg" {
  source = "./modules/asg"

  tag_header = local.tag_header
  region     = local.region

  private_subnet_ids = module.network.private_subnet_ids

  asg_security_group_id = module.network.asg_security_group_id

  target_group_arn = module.alb.target_group_arn

  instance_type = "t3.micro"

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  depends_on = [
    module.network
  ]
}


# ==========================================
# 5. CodeDeploy
# ==========================================

module "codedeploy" {
  source = "./modules/codedeploy"

  tag_header = local.tag_header

  autoscaling_group_name = module.asg.autoscaling_group_name
}


# ==========================================
# 6. CodePipeline
# ==========================================

module "pipeline" {
  source = "./modules/pipeline"

  tag_header = local.tag_header

  github_repository = "cdmi4613/ex10-asg-codedeploy"
  github_branch     = "main"

  codedeploy_application_name = module.codedeploy.application_name

  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name
}
