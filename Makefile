.PHONY: build.ansible

ANSIBLE = gisleburt/ansible

build.ansible:
	docker build ansible --tag $(ANSIBLE)
