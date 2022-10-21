# Motivation

The purpose of this repo is to provision a simple environment on AWS hosting a single EC2 Ubuntu instance in a private subnet with docker engine installed for experimenting with Docker commands.

# What's inside this repo<a name="repo_content"></a>

This repo contains terraform configuration files in the folder [provision_infra](/provision_infra/) for provisioning a single EC2 Ubuntu instance inside a private subnet of a custom VPC in AWS. The custom VPC is created using [terraform AWS VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) version 3.16.1. In addition, in the folder [configure_infra](/configure_infra/) there is the [set_up_server.yml](/configure_infra/set_up_server.yml) ansible playbook for configuring the server. The playbook has to be run manually (check section [Run Ansible](#run_ansible) for details) and installs the components listed below:
* Desktop xfce4 environment
* Docker engine
* Docker compose
* Tiger vnc server
* Google Chrome

# Prerequisites for working with the repo<a name="prerequisites"></a>

* Your local machine, has to have terraform installed so you can run the terraform configuration files included in this repository. This repo has been tested with terraform 1.3.2
* Since Ansible is used for the configuration of the EC2 Ubuntu instance (i.e. for installing a desktop environment, docker engine etc.), you also need to have Ansible installed on your local machine which will play the role of an Ansible control node. This repo has been tested with Ansible 2.13.5
* You need to generate a pair of aws_access_key_id-aws_secret_access_key for your AWS user using the console of AWS and provide the path where the credentials are stored to the variable called ```credentials_location``` which is in ```/provision_infra/terraform.tfvars``` file. This is used by terraform to make programmatic calls to AWS API.
* You need to use AWS console (prior to running the terraform configuration files) to generate a key-pair whose name you need to specify in the ``provision_infra/terraform.tfvars`` file (variable name is ```key_name```). The ```pem``` file (which has to be downloaded from AWS and stored on your local machine) of the key pair, is used in order for Ansible to authenticate when connecting to the EC2 Ubuntu instance with ssh.
* Go through the section [Accessing the EC2 Ubuntu instance](#access_instance) and make sure that you have [AWS CLI installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), as well as [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) and the proper configuration in ```~/.ssh/config``` and ```~/.aws/config``` files. 
* Install sdarwin.vnc role with the command ```ansible-galaxy install sdarwin.vnc```. This fetches the ansible role made by Sam Darwin and places it in ```~/.ansible/roles```. The role is used by the [set_up_server.yml](/configure_infra/set_up_server.yml) ansible playbook to install a desktop environment on the server as well as for installing tiger vnc server. You can find the git repo of Sam's role [here](https://github.com/sdarwin/Ansible-VNC)


# Accessing the EC2 Ubuntu instance<a name="access_instance"></a>

Access to the EC2 Ubuntu instance is needed both for humans (e.g. to interact with the Ubuntu server via the CLI or by using a VNC client) and Ansible (which is used to set up the Ubuntu server). Although the AWS security group (i.e. the default security group created when the VPC is provisioned) where the Ubuntu instance is placed does **not** include any ingress rule; using SSH to connect to the instance is still possible thanks to AWS Systems Manager. Terraform installs SSM Agent on the Ubuntu instance.   

### Human Access<a name="human_access"></a>

<ins>**Interact with the remote Ubuntu Server using the CLI via SSH**</ins> 

In order for a client (e.g. you local machine) to ssh to the EC2 instances, it needs to fullfil the below:

* Have AWS CLI installed: [Installation of AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Have the Session Manager plugin for the AWS CLI installed: [Install the Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
* Have the configuration below into the SSH configuration file of your local machine (typically located at ```~/.ssh/config```)
```shell
# SSH over Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```
* Specify in the ```~/.aws/config``` file the AWS region like below:
```shell
[default]
region=<AWS_REGION>
```
You can connect using the command: ```ssh -i <KEY_PEM_FILE> <USER_NAME>@<INSTANCE_ID>```
The ```USER_NAME``` of the Ubuntu Server is ```ubuntu```. The ```KEY_PEM_FILE``` is the path pointing to the pem file of the key-pair that you need to generate as discussed in the [Prerequisites for working with the repo](#prerequisites) section.
When terraform finishes its execution, it returns  the ```instance_id_ubuntu_server```, which you can use as follows to connect to the EC2 instance: ```ssh -i <KEY_PEM_FILE> ubuntu@<INSTANCE_ID_UBUNTU_SERVER>```. Once you are connected as ```ubuntu``` user, you can switch to ```root``` with the command: ```sudo -i```. The password of the ```ubuntu``` user can be set when running ansible. Check section [Run Ansible](#run_ansible) for details. 
<br/><br/>
<ins>**Interact with the desktop environment of the Ubuntu Server using a VNC client**</ins>

Note that accessing the desktop environment of the Ubuntu EC2 instance using VNC's Frame Buffer protocol (RFB) is possible, but first an SSH tunnel from your local machine to the Ubuntu server needs to be established since the RFB traffic will reach the EC2 Ubuntu server through the SSH tunnel. This approach was chosen because the RFB protocol is not secure, but having it reaching the remote Server through the SSH tunnel is a secure way for interacting with the desktop environment of the Server. 

* Create an SSH tunnel to the destination server: ```ssh -i <PUBLIC_KEY> -L 5901:localhost:5901 ubuntu@<INSTANCE_ID_UBUNTU_SERVER>```
* On the VNC viewer provide the following: ```localhost:5901```
> **_NOTE:_**  The password that you need to provide to the VNC client when prompted, is the one configured in [/configure_infra/group_vars/all](/configure_infra/group_vars/all) (variable ```vnc_default_password```).

<br/>

### Ansible Access
When Ansible does not find an ```ansible.cfg``` file, it uses the defaults which means that it will use the configuration of ```~/.ssh/config``` for connecting via SSH to the hosts which needs to interact with. From that perspective, in order for Ansible to connect to the EC2 instances via SSH, all the points discussed in the section above ([Human Access](#human_access)) are still relevant. The playbooks themselves define the user that needs to be used, however, you still need to specify the ```KEY_PEM_FILE``` which is the pem file of the key-pair that you need to generate using AWS console as discussed in the [Prerequisites for working with the repo](#prerequisites) section.
For running the playbook of this repository follow the instructions in the section below: [Run Ansible](#run_ansible)
<br/><br/>
# Provision the infrastructure and configure the Ubuntu instance<a name="run_scripts"></a>

Note that terraform generates a file into the configure_infra folder called ```inventory``` which will be used as the inventory for Ansible
# Architecture<a name="architecture"></a>

A high level view of the virtual infrastructure which will be created by the terraform configuration files included in this repo can be seen in the picture below: 

 ![High Level Setup](/assets/images/Ubuntu-Server-AWS.png)
 #### Notes
- Subnet 10.0.1.0/24 is private in the sense that instances that are created inside it do not get a public IP
- Subnet 10.0.2.0/24 is public in the sense that instances which are created inside it get a public and a private IP
- The default route of the private subnet is the NAT gateway which resides in the public subnet 
- The default route of the public subnet is the Internet Gateway (IGW)
- The ubuntu server is placed in the default security group which comes with the creation of the VPC. No changes where applied to the default security group which means that:
  - It does not allow any inbound traffic (apart from the traffic generated within the security group itself). Note that ssh access to the EC2 Ubuntu instance whose interface is in the default security group is possible through AWS SSM
  - It allows all outbound traffic 

### Run terraform
In the folder [provision_infra](/provision_infra/) run:
```terraform apply```

### Run Ansible<a name="run_ansible"></a>
Before running the playbook set the value of the ```vnc_default_password``` in [/configure_infra/group_vars/all](/configure_infra/group_vars/all). Once done, in the folder [configure_infra](/configure_infra/) run the playbook with the command below: 

```ansible-playbook --private-key <KEY_PEM_FILE> -i inventory set_up_server.yml --extra-vars "ubuntu_user_password=<USER_PASSWORD>"```