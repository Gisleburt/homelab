# Home lab configurator

A set of tools to build my home lab kubernetes cluster on any number of raspberry pis.

The pi's in the cluster run RaspiOS Lite (32bit at time of writing). Each machine needs to be
initially configured with a shell script to prepare it for ansible. This script copies over a public
ssh key, and sets the hostname. After that set up is managed through ansible. 

All commands are runnable through Make but you will need Docker installed as this is used to run
ansible.

## Preparation

### You will need:

1. At least 2 Raspberry Pis (v4+ with at least 4GB of memory are preferable, but v3s should work)
2. A Micro SD card for each Pi
3. A PoE+ hat and ethernet cable for each Pi
4. A switch that can deliver PoE+

If you can not get PoE+ hats and a PoE+ switch, you can do this over WiFi, however this will impact
performance and will require some set up steps we're not covering in this guide. You will also need
to comment out the `poe` role in the ansible setup.

### To prepare your Raspberry Pis

1. Download the [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
2. Flash your Micro SD cards with Raspberry Pi OS Lite 64 bit making sure to
   1. enable SSH
   2. copy in your ssh keyfile
   3. set the username and password
   
### Once you have connected your Pis to the switch

1. Make sure that your Pis have been assigned static IP addresses by your router
2. Make a new ssh key file without a password, you'll use this in the next step 
3. Run the prepare-host.sh file in the `prepare` folder with the IP address of the pi, the new
   hostname and the location of your ssh public key. Eg
   ```
   ./prepare/prepare-host.sh 10.4.0.100 k8s-master-100 ~/.ssh/id_rsa
   ```
4. Finally, you will need to create a `hosts` file in this directory. This is ignored by git, but
   it should look like the following, but change your IP addresses and keyfile name as required:
   ```ini
   [masters]
   10.4.0.100
   
   [nodes]
   10.4.0.101
   10.4.0.102
   
   [k8s:children]
   masters
   nodes
   
   [storage_provider]
   10.4.0.101
   
   [k8s:vars]
   ansible_ssh_user=pi
   ansible_ssh_private_key_file=~/.ssh/pi-k8s
   ansible_python_interpreter=/usr/bin/python3
   ```

## Commands

Make commands will use empty files in `build/` to keep track of changes 

### `make build/cluster`

The only cammand you'll really need, once the [Preparation](#Preparation) steps are complete. It
will set up the PoE hat, remove the swap file, and (todo) install the appropriate services.

### `make build/ansible`

Creates the ansible docker image that will be used to run ansible playbooks. This is run
automatically but `build/cluster` so there is no need to run it separately.
