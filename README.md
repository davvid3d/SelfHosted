# Self hosted services

## 1. requirements

### 1.1 update system
On a fresh installed system, for Debian system:
```bash
sudo apt update 
sudo apt upgrade -y
```
### 1.2 Ansible
first install Ansible (more informations: [Ansible installation doc](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu):

```bash
sudo apt install software-properties-common # Install the software-properties-common package
sudo apt-add-repository ppa:ansible/ansible # Install ansible personal package archive
# Install ansible
sudo apt update
sudo apt install ansible
```

then test ansible:
```bash
ansible localhost -m ping
```
the output should looks like this:
```bash
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
configure the hosts file inventory containing the target hosts located at */etc/ansible/hosts* or create a hosts file at a specific location :

```bash
sudo nano /etc/ansible/hosts
# or in local file
sudo nano hosts
```

the file contains already some example, for our usage, we must define this computer, because it will be the main server and the other server nodes if needed. Of course this configuration is depending the network availability and architecture. This is just an exemple:

```bash
[servers]
server1 ansible_host=localhost ansible_connection=local
server2 ansible_host=20.199.113.xxx ansible_user=xxx

[main]
server1

[web]
server1
server2

[db]
server1
server2

[file]
server1

[network]
server1
server2
```

the localhost is set with the variable *ansible_connection=local* to avoid using the ssh connection to reach itself. A specific user can be set for external servers, The ssh key pair connection is used for this example. The public key of the localhost must be set as authorized key in the remote hosts. more details can be seen here: [Ansible inventory doc](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html).

to test the good configuration of the inventory, the Ansible ping command can be send to all the inventory:

 ```bash
ansible all -m ping
# or by using local hosts file
ansible -i hosts all -m ping
```

and all hosts should reply to the command successfully:

 ```bash
server1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
server2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

Setup the hosts passwords in an Ansible vault to secure them, for that, create a dictionary with the passwords, for exemple, edit the vault file :

 ```bash
nano Ansible/group_vars/servers/my_vault.yml
```
and set the password of the hosts:

 ```yaml
my_vault:
  server1:
      ansible_password: XXXX
  server2:
      ansible_password: XXXX
```
then encrypt the password vault to remove plan password text
 ```bash
ansible-vault encrypt Ansible/group_vars/servers/my_vault.yml
```
and set the vault password as wanted, the vault file is then encrypted.

Now as we have set a vault password, for each ansible command that needs the passwords, the flag *--ask-vault-pass* must be added to decrypt the vault passwords.

The vault password can also be set in a password file for example:
 ```bash
echo "password" >> Ansible/password.txt
```
then the password file can be used to call playbooks that are using the password vault.

The set passwords can be tested by using the *debug.yaml* playbook:
 ```bash
ansible-playbook -i Ansible/hosts Ansible/debug.yaml --ask-vault-pass
# or
ansible-playbook -i Ansible/hosts Ansible/debug.yaml --vault-password-file Ansible/password.txt
```

and the set password must be displayed in the output:
 ```bash
 Vault password: 

PLAY [servers] **************************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [server2]
ok: [server1]

TASK [debug] ****************************************************************************************
ok: [server1] => {
    "ansible_password": "XXXX"
}
ok: [server2] => {
    "ansible_password": "XXXX"
}

PLAY RECAP ******************************************************************************************
server1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
server2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

