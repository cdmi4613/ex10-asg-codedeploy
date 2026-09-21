# ==========================================
# 1. VPC
# ==========================================

resource "aws_vpc" "ex10_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_header}vpc"
  }
}


# ==========================================
# 2. Internet Gateway
# ==========================================

resource "aws_internet_gateway" "ex10_igw" {
  vpc_id = aws_vpc.ex10_vpc.id

  tags = {
    Name = "${var.tag_header}igw"
  }
}


# ==========================================
# 3. Public Subnets
# ==========================================

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.ex10_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_header}public-1a-subnet"
    Type = "public"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.ex10_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_header}public-1c-subnet"
    Type = "public"
  }
}

resource "aws_subnet" "public_1d" {
  vpc_id                  = aws_vpc.ex10_vpc.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_header}public-1d-subnet"
    Type = "public"
  }
}


# ==========================================
# 4. Private Subnets
# ==========================================

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.ex10_vpc.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.tag_header}private-1a-subnet"
    Type = "private"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.ex10_vpc.id
  cidr_block        = "10.10.12.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.tag_header}private-1c-subnet"
    Type = "private"
  }
}

resource "aws_subnet" "private_1d" {
  vpc_id            = aws_vpc.ex10_vpc.id
  cidr_block        = "10.10.13.0/24"
  availability_zone = "ap-northeast-1d"

  tags = {
    Name = "${var.tag_header}private-1d-subnet"
    Type = "private"
  }
}


# ==========================================
# 5. DB Subnets
# ==========================================

resource "aws_subnet" "db_1a" {
  vpc_id            = aws_vpc.ex10_vpc.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.tag_header}db-1a-subnet"
    Type = "db"
  }
}

resource "aws_subnet" "db_1c" {
  vpc_id            = aws_vpc.ex10_vpc.id
  cidr_block        = "10.10.22.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.tag_header}db-1c-subnet"
    Type = "db"
  }
}

resource "aws_subnet" "db_1d" {
  vpc_id            = aws_vpc.ex10_vpc.id
  cidr_block        = "10.10.23.0/24"
  availability_zone = "ap-northeast-1d"

  tags = {
    Name = "${var.tag_header}db-1d-subnet"
    Type = "db"
  }
}


# ==========================================
# 6. NAT Gateway
# ==========================================

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.tag_header}nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id

  depends_on = [
    aws_internet_gateway.ex10_igw
  ]

  tags = {
    Name = "${var.tag_header}nat-gateway"
  }
}


# ==========================================
# 7. Public Route Table
# ==========================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ex10_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ex10_igw.id
  }

  tags = {
    Name = "${var.tag_header}public-rt"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1d" {
  subnet_id      = aws_subnet.public_1d.id
  route_table_id = aws_route_table.public_rt.id
}


# ==========================================
# 8. Private Route Table
# ==========================================

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ex10_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.tag_header}private-rt"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_1d" {
  subnet_id      = aws_subnet.private_1d.id
  route_table_id = aws_route_table.private_rt.id
}


# ==========================================
# 9. DB Route Table
# 인터넷 경로 없음
# ==========================================

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.ex10_vpc.id

  tags = {
    Name = "${var.tag_header}db-rt"
  }
}

resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.db_rt.id
}

resource "aws_route_table_association" "db_1c" {
  subnet_id      = aws_subnet.db_1c.id
  route_table_id = aws_route_table.db_rt.id
}

resource "aws_route_table_association" "db_1d" {
  subnet_id      = aws_subnet.db_1d.id
  route_table_id = aws_route_table.db_rt.id
}


# ==========================================
# 10. ALB Security Group
# ==========================================

resource "aws_security_group" "alb_sg" {
  name        = "${var.tag_header}alb-sg"
  description = "Security Group for ex10 ALB"
  vpc_id      = aws_vpc.ex10_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_header}alb-sg"
  }
}


# ==========================================
# 11. ASG Security Group
# ==========================================

resource "aws_security_group" "asg_sg" {
  name        = "${var.tag_header}asg-sg"
  description = "Security Group for ex10 private ASG instances"
  vpc_id      = aws_vpc.ex10_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_header}asg-sg"
  }
}
