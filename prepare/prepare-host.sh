#!/usr/bin/env bash
set -eufo pipefail

SSH_USER=pi

HOST_TYPE=$1
HOST_TYPE_REGEX='^(master)|(node)$'
if ! [[ $HOST_TYPE =~ $HOST_TYPE_REGEX ]] ; then
  echo "error: first parameter should be either 'master' or 'node'" >&2; exit 1
fi

IP=$2
IP_REGEX='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
if ! [[ $IP =~ $IP_REGEX ]] ; then
  echo "error: second parameter should be an IPv4 address" >&2; exit 1
fi
NODE_ID=$(echo "$IP" | sed 's/[0-9]*\.//g')

NEW_HOSTNAME="k8s-${HOST_TYPE}-${NODE_ID}"

SSH_KEY=$3
if ! [[ -f "${SSH_KEY}" ]] ; then
  echo "error: third parameter should be the path to your ssh key" >&2; exit 1
fi
SSH_KEY_REGEX="^\-+BEGIN.+PRIVATE KEY\-$"
if [[ $(head 1 "${SSH_KEY}") =~ $SSH_KEY_REGEX ]] ; then
  echo "error: the path at the third parameter was not to an ssh key" >&2; exit 1
fi

SSH_PUB="${SSH_KEY}.pub"
if ! [[ -f "${SSH_PUB}" ]] ; then
  echo "error: could not find " >&2; exit 1
fi
if [[ $(head -c 3 "${SSH_PUB}") != "ssh" ]] ; then
  echo "error: the path at the third parameter was not to a public key" >&2; exit 1
fi

#┌─┬┐  ╔═╦╗  ╓─╥╖  ╒═╤╕
#│ ││  ║ ║║  ║ ║║  │ ││
#├─┼┤  ╠═╬╣  ╟─╫╢  ╞═╪╡
#└─┴┘  ╚═╩╝  ╙─╨╜  ╘═╧╛

echo "╔═════════════════╗"
echo "║ Copying Keyfile ║"
echo "╚═════════════════╝"
ssh-copy-id -i $SSH_PUB $SSH_USER@$IP

echo "╔═════════════════╗"
echo "║ Change Password ║"
echo "╚═════════════════╝"
ssh -i $SSH_KEY -t $SSH_USER@$IP "passwd"

echo "╔══════════════════╗"
echo "║ Setting Hostname ║"
echo "╚══════════════════╝"
ssh -i $SSH_KEY -t $SSH_USER@$IP "sudo hostnamectl set-hostname $NEW_HOSTNAME"

echo "╔════════════╗"
echo "║ Restarting ║"
echo "╚════════════╝"
ssh -i $SSH_KEY -t $SSH_USER@$IP "sudo shutdown -r 0"
