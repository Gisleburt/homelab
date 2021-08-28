# source this file to simplify using ansible

alias ansible='docker run --rm -v ~/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible ansible'
alias ansible-playbook='docker run --rm -v ~/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible ansible-playbook'
alias ansible-galaxy='docker run --rm -v ~/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible ansible-galaxy'
alias ansible-container='docker run --rm -it -v ~/.ssh:/root/.ssh -v "${PWD}:/ansible" gisleburt/ansible'

alias kubectl='docker run --rm -it -v "${PWD}/k3s-config.yaml:/root/.kube/config" -v "${PWD}:/home" gisleburt/kubectl kubectl'
alias helm='docker run --rm -it -v "${PWD}/k3s-config.yaml:/root/.kube/config" -v ${PWD}/tools/helm-cache:/root/.cache/helm -v "${PWD}:/home" gisleburt/kubectl helm'
