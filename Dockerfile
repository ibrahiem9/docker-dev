# Make sure that you are not connected to VPN when building this image

FROM --platform=linux/amd64 ubuntu:22.04
# something about running source commands
SHELL ["/bin/bash", "-c"] 
# Force silent installs with apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade base packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils

# Install common packages that are available via native package manager
#   - curl, wget, unzip required for package installs
#   - groff required for aws cli help docs
#   - jq required for `data.external.account_tags`
#   - iputils-ping net-tools dnsutils helpful for debug/troubleshooting
#   - nano preferred as text editor
RUN apt-get update -y && \
    apt-get install -y git curl wget unzip groff jq iputils-ping net-tools dnsutils nano software-properties-common build-essential

# Install node js and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install aws cli
RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscli.zip && \
    unzip awscli.zip && \
    rm awscli.zip && \
    ./aws/install && \
    rm -rf ./aws*

# Install aws2-wrap
RUN apt-get update -y && \
    apt-get install -y pip && \
    pip install aws2-wrap

# Install terraform
RUN apt-get install -y gnupg software-properties-common && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update -y && \
    apt-get install -y terraform

# Install kubectl
RUN apt-get install -y apt-transport-https ca-certificates && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.kubernetes.io/ kubernetes-xenial main" && \
    apt-get update -y && \
    apt-get install -y kubectl

# Install helm
RUN curl -fsSL https://baltocdn.com/helm/signing.asc | apt-key add - && \
    apt-add-repository "deb https://baltocdn.com/helm/stable/debian/ all main" && \
    apt-get update -y && \
    apt-get install -y helm

# Install GCloud SDK 
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

# Install OpenJDK 11
RUN apt-get update -y && \
    apt-get install -y openjdk-11-jre-headless

# Install Maven
RUN apt-get update -y &&\
    apt-get install -y maven

# Install vault
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update -y && \
    apt-get install -y vault
# Workaround for vault cli Operation not permitted issue
# https://github.com/hashicorp/vault/issues/10924
RUN apt-get install --reinstall -y vault

# Install istioctl
# https://github.com/istio/istio/releases
ENV ISTIO_VERSION="1.15.0"
RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
    mv ./istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/ && \
    rm -rf ./istio-*

# Install golang
# https://github.com/golang/go/releases
ENV GO_VERSION="1.19"
RUN wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -zxvf /tmp/go.tar.gz -C /tmp && \
    chmod +x /tmp/go/bin/* && \
    cp -r /tmp/go/bin/* /usr/local/bin/ && \
    cp -r /tmp/go /usr/local && \
    rm -rf /tmp/go*
# Ensure GOPATH dir exists and set
ENV GOPATH=/root/go
RUN mkdir -p $GOPATH
# Install go modules required by VS Code extension golang.go
RUN go get -v golang.org/x/tools/gopls

# Install Rust
RUN apt-get update -y && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
# Alternatively, you can run: ENV PATH="/root/.cargo/bin:${PATH}"

# Install k9s
# K9s is a shell tool that simplifies kubernetes operator tasks
RUN wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz -O k9s.tar.gz && \
    tar -zxvf k9s.tar.gz && \
    chmod +x ./k9s && \
    mv ./k9s /usr/local/bin/k9s && \
    rm -rf ./k9s*

# Install Python 3 and Pip
RUN apt-get update -y && \
    apt-get install python3 -y && \
    apt-get install python3-pip -y

WORKDIR workspace/

# Expose port if you want to test local services
# You can change the port to something other than 8080
EXPOSE 8080

# Cleanup
# RUN apt-get purge -y --auto-remove
