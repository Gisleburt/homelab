#!/usr/bin/env sh
set -eufo pipefail

SSH_USER=pi

IP=$1
IP_REGEX='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
if ! [[ $IP =~ $IP_REGEX ]] ; then
  echo "error: first parameter should be an IPv4 address" >&2; exit 1
fi

NEW_HOSTNAME=$2
HOSTNAME_REGEX='^[0-9a-zA-Z][0-9a-zA-Z\-]{0,62}$'
if ! [[ $NEW_HOSTNAME =~ $HOSTNAME_REGEX ]] ; then
  echo "error: second parameter should be a valid hostname" >&2; exit 1
fi

SSH_KEY=$3
if ! [[ -f "$SSH_KEY" ]] ; then
  echo "error: third parameter should be the path to your ssh public key" >&2; exit 1
fi
if [[ $(head -c 3 $SSH_KEY) != "ssh" ]] ; then
  echo "error: the path at the third parameter was not to a public key" >&2; exit 1
fi

#┌─┬┐  ╔═╦╗  ╓─╥╖  ╒═╤╕
#│ ││  ║ ║║  ║ ║║  │ ││
#├─┼┤  ╠═╬╣  ╟─╫╢  ╞═╪╡
#└─┴┘  ╚═╩╝  ╙─╨╜  ╘═╧╛

echo "╔═════════════════╗"
echo "║ Copying Keyfile ║"
echo "╚═════════════════╝"
ssh-copy-id -i $SSH_KEY $SSH_USER@$IP

echo "╔══════════════════╗"
echo "║ Setting Hostname ║"
echo "╚══════════════════╝"
ssh -t $SSH_USER@$IP "sudo hostnamectl set-hostname $NEW_HOSTNAME"

echo "╔════════════╗"
echo "║ Restarting ║"
echo "╚════════════╝"
ssh -t $SSH_USER@$IP "sudo shutdown -r 0"
