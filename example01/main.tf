terraform {
   required_providers {
     aws = {
        source = "hashicorp/aws"
     }
   }
}
provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "devopsvpc" {
    cidr_block = "69.0.0.0/16"
    tags = {
      "Name" = "devopsvpc"
    }
  
}
resource "aws_subnet" "devopspubsn-1" {
    cidr_block = "69.0.1.0/24"
    vpc_id = aws_vpc.devopsvpc.id
    availability_zone = "us-east-1a"
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
    subnet_id = aws_subnet.devopspubsn-1.id
}

resource "aws_security_group" "devopssg-1" {
  vpc_id = aws_vpc.devopsvpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "TCP"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = -1
  }
  tags = {
    "Name" = "devopssg-1"
  }
}

resource "aws_key_pair" "devopskp" {
  key_name = "devopskp"
  public_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "aws_instance" "devopsec2-1" {
  subnet_id = aws_subnet.devopspubsn-1.id
  vpc_security_group_ids = [ "${aws_security_group.devopssg-1.id}" ]
  instance_type = "t2.micro"
  ami = "ami-08c40ec9ead489470"
  key_name = "devopskp"
  associate_public_ip_address = true
  tags = {
    "Name" = "devopsec2-1"
  }
}
