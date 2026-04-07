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
2. Run the prepare-host.sh file in the `prepare` folder with username and host for each node
   ```
   ./prepare/prepare-host.sh daniel 10.4.0.100
   ```
   Note: This will create a new ssh key in `$PWD/.ssh` which will be shared with tools like
   ansible. This directory will also be ignored by git but the keyfile is not password protected
   so take care.
3. Optional: You may need to create a `$PWD/.ssh/config`. Eg:
   ```
   Host 10.4.*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
   IdentityFile ~/.ssh/homelab
   IdentitiesOnly yes
   
   Host rpi-*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
   IdentityFile ~/.ssh/homelab
   IdentitiesOnly yes
   ```
4. Finally, you will need to create a `hosts` file in this directory. This is ignored by git, but
   it should look like the following, but change your IP addresses and keyfile name as required:
   ```ini
   [primary_server]
   10.4.0.100
   
   [secondary_servers]
   # Add more servers here for High Availability
   
   [agents]
   10.4.0.101
   10.4.0.102
   
   [k8s:children]
   primary_server
   secondary_servers
   agents

   [storage_provider]
   10.4.0.101
   
   [k8s:vars]
   ansible_ssh_user=pi
   ansible_ssh_private_key_file=~/.ssh/homelab
   ```

> **A Note on IP Addresses:** This playbook assumes your homelab will sit on a 10.4.0.0/16 network.
> Specifically, the server will be on 10.4.0.100, nodes will build up after that, eg, 10.4.0.101,
> 102, etc.
> 
> Load balancers will be configured through MetalLB to work on addresses 10.4.16.0/24

## Commands

Make commands will use empty files in `build/` to keep track of changes 

### `make build/cluster`

The only command you'll really need, once the [Preparation](#Preparation) steps are complete. It
will set up the PoE hat, remove the swap file, and install the appropriate services. Finally, it
will copy a `k3s-config.yaml` file to the root of this project (`.gitignore`d) so that you can
connect to the cluster with kubectl (see below).

> **A note on replacing nodes**: Rerunning `make build/cluster` will automatically rebuild nodes
> however, you must remember to delete nodes that have died from the cluster first with `kubectl
> delete node`. Kubernetes is smart enough to be suspicious of nodes connecting with the same name
> as existing nodes and prevent them from joining the cluster.

### `make build/ansible`

Creates the ansible docker image that will be used to run ansible playbooks. This is run
automatically but `build/cluster` so there is no need to run it separately.

### `make build/kubectl

Creates a kubectl that exists inside of docker, so that you don't need to install it locally / mess
with your locally installed kubectl. When you use the aliased version of kubectl, it will share
the k3s-config.yaml file in the root of this project directory to connect to the k3s cluser. 

## Kubernetes

When applying kubernetes configurations, do them in numeric order.

Some configurations may error because resource types don't exist, however, if you wait a moment and reapply the resource
it should be fine.

See below for specific problems you may run into

### [100.nfs-provisioner](services/100.nfs-provisioner)

Make sure that the `storage.nfs-tester` pod starts correctly before moving on. If it does, you can delete the
deployment. If it doesn't, describe the pod to look for errors that might indicate the storage provider is not correctly
configured. The most likely reason is that the IP address for the NFS server is incorrect. Note it must be changed in
two place, the volume mount on the provider, and the address in the environment.

> ToDo: Can we make the volume mount address come from a ConfigMap?
