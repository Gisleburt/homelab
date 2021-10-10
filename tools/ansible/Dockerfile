FROM alpine:3

RUN apk update
RUN apk add ansible
RUN apk add openssh
RUN apk add sshpass

# These packages only required for ansible k8s module
RUN apk add python3
RUN apk add py3-pip
# todo: fix dependencies https://github.com/kubernetes-client/python/issues/1333
RUN pip3 install openshift==0.11.0 pyyaml kubernetes==11.0.0

WORKDIR /ansible
