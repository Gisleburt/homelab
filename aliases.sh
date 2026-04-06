# source this file to simplify using ansible

alias ansible='podman run --rm -v ${PWD}/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible ansible'
alias ansible-playbook='podman run --rm -v ${PWD}/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible ansible-playbook'
alias ansible-galaxy='podman run --rm -v ${PWD}/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible ansible-galaxy'
alias ansible-container='podman run --rm -it -v ${PWD}/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible'

alias kubectl='podman run --rm -it -v "${PWD}/k3s-config.yaml:/root/.kube/config" -v "${PWD}:/home" gisleburt/kubectl kubectl'
alias helm='podman run --rm -it -v "${PWD}/k3s-config.yaml:/root/.kube/config" -v ${PWD}/tools/helm-cache:/root/.cache/helm -v "${PWD}:/home" gisleburt/kubectl helm'
