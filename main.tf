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
}