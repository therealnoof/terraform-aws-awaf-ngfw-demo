#
# Provider Declared
#
provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "~/.aws/credentials-commercial-aws"
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

#
# Create the Route Table
#
resource "aws_route_table" "awaf-ngfw-demo-table" {
  vpc_id                = module.vpc.vpc_id
  
    route {
    cidr_block          = "0.0.0.0/0"
    gateway_id          = "${aws_internet_gateway.awaf-ngfw-demo.id}"  
  }
  tags = {
    Name = "awaf-ngfw-demo-route-table"
  }
}

#
# Create the Route Table associations
#
resource "aws_route_table_association" "awaf-ngfw-demo-table-association" {
  subnet_id             = "${aws_subnet.mgmt.id}" 
  route_table_id        = "${aws_route_table.awaf-ngfw-demo-table.id}"
}

resource "aws_route_table_association" "awaf-ngfw-demo-table-association-1" {
  subnet_id             = "${aws_subnet.public.id}" 
  route_table_id        = "${aws_route_table.awaf-ngfw-demo-table.id}"
}

resource "aws_route_table_association" "awaf-ngfw-demo-table-association-2" {
  subnet_id             = "${aws_subnet.internal.id}" 
  route_table_id        = "${aws_route_table.awaf-ngfw-demo-table.id}"
}

resource "aws_route_table_association" "awaf-ngfw-demo-table-association-3" {
  subnet_id             = "${aws_subnet.web.id}" 
  route_table_id        = "${aws_route_table.awaf-ngfw-demo-table.id}"
}

#
# Create the Main Route Table asscociation
#
resource "aws_main_route_table_association" "awaf-ngfw-demo-table-association" {
  vpc_id                = module.vpc.vpc_id
  route_table_id        = "${aws_route_table.awaf-ngfw-demo-table.id}"
}


#
# Create the IGW
#
resource "aws_internet_gateway" "awaf-ngfw-demo" {
  vpc_id                = module.vpc.vpc_id
  tags = {
    Name = "awaf-ngfw-demo"
  }
}

#
# Create Ephemeral EIP for NGFW
#
resource "aws_eip" "ephemeral_ngfw" {
  vpc                         = true
  public_ipv4_pool            = "amazon"
}

#
# Create Ephemeral EIP for NGFW
#
resource "aws_eip" "ephemeral_public" {
  vpc                         = true
  public_ipv4_pool            = "amazon"
}

#
# Create Ephemeral EIP for BIGIP
#
resource "aws_eip" "ephemeral_bigip" {
  vpc                         = true
  public_ipv4_pool            = "amazon"
}

#
# Create Ephemeral EIP for Web Server
# un-comment if you need to access the primary interface
#resource "aws_eip" "ephemeral_web" {
#  vpc                         = true
#  public_ipv4_pool            = "amazon"
#}

#
# Create EIP Association with NGFW MGMT Interface
#
resource "aws_eip_association" "ngfw" {
  network_interface_id        = "${aws_network_interface.awaf-ngfw-demo-ngfw-mgmt.id}"
  allocation_id               = "${aws_eip.ephemeral_ngfw.id}"
}

#
# Create EIP Association with  Interface
#
resource "aws_eip_association" "ngfw-web" {
  network_interface_id        = "${aws_network_interface.awaf-ngfw-demo-public.id}"
  allocation_id               = "${aws_eip.ephemeral_public.id}"
}

#
# Create EIP Association with BIGIP MGMT Interface
#
resource "aws_eip_association" "bigip" {
  network_interface_id        = "${aws_network_interface.awaf-ngfw-demo-bigip-mgmt.id}"
  allocation_id               = "${aws_eip.ephemeral_bigip.id}"
}


# Create EIP Association with Web Server Interface
# un-commment if you need to access the primary interface
#resource "aws_eip_association" "web" {
#  network_interface_id        = "${aws_network_interface.awaf-ngfw-demo-web.id}"
#  allocation_id               = "${aws_eip.ephemeral_web.id}"
#}


#########################
# Create Security Group #
#########################

#
# Create General Security Group for all Instances/Subnets
#
resource "aws_security_group" "awaf-ngfw-demo" {
  vpc_id                = module.vpc.vpc_id
  description           = "awaf-ngfw-demo"
  name                  = "awaf-ngfw-demo"
  tags = {
    Name = "awaf-ngfw-sg"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

##################
# Create Subnets #
##################

#
# Create Management Subnet for all Instances
#
resource "aws_subnet" "mgmt" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "${var.az}"
  tags = {
    Name = "awaf-ngfw-demo-mgmt"
    Group_Name = "awaf-ngfw-demo-mgmt"
  }
}

#
# Create Public Subnet for Firewall Ingress Interface
#
resource "aws_subnet" "public" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.2.0/24"
  availability_zone     = "${var.az}"
  tags = {
    Name = "awaf-ngfw-demo-public"
    Group_Name = "awaf-ngfw-demo-public"
  }
}

#
# Create Internal Subnet for NGFW Egress and F5 External(Ingress)
#
resource "aws_subnet" "internal" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.3.0/24"
  availability_zone     = "${var.az}"
  tags = {
    Name = "awaf-ngfw-demo-internal"
    Group_Name = "awaf-ngfw-demo-internal"
  }
}

