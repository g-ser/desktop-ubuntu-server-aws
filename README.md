# Motivation

# Prerequisites for working with the repo<a name="prerequisites"></a>

* Install sdarwin.vnc role ```ansible-galaxy install sdarwin.vnc```

# Provision the infrastructure and configure the Ubuntu instance<a name="run_scripts"></a>

Note that terraform generates a file into the configure_infra folder called ```inventory``` which will be used as the inventory for Ansible

### Run terraform
In the folder [provision_infra](/provision_infra/) run:
```terraform apply```

### Run Ansible<a name="run_ansible"></a>
In the folder [configure_infra](/configure_infra/) run: 

```ansible-playbook --private-key <KEY_PEM_FILE> -i inventory set_up_server.yml --extra-vars "ubuntu_user_password=<USER_PASSWORD>"```


# Connect to the Docker Host Server using a VNC viewer

* Create an SSH tunnel to the destination server: ```ssh -i <PUBLIC_KEY> -L 5901:localhost:5901 <VNC_USER>@<INSTANCE_ID_DOCKER_HOST>```
* On the VNC viewer provide the following: localhost:5901



