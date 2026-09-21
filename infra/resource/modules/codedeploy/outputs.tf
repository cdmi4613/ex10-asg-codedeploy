output "application_name" {
  value = aws_codedeploy_app.app.name
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
}

output "service_role_arn" {
  value = aws_iam_role.codedeploy_role.arn
}
