FROM rubensa/ubuntu-tini-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Architecture component of TARGETPLATFORM (platform of the build result)
ARG TARGETARCH

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.8.1
RUN echo "# Installing helm..." \
    #
    # Install HELM
    && cd /tmp \
    && curl -o helm-linux.tar.gz -sSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar xvfz helm-linux.tar.gz \
    && mv linux-${TARGETARCH}/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm completion bash >/etc/bash_completion.d/helm \
    && rm helm-linux.tar.gz \
    && rm -rf linux-${TARGETARCH}

# https://storage.googleapis.com/kubernetes-release/release/stable.txt
ARG KUBECTL_VERSION=1.23.5
RUN echo "# Installing kubectl..." \
     #
    # Install kubectl
    && curl -o /usr/local/bin/kubectl -sSL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    # kubectl bash completion
    && kubectl completion bash >/etc/bash_completion.d/kubectl

# https://github.com/ahmetb/kubectx/releases
ARG KUBECTX_VERSION=0.9.4
RUN echo "# Installing kubectx and kubens..." \
    #
    # Install kubectx and kubens
    && curl -sSL https://github.com/ahmetb/kubectx/archive/v${KUBECTX_VERSION}.tar.gz | tar xvz \
    && mv kubectx-${KUBECTX_VERSION}/kubectx /usr/local/bin/kubectx \
    && mv kubectx-${KUBECTX_VERSION}/kubens /usr/local/bin/kubens \
    && chmod +x /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubens \
    # kubectx and kubens bash completion
    && mv kubectx-${KUBECTX_VERSION}/completion/kubectx.bash /etc/bash_completion.d/kubectx \
    && mv kubectx-${KUBECTX_VERSION}/completion/kubens.bash /etc/bash_completion.d/kubens

# https://github.com/wercker/stern/releases
ARG STERN_VERSION=1.11.0
# stern is only availabe for amd64 architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        echo "# Installing stern..." \
        #
        # Install stern
        && curl -o /usr/local/bin/stern -sSL "https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64"  \
        && chmod +x /usr/local/bin/stern \
        # stern bash completion
        && stern --completion=bash bash >/etc/bash_completion.d/stern; \
    fi

# https://github.com/derailed/k9s/releases
ARG K9S_VERSION=0.25.18
RUN echo "# Installing k9s..." \
     #
    # Install k9s
    && if [ "$TARGETARCH" = "amd64" ]; then TARGET=x86_64; else TARGET=$TARGETARCH; fi \
    && curl -sSL "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGET}.tar.gz" | tar xzf - k9s  \
    && mv k9s /usr/local/bin \
    && chmod +x /usr/local/bin/k9s

# https://github.com/weaveworks/eksctl/releases
ARG EKSCTL_VERSION=0.92.0
RUN echo "# Installing eksctl..." \
    #
    # Install eksctl
    && curl -sSL "https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_Linux_${TARGETARCH}.tar.gz" | tar xz  \
    && mv eksctl /usr/local/bin \
    && chmod +x /usr/local/bin/eksctl \
    && eksctl completion bash >/etc/bash_completion.d/eksctl

# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst
ARG AWSCLI_VERSION=2.5.4
RUN echo "# Installing awscli..." \
    && if [ "$TARGETARCH" = "arm64" ]; then TARGET=aarch64; elif [ "$TARGETARCH" = "amd64" ]; then TARGET=x86_64; else TARGET=$TARGETARCH; fi \
    #
    # Install AWS CLI v2
    && curl -o "awscliv2.zip" -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${TARGET}-${AWSCLI_VERSION}.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /opt/aws-cli \
    && rm awscliv2.zip \
    && rm -rf aws \
    # Configure aws bash completion for the non-root user
    && printf "\ncomplete -C '/usr/local/bin/aws_completer' aws\n" >> /home/${USER_NAME}/.bashrc

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt
RUN apt-get update

RUN echo "# Installing groff, less and jq..." \
    #
    # Install groff, less and jq
    && apt-get -y install --no-install-recommends groff less jq

# Clean up apt
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USER_NAME
