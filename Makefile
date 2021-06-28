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
	@touch build/ansible

ansible.test: build/ansible
	@echo Pinging all k8s masters and nodes
	@docker run --rm \
	  -v ~/.ssh:/root/.ssh \
	  -v "${PWD}:/ansible" \
	  ${ANSIBLE} \
	  ansible -i hosts -m ping k8s