#
# Create Web Server Subnet 
#
resource "aws_subnet" "web" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.4.0/24"
  availability_zone     = "${var.az}"
  tags = {
    Name = "awaf-ngfw-demo-web"
    Group_Name = "awaf-ngfw-demo-web"
  }
}

#####################
# Create Interfaces #
#####################

#
# Create Public Network Interface for NGFW
#
resource "aws_network_interface" "awaf-ngfw-demo-public" {
  private_ips           = ["10.0.2.50"]
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.public.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-public"
  }
}

#
# Create Internal Network Interface for NGFW
#
resource "aws_network_interface" "awaf-ngfw-demo-ngfw-internal" {
  private_ips           = ["10.0.3.50"]
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.internal.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-internal"
  }
}

#
# Create MGMT Network Interface for NGFW
#
resource "aws_network_interface" "awaf-ngfw-demo-ngfw-mgmt" {
  private_ips           = ["10.0.1.50"]
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.mgmt.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-mgmt"
  }
}

#
# Create External(Ingress) Network Interface for BIG-IP
#
resource "aws_network_interface" "awaf-ngfw-demo-bigip-external" {
  private_ips           = ["10.0.3.150"]
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.internal.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-external"
  }
}

#
# Create Internal Network Interface for BIG-IP
#
resource "aws_network_interface" "awaf-ngfw-demo-bigip-internal" {
  private_ips           = ["10.0.4.150"]
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.web.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-web"
  }
}

#
# Create MGMT Network Interface for BIG-IP
#
resource "aws_network_interface" "awaf-ngfw-demo-bigip-mgmt" {
  private_ips           = ["10.0.1.150"]
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.mgmt.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-mgmt"
  }
}

#
# Create Internal Network Interface for Web Server
#
resource "aws_network_interface" "awaf-ngfw-demo-web" {
  private_ips           = ["10.0.4.50"]  
  source_dest_check     = "false"
  subnet_id             = "${aws_subnet.web.id}"
  security_groups       = ["${aws_security_group.awaf-ngfw-demo.id}"]
  tags = {
    Name = "awaf-ngfw-demo-web"
  }
}



#######################################
# Vulnerable Web Server Configs Begin #
#######################################

#
# Create Web Server
#

resource "aws_instance" "awaf-ngfw-demo-webserver" {

  count                       = 1
  ami                         = "${var.juiceshop_ami}"  
  instance_type               = "t2.large"
  key_name                    = var.ec2_key_name  
  availability_zone           = "${var.az}"
  user_data                   = <<-EOF
                                #!/bin/bash
                                docker run -d -p 80:3000 bkimminich/juice-shop
                                EOF
  tags = {
    Name = "awaf-ngfw-demo-web-server"
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-web.id}"
    device_index              = 0
  }
}

##############################
# Create IAM role and policy #
##############################

resource "aws_iam_instance_profile" "profile" {
  name = "test_profile"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_policy" "policy" {
  name        = "allow_palo_alto_to_s3_bucket"
  path        = "/"
  description = "A policy to allow the NGFW EC2 instance access to an S3 bucket for bootstrapping."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::bootstrap-palo-alto-demo",
                "arn:aws:s3:::bootstrap-palo-alto-demo/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "role" {
  name = "palo_alto_bootstrap"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

######################
# NGFW Configs Begin #
######################

#
# Create NGFW - Palo Alto
# 
resource "aws_instance" "ngfw" {

  count                       = 1
  ami                         = "${var.paloalto_ami}"  
  instance_type               = "m5.2xlarge"
  iam_instance_profile        = "${aws_iam_instance_profile.profile.name}"
  key_name                    = var.ec2_key_name  
  user_data                   = <<-EOF
                                vmseries-bootstrap-aws-s3bucket=bootstrap-palo-alto-demo
                                EOF
  availability_zone           = "${var.az}"
    tags = {
    Name = "awaf-ngfw-demo-ngfw"
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-ngfw-mgmt.id}"
    device_index              = 0
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-public.id}"
    device_index              = 1
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-ngfw-internal.id}"
    device_index              = 2
  }
}

#
# Create BIG-IP - AWAF PAYG 1Gig
# 
resource "aws_instance" "bigip" {

  count                       = 1
  ami                         = "${var.awaf_ami}"  
  instance_type               = "m5.2xlarge"
  key_name                    = var.ec2_key_name  
  availability_zone           = "${var.az}"
  # build user_data file from template
  user_data = templatefile(
    "${path.module}/f5_onboard.tmpl",
    {
      DO_URL      = var.DO_URL,
      AS3_URL     = var.AS3_URL,
      libs_dir    = var.libs_dir,
      onboard_log = var.onboard_log,
      PWD         = var.password_bigip
    }
  )
  tags = {
    Name = "awaf-ngfw-demo-bigip"
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-bigip-mgmt.id}"
    device_index              = 0
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-bigip-external.id}"
    device_index              = 1
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.awaf-ngfw-demo-bigip-internal.id}"
    device_index              = 2
  }
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
