.PHONY: build.ansible

ANSIBLE = gisleburt/ansible

build.ansible:
	@echo Building Docker image
	@docker build ansible --tag $(ANSIBLE)

ansible.test:
	@echo Pinging all k8s masters and nodes
	@docker run --rm \
	  -v ~/.ssh:/root/.ssh \
	  -v "${PWD}:/ansible" \
	  gisleburt/ansible \
	  ansible -i hosts -m ping k8s
