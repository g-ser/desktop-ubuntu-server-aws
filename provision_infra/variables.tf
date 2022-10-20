variable "region" {
  description = "The AWS region where the infrastructure will be provisioned"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The cidr block of the VPC"
  type        = string
}

variable "private_subnet" {
  description = "The cidr block of the subnet where the docker host will be created"
  type        = string
}

variable "public_subnet" {
  description = "The cidr block of the subnet where the NAT gateway will be created"
  type        = string
}
variable "credentials_location" {
  description = "The location in your local machine of the aws_access_key_id and aws_secret_access_key"
  type        = string
}

variable "ubuntu_server_ip_address" {
  description = "The IP address of the 2nd worker node of the k8s cluster."
  type        = string
}

variable "ubuntu_server_instance_type" {
  description = "The instance type of the master node"
  type        = string
}

variable "key_name" {
  description = "Key name of the key pair used to connect to EC2 instances"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone where the vpc will be created"
  type        = string
}

