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
resource "aws_key_pair" "devopskp" {
  key_name = "devopskp"
  public_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "aws_ebs_volume" "single_ec2_ebs" {
  availability_zone = aws_instance.single_ec2.availability_zone
  size              = 10
  tags = {
    Name = "ec2-ebs-single-demo"
  }
}

resource "aws_volume_attachment" "single_ec2_ebs_att" {
  device_name  = "/dev/sdd"
  volume_id    = aws_ebs_volume.single_ec2_ebs.id
  instance_id  = aws_instance.single_ec2.id
  force_detach = true
}
resource "aws_instance" "single_ec2" {
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  ami = "ami-08c40ec9ead489470"
  key_name = aws_key_pair.devopskp.key_name
  associate_public_ip_address = true
  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
    tags = {
      "Name" = "single_ec2"
    }
  }
  tags = {
    "Name" = "single_ec2"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install xfsprogs -y
sudo mkfs -t xfs /dev/xvdd
sudo mkdir /data
sudo mount /dev/xvdd /data
BLK_ID=$(sudo blkid /dev/xvdd | cut -f2 -d" ")
if [[ -z $BLK_ID ]]; then
  echo "Hmm ... no block ID found ... "
  exit 1
fi
echo "$BLK_ID     /data   xfs    defaults   0   2" | sudo tee --append /etc/fstab
sudo mount -a
echo "Bootstrapping Complete!"
EOF
}
