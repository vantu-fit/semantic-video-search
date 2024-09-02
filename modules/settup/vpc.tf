#################################
# VPC
#################################
resource "aws_vpc" "main" {
  cidr_block = "172.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = var.common_tags
}

#################################
# Internet Gateway
#################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = var.common_tags
}

#################################
# Public Subnets
#################################
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "172.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = var.common_tags
}

#################################
# Private Subnets
#################################
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "172.0.${count.index + 10}.0/24"
  tags = var.common_tags
}

#################################
# Route Tables
#################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = var.common_tags
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = var.common_tags
}

resource "aws_route_table_association" "private" {
  count = 2
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#################################
# Security Groups
#################################
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow http traffic
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow https traffic
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow ssh traffic
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags = var.common_tags
}

output "vpc_id" {
  value = aws_vpc.main.id
  
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
  
}

output "security_group_id" {
  value = aws_security_group.default.id
  
}

