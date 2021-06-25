# Home lab kubernetes configurator

A set of tools to build my home lab kubernetes cluster on any number of raspberry pis.

The pi's in the cluster run Ubuntu LTS (20.04 at time of writing). Each machine needs to be
initially configured with a shell script to prepare it for ansible. This script copies over a public
ssh key, and sets the hostname. After that set up is managed through ansible. 

All commands are runnable through Make but you will need Docker installed as this is used to run
ansible.

## Commands

# `make build.ansible`

Creates the ansible docker image that will be used to run ansible playbooks.
