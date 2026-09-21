# ==========================================
# 1. CodeDeploy Service Role
# ==========================================

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.tag_header}codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codedeploy.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.tag_header}codedeploy-service-role"
  }
}


# ==========================================
# 2. CodeDeploy Policy
# ==========================================

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}


# ==========================================
# 3. CodeDeploy Application
# ==========================================

resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"

  name = "${var.tag_header}codedeploy-app"
}


# ==========================================
# 4. Deployment Group
# ==========================================

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name = aws_codedeploy_app.app.name

  deployment_group_name = "${var.tag_header}deployment-group"

  service_role_arn = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = [
    var.autoscaling_group_name
  ]

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true

    events = [
      "DEPLOYMENT_FAILURE"
    ]
  }
}
