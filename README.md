![f5](https://user-images.githubusercontent.com/18743780/72476144-74b9cd80-37ba-11ea-82f3-81d37306b20e.png)![aws](https://user-images.githubusercontent.com/18743780/72476149-76839100-37ba-11ea-90ad-2da2bcfe2ecb.png)![terraform](https://user-images.githubusercontent.com/18743780/72476158-7a171800-37ba-11ea-95dc-1f58f7974150.png)

# Terraform AWAF NGFW Demo

Terraform Version supported = Terraform v0.12.9

AWS Provider version supported = v2.43.0

This Terraform will deploy a fully bootstrapped infrastructure for the purposes of demoing AWAF vs. NGFW capabilities.

Some enterprises believe that a NGFW will protect their apps from layer 7 attack types.  This is simply not true.  While a NGFW does have some layer 7 functionality...it does not protect apps from the OWASP top 10.  Simply stated a NGFW is NOT a Web Application Firewall!  This demo will help demostrate.

The Terraform will launch a fully bootstrapped NGFW(Palo Alto), BIG-IP(AWAF), and a vulnerable web server hosting the Juice Shop application.

Three public IP's will be assigned and outputted to the terminal after launch.  You will need to wait about 10 to 15 minutes for the infrastructure to fully boot up.  After boot up completes, open a web browser pointing to the eip_for_Web_Application IP.  

The BIG-IP has a very generic WAF policy applied to the virtual but it is in blocking mode. Feel free to fork this repo and create your own policy. You will need to change the Github URL in as3 declaration inside of the f5_onboard.tmpl file.

Use your favorite web attack tools or download Kali Linux, Burp Suite or OWASP Zap for example.
# IMPORTANT DoS or DDoS attack types are not allowed against AWS infrastructure
Please read the AWS Policy for Penetration Testing 
https://aws.amazon.com/security/penetration-testing/

# What Do I Need To Launch This Sweet Demo?
1. You need Terraform installed https://www.terraform.io/downloads.html
2. You need Git installed https://gist.github.com/derhuerst/1b15ff4652a867391f03
3. You need an AWS account with programmatic access
4. You need AWS API credentials(Access/Secret keys) https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
5. You will need to create a credential file in the Terraform /.aws directory. Place your access and secret key in this file.
Example:
[default]
aws_access_key_id = XXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXX

Then call this file in the main.tf file. https://www.terraform.io/docs/providers/aws/index.html
Example: 
provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "/home/ahernandez/Terraform/.aws/credentials-commercial-aws"
}
5. You may need a key pair (I recommended you create one and reference it during terraform apply)
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html


# Ok Let's Launch!
1. Open a terminal window
2. Git clone this repo. Type this at the CLI: git clone git@github.com:therealnoof/terraform-aws-awaf-ngfw-demo.git
3. run this command: terraform init
4. run this command to launch: terraform apply -auto-approve
5. run this command to destroy: terraform destroy -auto-approve

Enjoy!
