# Home lab kubernetes configurator

A set of tools to build my home lab kubernetes cluster on any number of raspberry pis.

The pi's in the cluster run RaspiOS Lite (32bit at time of writing). Each machine needs to be
initially configured with a shell script to prepare it for ansible. This script copies over a public
ssh key, and sets the hostname. After that set up is managed through ansible. 

All commands are runnable through Make but you will need Docker installed as this is used to run
ansible.

## Preparation

You need to do a couple of things to prepare.
1. Make sure your Pis are assigned static IP addresses by your router.
2. Make a new ssh key file without a password, you'll use this in the next step 
2. Run the prepare-host.sh file in the `prepare` folder with the IP address of the pi, the new
   hostname and the location of your ssh public key. Eg
   ```
   ./prepare/prepare-host.sh 10.4.0.100 k8s-master-100 ~/.ssh/id_rsa
   ```
3. Finally, you will need to create a `hosts` file in this directory. This is ignored by git, but
   it should look like the following, but change your IP addresses and keyfile name as required:
   ```
   [masters]
   10.4.0.100
   
   [nodes]
   10.4.0.101
   10.4.0.102
   
   [k8s:children]
   masters
   nodes
   
   [k8s:vars]
   ansible_ssh_user=pi
   ansible_ssh_private_key_file=~/.ssh/pi-k8s
   ```

## Commands

# `make build.ansible`

Creates the ansible docker image that will be used to run ansible playbooks.
