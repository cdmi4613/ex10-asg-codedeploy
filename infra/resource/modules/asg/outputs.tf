output "autoscaling_group_name" {
  value = aws_autoscaling_group.asg.name
}

output "launch_template_id" {
  value = aws_launch_template.asg_lt.id
}

output "ec2_role_name" {
  value = aws_iam_role.asg_node_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.asg_node_profile.name
}
