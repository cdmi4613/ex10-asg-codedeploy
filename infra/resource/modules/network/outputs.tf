output "vpc_id" {
  value = aws_vpc.ex10_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
    aws_subnet.public_1d.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
    aws_subnet.private_1d.id
  ]
}

output "db_subnet_ids" {
  value = [
    aws_subnet.db_1a.id,
    aws_subnet.db_1c.id,
    aws_subnet.db_1d.id
  ]
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "asg_security_group_id" {
  value = aws_security_group.asg_sg.id
}
