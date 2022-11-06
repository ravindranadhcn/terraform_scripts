terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "devopsvpc" {
  cidr_block = "69.0.0.0/16"
  tags = {
    "Name" = "devopsvpc"
  }

}
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
resource "aws_subnet" "devopspubsn-1" {
  cidr_block = "69.0.1.0/24"
  vpc_id     = aws_vpc.devopsvpc.id
  #availability_zone = "us-east-1a"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "devopspubsn-1"
  }
}
resource "aws_internet_gateway" "devopsvpcig" {
  vpc_id = aws_vpc.devopsvpc.id

}
resource "aws_route_table" "devopsvpcigrt" {
  vpc_id = aws_vpc.devopsvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devopsvpcig.id
  }
}

resource "aws_route_table_association" "devopsrtassosiation" {
  route_table_id = aws_route_table.devopsvpcigrt.id
  subnet_id      = aws_subnet.devopspubsn-1.id
}

resource "aws_security_group" "devopssg-1" {
  vpc_id = aws_vpc.devopsvpc.id
  ingress {
    cidr_blocks = var.ingress_ports[0].cidr_block
    from_port   = var.ingress_ports[0].from_port
    to_port     = var.ingress_ports[0].to_port
    protocol    = var.ingress_ports[0].protocol
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
  tags = {
    "Name" = "devopssg-1"
  }
}

resource "aws_key_pair" "devopskp" {
  key_name   = "devopskp"
  public_key = var.ec2_key_pair
}
data "aws_ami" "ec2_ami" {
  most_recent = true
  name_regex  = "^ubuntu*"
  owners      = ["amazon"]
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "devopsec2-1" {
  subnet_id                   = aws_subnet.devopspubsn-1.id
  vpc_security_group_ids      = ["${aws_security_group.devopssg-1.id}"]
  instance_type               = var.instance_size
  ami                         = data.aws_ami.ec2_ami.id
  key_name                    = "devopskp"
  associate_public_ip_address = var.assign_public_ip
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    tags = {
      "Name" = "devopsec2-1"
      "FileSystem" : "/root"
    }
  }
  ebs_block_device {
    device_name = "/dev/xvdba"
    volume_size = "10"
    volume_type = "gp3"
    tags = {
      "FileSystem" : "/hana/data"
    }
  }
  user_data = <<-EOF
                #! /bin/bash
                sudo apt install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
  EOF
  tags = {
    "Name" = "devopsec2-1"
  }
}