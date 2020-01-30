#
# Provider Declared
#
provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}

#
# Create a random id
#
resource "random_id" "id" {
  byte_length = 2
}

###########################
# Core Networking Created #
###########################

#
# Create the VPC 
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = format("%s-vpc-%s", local.prefix, random_id.id.hex)
  cidr                 = local.cidr
  azs                  = ["${var.az}"]
  enable_nat_gateway   = "true"
  enable_dns_hostnames = "true"
}










#############
# Variables #
#############

#
# Variables used by this example
#
locals {
  prefix            = "tf-aws-awaf-ngfw-demo"
  cidr              = "10.0.0.0/16"
  allowed_mgmt_cidr = "0.0.0.0/0"
  allowed_app_cidr  = "0.0.0.0/0"
}
