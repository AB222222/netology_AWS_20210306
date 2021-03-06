provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "my1backet"
    key    = "project/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  mytest_instance_type_map = {
    stage = "t2.micro"
    prod = "t2.micro"
  }
}

locals {
  mytest_instance_count_map = {
    stage = 1
    prod = 2
  }
}

resource "aws_instance" "mytest" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.mytest_instance_type_map[terraform.workspace]
  count = local.mytest_instance_count_map[terraform.workspace]

  tags = {
    Name = "HelloWorld"
  }

  lifecycle {
    create_before_destroy = true  
  }
}

