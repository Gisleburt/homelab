FROM alpine:3

WORKDIR /tmp

RUN apk add curl # sha256sum

# Get binary
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Checksum binary
#RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
#RUN echo "$(<kubectl.sha256) kubectl" | sha256sum --check

RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

WORKDIR /kubectl

CMD ["/kubectl/kubectl"]
