variable "availability_zone_names" {
  type    = list(string)
  default = ["us-east-1a", "us-west-1a"]
}

variable "region_names" {
  type    = list(string)
  default = ["us-east-1", "us-west-1"]
}

variable "root_volume_size" {
    type = number
    default = "10"
}
variable "assign_public_ip" {
  type = bool
  default = true
}
variable "ingress_ports" {
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_block = list(string)
  }))
  default = [
    {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_block = ["0.0.0.0/0"]
    }
  ]
}

variable "instance_size" {
  type = string
  default = "t2.micro"
}

variable "ec2_key_pair" {
  type = string
  default = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  sensitive = true
}
