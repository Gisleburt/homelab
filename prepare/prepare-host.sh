#!/usr/bin/env bash
set -eufo pipefail

# Create the .ssh dir if its not there
mkdir -p "${PWD}/.ssh"

# Create the ssh key if its not there
SSH_KEY="${PWD}/.ssh/homelab"
if ! [[ -f "${SSH_KEY}" ]] ; then
  echo "╔═════════════════════════════╗"
  echo "║ Keyfile not found, creating ║"
  echo "╚═════════════════════════════╝"
  ssh-keygen -f "${SSH_KEY}" -N "" -C "Homelab Auto Generated Key"
  chmod go-rwx "${SSH_KEY}"
fi

SSH_USER=$1
if [[ $SSH_USER =~ "" ]] ; then
  echo "error: first parameter should be the username for ssh" >&2; exit 1
fi

HOST=$2
if [[ $HOST =~ "" ]] ; then
  echo "error: second parameter should be the hostname for ssh" >&2; exit 1
fi

SSH_KEY_REGEX="^\-+BEGIN.+PRIVATE KEY\-$"
if [[ $(head 1 "${SSH_KEY}") =~ $SSH_KEY_REGEX ]] ; then
  echo "error: ssh key does not seem to have been created correctly" >&2; exit 1
fi

SSH_PUB="${SSH_KEY}.pub"
if ! [[ -f "${SSH_PUB}" ]] ; then
  echo "error: could not find ${SSH_PUB}" >&2; exit 1
fi
if [[ $(head -c 3 "${SSH_PUB}") != "ssh" ]] ; then
  echo "error: ${SSH_PUB} does not appear to be a public key" >&2; exit 1
fi

#┌─┬┐  ╔═╦╗  ╓─╥╖  ╒═╤╕
#│ ││  ║ ║║  ║ ║║  │ ││
#├─┼┤  ╠═╬╣  ╟─╫╢  ╞═╪╡
#└─┴┘  ╚═╩╝  ╙─╨╜  ╘═╧╛

echo "╔═════════════════╗"
echo "║ Copying Keyfile ║"
echo "╚═════════════════╝"
ssh-copy-id -i $SSH_PUB $SSH_USER@$HOST

echo "╔════════════════════╗"
echo "║ Testing Connection ║"
echo "╚════════════════════╝"
ssh -i $SSH_KEY -t $SSH_USER@$HOST "echo \"Hello, World!\""
#
#echo "╔═════════════════╗"
#echo "║ Change Password ║"
#echo "╚═════════════════╝"
#ssh -i $SSH_KEY -t $SSH_USER@$HOST "passwd"

#echo "╔══════════════════╗"
#echo "║ Setting Hostname ║"
#echo "╚══════════════════╝"
#ssh -i $SSH_KEY -t $SSH_USER@$HOST "sudo hostnamectl set-hostname $NEW_HOSTNAME"

#echo "╔════════════╗"
#echo "║ Restarting ║"
#echo "╚════════════╝"
#ssh -i $SSH_KEY -t $SSH_USER@$HOST "sudo shutdown -r 0"
