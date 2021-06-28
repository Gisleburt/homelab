# Home lab kubernetes configurator

A set of tools to build my home lab kubernetes cluster on any number of raspberry pis.

The pi's in the cluster run Ubuntu LTS (20.04 at time of writing). Each machine needs to be
initially configured with a shell script to prepare it for ansible. This script copies over a public
ssh key, and sets the hostname. After that set up is managed through ansible. 

All commands are runnable through Make but you will need Docker installed as this is used to run
ansible.

## Preparation

You need to do a couple of things to prepare.
1. Make sure your Pis are assigned static IP addresses by your router.
2. Run the prepare-host.sh file in the prepare folder with the IP address of the pi, the new
   hostname and the location of your ssh public key. Eg
   ```
   ./prepare/prepare-host.sh 10.4.0.100 k8s-master-001 ~/.ssh/id_rsa
   ```

## Commands

# `make build.ansible`

Creates the ansible docker image that will be used to run ansible playbooks.
