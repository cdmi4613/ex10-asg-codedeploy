# ==========================================
# 1. EC2 IAM Role
# ==========================================

resource "aws_iam_role" "asg_node_role" {
  name = "${var.tag_header}asg-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.tag_header}asg-node-role"
  }
}


# ==========================================
# 2. ECR Read
# ==========================================

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.asg_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# ==========================================
# 3. S3 Read
# ==========================================

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.asg_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# ==========================================
# 4. SSM
# ==========================================

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.asg_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ==========================================
# 5. Instance Profile
# ==========================================

resource "aws_iam_instance_profile" "asg_node_profile" {
  name = "${var.tag_header}asg-node-instance-profile"
  role = aws_iam_role.asg_node_role.name
}


# ==========================================
# 6. Amazon Linux 2023 AMI
# ==========================================

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ==========================================
# 7. Launch Template
# ==========================================

resource "aws_launch_template" "asg_lt" {
  name_prefix   = "${var.tag_header}asg-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.asg_security_group_id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_node_profile.name
  }

  user_data = base64encode(
    file("${path.module}/userdata.sh")
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.tag_header}asg-node-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.tag_header}asg-node-volume"
    }
  }

  tags = {
    Name = "${var.tag_header}asg-launch-template"
  }
}


# ==========================================
# 8. Auto Scaling Group
# Private Subnet 3개
# ==========================================

resource "aws_autoscaling_group" "asg" {
  name = "${var.tag_header}codedeploy-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "${var.tag_header}asg-node-instance"
    propagate_at_launch = true
  }
}
