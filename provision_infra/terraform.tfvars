# credentials for connecting to AWS
credentials_location = "~/.aws/credentials"

# key for connecting to EC2 instances for managing them
key_name = "gs_key_pair"

# VPC
region            = "eu-north-1"
vpc_cidr_block    = "10.0.0.0/16"
availability_zone = "eu-north-1a"

# vpc subnets
private_subnet = "10.0.1.0/24"
public_subnet  = "10.0.2.0/24"


# ubuntu docker host
ubuntu_server_ip_address    = "10.0.1.4"
ubuntu_server_instance_type = "t3.small"
