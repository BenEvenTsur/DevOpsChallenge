locals {
  ubuntu_focal_fossa_ami = "ami-0ee8244746ec5d6d4"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }

  required_version = ">= 1.2.1"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

module "hello_world_website" {
  source = "./modules/hello_world_website"

  ami_id                 = local.ubuntu_focal_fossa_ami
  instance_type          = "t3.nano"
  ec2_instances_quantity = 2
  http_port              = 80
}