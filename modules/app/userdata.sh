#!/bin/bash

dnf install python3.11-pip ansible -y | tee -a /opt/userdata.log
pip3.11 install boto3 botocore | tee -a /opt/userdata.log



# shellcheck disable=SC2154
ansible-pull -i localhost, -U https://github.com/sai184/Infra-Ansible.git main.yml -e role_name="${role_name}" -e env="${env}"| tee -a /opt/userdata.log


#tee =>  will use for i need both output and logfile ,if you use redirect > it will go directly output to that file