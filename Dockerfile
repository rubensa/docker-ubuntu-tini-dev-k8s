FROM rubensa/ubuntu-tini-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

ARG HELM_VERSION=3.3.4
# https://storage.googleapis.com/kubernetes-release/release/stable.txt
ARG KUBECTL_VERSION=1.19.2

# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
ARG AWS_IAM_AUTH_VERSION_URL=https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    #
    # Install
    && apt-get -y install --no-install-recommends groff less \
    # 
    # Install jq
    && apt-get -y install jq \
    #
    # Install HELM
    && curl -sSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xvz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm completion bash >/etc/bash_completion.d/helm \
    && rm -rf linux-amd64 \
    #
    # Install kubectl
    && curl -sSLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl completion bash >/etc/bash_completion.d/kubectl \
    #
    # Install aws-iam-authenticator
    && curl -sSLO ${AWS_IAM_AUTH_VERSION_URL} \
    && mv aws-iam-authenticator /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator \
    #
    # Install eksctl
    && curl -sSL "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_Linux_amd64.tar.gz" | tar xz  \
    && mv eksctl /usr/local/bin \
    && chmod +x /usr/local/bin/eksctl \
    && eksctl completion bash >/etc/bash_completion.d/eksctl \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USER_NAME

# Create python environment and install awscli
RUN /bin/bash -l -c "source /opt/conda/etc/profile.d/conda.sh; conda create -y -n k8s python=3.8; /opt/conda/envs/k8s/bin/pip install awscli" \
    # Activate project environment
    && printf "\nconda activate k8s\n" >> /home/${USER_NAME}/.bashrc
