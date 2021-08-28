.PHONY: build.ansible

ANSIBLE = gisleburt/ansible

build/ansible: tools/ansible/*
	@echo Building Docker image
	@docker build tools/ansible --tag $(ANSIBLE)
	@mkdir -p build
	@touch build/ansible

build/cluster: build/ansible homelab/* homelab/*/* homelab/*/*/* homelab/*/*/*
	@echo Running the playbook
	@docker run --rm \
	  -v ~/.ssh:/root/.ssh \
	  -v "${PWD}:/ansible" \
	  ${ANSIBLE} \
	  ansible-playbook -i hosts homelab/playbook.yml
	@mkdir -p build
	@touch build/cluster

build/kubectl: tools/kubectl/*
	@echo Building kubectl docker image

build/dashboard: services/kubernetes-web-ui/*.yml
	@echo Installing Dashboard
	@GITHUB_URL=https://github.com/kubernetes/dashboard/releases
	@VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
	@kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
	@kubectl apply -f services/kubernetes-web-ui/*.yml
	@touch build/dashboard

run/dashboard: build/dashboard

ansible.test: build/ansible
	@echo Pinging all k8s masters and nodes
	@docker run --rm \
	  -v ~/.ssh:/root/.ssh \
	  -v "${PWD}:/ansible" \
	  ${ANSIBLE} \
	  ansible -i hosts -m ping k8s

run/gitlab-runner: build/kubectl
	@echo Starting github runner
	@docker run --rm -it \
      -v "${PWD}/k3s-config.yaml":/root/.kube/config \
      -v "${PWD}":/home \
      gisleburt/kubectl \
        kubectl apply -f services/gitlab-runner/namespace.yaml
	@docker run --rm -it \
	  -v "${PWD}/k3s-config.yaml":/root/.kube/config \
	  -v "${PWD}/tools/helm-cache":/root/.cache/helm \
	  -v "${PWD}":/home \
	  gisleburt/kubectl \
	    sh -c \
	    "helm repo add gitlab https://charts.gitlab.io && \
	    helm repo update && \
	    helm install \
	      --namespace gitlab \
	      gitlab-runner \
	      -f services/gitlab-runner/values.yaml \
	      gitlab/gitlab-runner"
