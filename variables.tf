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
  default     = "us-east-1"
}

#
# Availability Zone - hard coded
#
variable "az" {
  description = "Set Availability Zone"
  type        = string
  default     = "us-east-1a"
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

#
# Juice Shop AMI - hard coded
#
variable "juiceshop_ami" {
  description = "Custom Public AMI running Ubuntu with Docker"
  type        = string
  default     = "ami-0e3bf8071436d410c"
}

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable DO_URL {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.7.0/f5-declarative-onboarding-1.7.0-3.noarch.rpm"
}
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable AS3_URL {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.14.0/f5-appsvcs-3.14.0-4.noarch.rpm"
}

variable "libs_dir" {
  description = "Directory on the BIG-IP to download the A&O Toolchain into"
  type        = string
  default     = "/config/cloud/aws/node_modules"
}

variable onboard_log {
  description = "Directory on the BIG-IP to store the cloud-init logs"
  type        = string
  default     = "/var/log/startup-script.log"
}

variable "password_bigip" {
  description = "Static password assigned to BIG-IP on boot"
  type        = string
  default     = "F5Twister!"
  
}
