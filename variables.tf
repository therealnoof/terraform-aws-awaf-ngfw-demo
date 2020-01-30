#
# This outputs to the console asking for the SSH key for the EC2 instances
# You should have created a key pair in advance
#
variable "ec2_key_name" {
  description = "AWS EC2 Key name for SSH access"
  type        = string
}

#
# Region - hard coded
#
variable "region" {
  description = "Set the Region"
  type        = string
  default     = "us-gov-west-1"
}

#
# Availability Zone - hard coded
#
variable "az" {
  description = "Set Availability Zone"
  type        = string
  default     = "us-gov-west-1a"
}

#
# F5 AWAF AMI - hard coded
#
variable "awaf_ami" {
  description = "PAYG F5 AWAF 1GIG"
  type        = string
  default     = "ami-0c83f27f3b93e10f9"
}

#
# Palo Alto AMI - hard coded
#
variable "paloalto_ami" {
  description = "Palo Alto NGFW PAYG Bundle 2"
  type        = string
  default     = "ami-016bb6fab3b0571f9"
}