# syntax=docker/dockerfile:1.4
FROM rubensa/ubuntu-tini-dev:20.04
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Architecture component of TARGETPLATFORM (platform of the build result)
ARG TARGETARCH

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# https://github.com/helm/helm/releases
ARG HELM_VERSION=4.0.4
RUN <<EOT
echo "# Installing helm..."
#
# Install HELM
cd /tmp
curl -o helm-linux.tar.gz -sSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz
tar xvfz helm-linux.tar.gz
mv linux-${TARGETARCH}/helm /usr/local/bin/helm
chown root:root /usr/local/bin/helm
chmod 755 /usr/local/bin/helm
helm completion bash >/etc/bash_completion.d/helm
rm helm-linux.tar.gz
rm -rf linux-${TARGETARCH}
EOT

# https://github.com/kubernetes/kubectl/tags
# https://storage.googleapis.com/kubernetes-release/release/stable.txt
ARG KUBECTL_VERSION=1.31.0
RUN <<EOT
echo "# Installing kubectl..."
#
# Install kubectl
curl -o /usr/local/bin/kubectl -sSL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl
chown root:root /usr/local/bin/kubectl
chmod 755 /usr/local/bin/kubectl
# kubectl bash completion
kubectl completion bash >/etc/bash_completion.d/kubectl
EOT

# https://github.com/ahmetb/kubectx/releases
ARG KUBECTX_VERSION=0.9.5
RUN <<EOT
echo "# Installing kubectx and kubens..."
#
# Install kubectx and kubens
curl -sSL https://github.com/ahmetb/kubectx/archive/v${KUBECTX_VERSION}.tar.gz | tar xvz
mv kubectx-${KUBECTX_VERSION}/kubectx /usr/local/bin/kubectx
mv kubectx-${KUBECTX_VERSION}/kubens /usr/local/bin/kubens
chown root:root /usr/local/bin/kubectx
chmod 755 /usr/local/bin/kubectx
chown root:root /usr/local/bin/kubens
chmod 755 /usr/local/bin/kubens
# kubectx and kubens bash completion
mv kubectx-${KUBECTX_VERSION}/completion/kubectx.bash /etc/bash_completion.d/kubectx
mv kubectx-${KUBECTX_VERSION}/completion/kubens.bash /etc/bash_completion.d/kubens
# Clean up
rm -rf kubectx-${KUBECTX_VERSION}
EOT

# https://github.com/stern/stern/releases
ARG STERN_VERSION=1.33.1
RUN <<EOT
echo "# Installing stern..."
#
# Install stern
cd /tmp
curl -o stern_linux.tar.gz -sSL https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_${TARGETARCH}.tar.gz
mkdir -p /tmp/stern_linux
tar xvfz stern_linux.tar.gz -C /tmp/stern_linux
mv stern_linux/stern /usr/local/bin/stern
chown root:root /usr/local/bin/stern
chmod 755 /usr/local/bin/stern
stern --completion=bash >/etc/bash_completion.d/stern
rm stern_linux.tar.gz
rm -rf stern_linux
EOT

# https://github.com/derailed/k9s/releases
ARG K9S_VERSION=0.50.18
RUN <<EOT
echo "# Installing k9s..."
#
# Install k9s
curl -sSL "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" | tar xzf - k9s 
mv k9s /usr/local/bin
chown root:root /usr/local/bin/k9s
chmod 755 /usr/local/bin/k9s
k9s completion bash >/etc/bash_completion.d/k9s
EOT

# https://github.com/weaveworks/eksctl/releases
ARG EKSCTL_VERSION=0.221.0
RUN <<EOT
echo "# Installing eksctl..."
#
# Install eksctl
curl -sSL "https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_Linux_${TARGETARCH}.tar.gz" | tar xz 
mv eksctl /usr/local/bin
chown root:root /usr/local/bin/eksctl
chmod 755 /usr/local/bin/eksctl
eksctl completion bash >/etc/bash_completion.d/eksctl
EOT

# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst
# https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst
ARG AWSCLI_VERSION=2.32.32
RUN <<EOT
echo "# Installing awscli..."
if [ "$TARGETARCH" = "arm64" ]; then TARGET=aarch64; elif [ "$TARGETARCH" = "amd64" ]; then TARGET=x86_64; else TARGET=$TARGETARCH; fi
#
# Install AWS CLI v2
curl -o "awscliv2.zip" -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${TARGET}-${AWSCLI_VERSION}.zip"
unzip awscliv2.zip
./aws/install -i /opt/aws-cli
rm awscliv2.zip
rm -rf aws
# Configure aws bash completion for the non-root user
printf "\ncomplete -C '/usr/local/bin/aws_completer' aws\n" >> /home/${USER_NAME}/.bashrc
EOT

ADD aws-profile.sh /usr/local/bin/aws-profile.sh
RUN <<EOT
echo "# Installing aws-profile..."
#
# Enable aws-profile execution
chmod +x /usr/local/bin/aws-profile.sh
#
# Configure aws-profile for the non-root user
printf "\n. /usr/local/bin/aws-profile.sh\n" >> /home/${USER_NAME}/.bashrc 
EOT

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt
RUN apt-get update

RUN <<EOT
echo "# Installing groff and less..."
#
# Install groff and less
apt-get -y install --no-install-recommends groff less
EOT

# Clean up apt
RUN <<EOT
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOT

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME=/home/$USER_NAME
