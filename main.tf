provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "tmapi_vpc"
    }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "tmapi_igw"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "tmapi_table"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags = {
    Name = "tmapi_subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.default.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags = {
    Name = "tmapi_subnet2"
  }
}

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.default.id
}

resource "aws_route_table_association" "b" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.default.id
}

resource "aws_security_group" "tmapi_sg" {
    vpc_id = aws_vpc.default.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "tmapi_sg"
    }
}

variable "secret_key" {
    description = "Django Secret Key"
    type= string
    sensitive = true
}

resource "aws_instance" "web" {
    ami = "ami-0c101f26f147fa7fd"
    instance_type = "t3.micro"  
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.tmapi_sg.id]

    associate_public_ip_address = true
    user_data_replace_on_change = true

    iam_instance_profile = aws_iam_instance_profile.tmapi_profile.name

    user_data =   <<-EOF
                #!/bin/bash
                set -ex
                yum update -y
                yum install -y yum-utils

                # Install Docker
                yum install -y docker
                service docker start

                # Install AWS CLI
                yum install -y aws-cli

                # Authenticate to ECR
                docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) 437017637763.dkr.ecr.us-east-1.amazonaws.com

                # Pull the image
                docker pull 437017637763.dkr.ecr.us-east-1.amazonaws.com/trailermais/tmapi:latest

                # Run the container
                sudo docker run -d -p 80:8000 \
                --env SECRET_KEY=${var.secret_key} \
                437017637763.dkr.ecr.us-east-1.amazonaws.com/trailermais/tmapi:latest
                EOF
    tags = {
        Name = "tmapi_complete_server"
    }
}

resource "aws_iam_role" "tmapi_role" {
    # name = "tmapi_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_instance_profile" "tmapi_profile" {
    name = "tmapi_profile"
    role = aws_iam_role.tmapi_role.name
}

resource "aws_iam_role_policy_attachment" "tmapi_policy" {
    role = aws_iam_role.tmapi_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}