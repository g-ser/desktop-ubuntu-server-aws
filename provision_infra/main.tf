#  This terraform configuration file provisions a VPC on 
#  AWS with two subnets: a private and a public.
#  The VPC is provisioned by the AWS VPC terraform module.
#  Within the private subnet an EC2 instance is created which can 
#  reach the Internet through the NatGateway that resides in the 
#  public subnet. The EC2 instance is just an Ubuntu Server VM 
#  The Ubuntu Server can be reached with AWS SSM 

terraform {
  required_version = ">= 1.3.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

# Configure the AWS Provider and credentials
provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.credentials_location]
}

# Create a vpc using the corresponding aws terraform module

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.1"

  name = "ubuntu-server-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.availability_zone]
  private_subnets = [var.private_subnet]
  public_subnets  = [var.public_subnet]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

# Create the interface of the Ubuntu Server

resource "aws_network_interface" "ubuntu_server_iface" {
  subnet_id       = module.vpc.private_subnets[0]
  private_ips     = [var.ubuntu_server_ip_address]
  security_groups = [module.vpc.default_security_group_id]

  tags = {
    Name = "ubuntu_server_iface"
  }
}

# Get the ami of Ubuntu Jammy 

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create AWS EBS volume

resource "aws_ebs_volume" "ubuntu_server_ebs" {
  availability_zone = var.availability_zone
  size              = 40
  type              = "gp2"

  tags = {
    Name = "Ubuntu server ebs volume"
  }
}

# Create Docker Host

resource "aws_instance" "ubuntu_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_server_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.ubuntu_server_iface.id
    device_index         = 0
  }

  user_data            = data.cloudinit_config.ubuntu_server.rendered
  iam_instance_profile = aws_iam_instance_profile.ssm_iam_profile.name
  tags = {
    Name = "Ubuntu Server"
  }
}

# Attach the ebs volume to the instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ubuntu_server_ebs.id
  instance_id = aws_instance.ubuntu_server.id
}

# generate a file into configure_infra folder
# which will be used as the inventory for Ansible
resource "local_file" "ansible_inventory" {
  content  = <<-EOT
      [ubuntu_server]   
      ${aws_instance.ubuntu_server.id}
    EOT
  filename = "../configure_infra/inventory"
}