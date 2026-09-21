locals {
  project = "ex10-asg-codedeploy"
  owner   = "std01"
  env     = "test"
  region  = "ap-northeast-1"

  tag_header = "std01-ex10-"

  common_tags = {
    Project = local.project
    Owner   = local.owner
    Env     = local.env
  }
}
