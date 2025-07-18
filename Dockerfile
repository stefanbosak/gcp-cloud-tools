# user in container
ARG CONTAINER_USER=user
ARG CONTAINER_GROUP=user

ARG CONTAINER_USER_ID=1000
ARG CONTAINER_GROUP_ID=1000

# set location of workspace directory
# (temporary space within container image)
ARG WORKSPACE_ROOT_DIR="/home/${CONTAINER_USER}"

# Debian release and options
ARG DEBIAN_RELEASE=testing-slim
ARG DEBIAN_FRONTEND=noninteractive

# ansible CLI tools versions
ARG ANSIBLE_CLI_VERSION=2.19.0b7

# Helm version
ARG HELM_CLI_VERSION=v3.18.4

# kubectl version
ARG K9S_CLI_VERSION=v0.50.9

# kubectl version
ARG KUBECTL_CLI_VERSION=v1.33.3

# kops version
ARG KOPS_CLI_VERSION=v1.32.1

# Terraform version
ARG TERRAFORM_CLI_VERSION=1.12.2

# Terragrunt version
ARG TERRAGRUNT_CLI_VERSION=v0.83.2

# gcloud CLI version
ARG GCLOUD_CLI_VERSION=530.0.0

# container as builder for preparing GCP cloud tools
FROM debian:${DEBIAN_RELEASE} AS gcp-cloud-tools-builder

LABEL stage="gcp-cloud-tools-builder" \
      description="Debian-based container builder for preparing GCP cloud tools" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tools" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG DEBIAN_FRONTEND

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install required packages and additional applications
RUN apt-get update && \
    apt-get -y --no-install-recommends install ca-certificates binutils curl unzip && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*"

# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-ansible-cli-builder

LABEL stage="gcp-cloud-tools-ansible-cli-builder" \
      description="Debian-based container builder for preparing GCP cloud tool ansible" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool ansible" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG ANSIBLE_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download and install ansible tool
RUN apt-get -y --no-install-recommends install python3-pip && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*"
RUN python3 -m pip install --break-system-packages  "https://github.com/ansible/ansible/archive/refs/tags/${ANSIBLE_CLI_VERSION}.tar.gz"
    
# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-helm-builder

LABEL stage="gcp-cloud-tools-helm-builder" \
      description="Debian-based container builder for preparing GCP cloud tool HELM CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool HELM CLI" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG HELM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download HELM archive file
ADD "https://get.helm.sh/helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install HELM
RUN mkdir -v "${WORKSPACE_ROOT_DIR}/helm" && tar -zxf "helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" -C "/usr/local/bin" --strip-components 1 --no-anchored "helm"


# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-kops-builder

LABEL stage="gcp-cloud-tools-kops-builder" \
      description="Debian-based container builder for preparing GCP cloud tool kops CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool kops CLI" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KOPS_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://github.com/kubernetes/kops/releases/download/${KOPS_CLI_VERSION}/kops-${TARGETOS}-${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/"

# install kubectl
RUN install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/kops-${TARGETOS}-${TARGETARCH}" "/usr/local/bin/kops"


# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-kubectl-builder

LABEL stage="gcp-cloud-tools-kubectl-builder" \
      description="Debian-based container builder for preparing GCP cloud tool kubectl CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool kubectl CLI" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KUBECTL_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://dl.k8s.io/release/${KUBECTL_CLI_VERSION}/bin/linux/${TARGETARCH}/kubectl" "${WORKSPACE_ROOT_DIR}/"

# install kubectl
RUN install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/kubectl" "/usr/local/bin/"


# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-k9s-builder

LABEL stage="gcp-cloud-tools-k9s-builder" \
      description="Debian-based container builder for preparing GCP cloud tool k9s CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool k9s CLI" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG K9S_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download k9s CLI binary file
ADD "https://github.com/derailed/k9s/releases/download/${K9S_CLI_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install k9s
RUN tar -zxf "k9s_Linux_${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "k9s"

# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-terraform-builder

LABEL stage="gcp-cloud-tools-terraform-builder" \
      description="Debian-based container builder for preparing GCP cloud tool terraform" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool terraform" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG TERRAFORM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download TF CLI archive file
ADD "https://releases.hashicorp.com/terraform/${TERRAFORM_CLI_VERSION}/terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" "${WORKSPACE_ROOT_DIR}/"

# install TF CLI binary
RUN unzip "terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" -d "/usr/local/bin/"


# container as builder for preparing GCP cloud tools
FROM gcp-cloud-tools-builder AS gcp-cloud-tools-terragrunt-builder

LABEL stage="gcp-cloud-tools-kubectl-builder" \
      description="Debian-based container builder for preparing GCP cloud tool terragrunt CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing GCP cloud tool terragrunt CLI" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG TERRAGRUNT_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_CLI_VERSION}/terragrunt_${TARGETOS}_${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/"

# install terragrunt CLI
RUN install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/terragrunt_${TARGETOS}_${TARGETARCH}" "/usr/local/bin/terragrunt"


# container as final image for providing GCP cloud tools
FROM debian:${DEBIAN_RELEASE} AS gcp-cloud-tools-image

LABEL stage="gcp-cloud-tools-image" \
      description="Debian-based container with GCP cloud tools" \
      org.opencontainers.image.description="Debian-based container with GCP cloud tools" \
      org.opencontainers.image.source=https://github.com/stefanbosak/gcp-cloud-tools

# user in container
ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

ARG GCLOUD_CLI_VERSION

ARG DEBIAN_FRONTEND

# set locales
ENV LANG=C.UTF-8
ENV TZ=UTC

# setup user profile
RUN if ! getent passwd ${CONTAINER_USER_ID}; then \
        groupadd --gid ${CONTAINER_GROUP_ID} "${CONTAINER_GROUP}" && \
        useradd --gid ${CONTAINER_GROUP_ID} --groups "sudo,${CONTAINER_USER}" -M -d "${WORKSPACE_ROOT_DIR}" --uid ${CONTAINER_USER_ID} "${CONTAINER_USER}" -s "/bin/bash"; \
    else \
        rm -fr "/home/${CONTAINER_USER}" && \
        usermod -M -d "${WORKSPACE_ROOT_DIR}" -c "${CONTAINER_USER}" "debian" && \
        groupmod -n "${CONTAINER_USER}" "debian" && \
        usermod -l "${CONTAINER_USER}" "debian" && \
        chown -R "${CONTAINER_USER}:${CONTAINER_GROUP}" "${WORKSPACE_ROOT_DIR}"; \
    fi && \
# SSH client configuration
    mkdir -v "/home/${CONTAINER_USER}/.ssh" && \
    echo "Host *\n" \
         "IdentitiesOnly yes\n" \
         "ControlPath ~/.ssh/_controlmasters-%r@%h:%p\n" \
         "ControlMaster auto\n" \
         "ControlPersist yes\n" \
         "AddressFamily inet\n" \
         "TCPKeepAlive yes\n" \
         "ConnectionAttempts 1\n" \
         "ConnectTimeout 5\n" \
         "ServerAliveCountMax 2\n" \
         "ServerAliveInterval 15\n" > "/home/${CONTAINER_USER}/.ssh/config" && \
    mkdir -v "/home/${CONTAINER_USER}/scripts"

# copy Google Cloud Platform helper scripts into user profile inside container image
COPY ./scripts "/home/${CONTAINER_USER}/scripts/"

# make sure about owner consistency of user profile directory content
RUN chown -vR ${CONTAINER_USER}:${CONTAINER_GROUP} "/home/${CONTAINER_USER}" && \
# install required packages
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y --no-install-recommends install ca-certificates curl wget openssl gnupg \
                                               openssh-client autossh plocate sudo \
                                               iputils-ping iproute2 mtr nmap lsof \
                                               mariadb-client postgresql-client sqlite3 \
                                               dnsutils whois dialog python3-argcomplete \
                                               bc inotify-tools git jq less locales \
                                               bash-completion nano screen tmux vim && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*" && \
# set locale to UTF-8
    sed --in-place '/en_US.UTF-8/s/^# //' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=C.UTF-8 && \
# disable bell and startup message for screen
    sed --in-place 's/vbell on/vbell off/;/startup_message off/s/^#//' /etc/screenrc && \
# allow sudo without password for CONTAINER_USER
    echo "${CONTAINER_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${CONTAINER_USER}" && \
# update plocate database
    updatedb && \
# enable tools completions (not required to run any tool)
    cp "/etc/skel/.bashrc" "/root" && \
    cp "/etc/skel/.bashrc" "${WORKSPACE_ROOT_DIR}" && \
    cp "/etc/skel/.profile" "${WORKSPACE_ROOT_DIR}" && \
    echo "complete -C terraform terraform" > "/usr/share/bash-completion/completions/terraform" && \
    echo "complete -C terragrunt terragrunt" > "/usr/share/bash-completion/completions/terragrunt"

# transfer tools from builders
COPY --from=gcp-cloud-tools-ansible-cli-builder "/usr/local/bin" "/usr/local/bin"
COPY --from=gcp-cloud-tools-ansible-cli-builder "/usr/local/lib/" "/usr/local/lib"
COPY --from=gcp-cloud-tools-helm-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=gcp-cloud-tools-kops-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=gcp-cloud-tools-kubectl-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=gcp-cloud-tools-k9s-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=gcp-cloud-tools-terraform-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=gcp-cloud-tools-terragrunt-builder "/usr/local/bin/" "/usr/local/bin/"

# install gcloud CLI tooling
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && \
    apt-get install -y \
    google-cloud-cli=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-gke-gcloud-auth-plugin=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-kpt=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-skaffold=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-kubectl-oidc=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-local-extract=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-log-streaming=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-terraform-tools=${GCLOUD_CLI_VERSION}-0 \
    google-cloud-cli-docker-credential-gcr=${GCLOUD_CLI_VERSION}-0 && \
# enable tools completions (required to run given tool to generate completion file content)
    helm completion bash > "/usr/share/bash-completion/completions/helm" && \
    kops completion bash > "/usr/share/bash-completion/completions/kops" && \
    kubectl completion bash > "/usr/share/bash-completion/completions/kubectl" && \
    cp "/usr/share/bash-completion/completions/kubectl" "/usr/share/bash-completion/completions/k" && \
    sed -i 's/kubectl/k/g' "/usr/share/bash-completion/completions/k" && \
    ln -s /usr/local/bin/kubectl /usr/local/bin/k && \
    k9s completion bash > "/usr/share/bash-completion/completions/k9s" && \
    activate-global-python-argcomplete && \
# DiD (Docker in Docker)
# - DinD via QEMU on ARM64 is not supported
#   (ARM64 requires ARM64 kernel from host system which is not present on AMD64 host)
    curl -fsSL https://get.docker.com | sh && \
    if ! getent group docker > /dev/null 2>&1; then \
      groupadd docker; \
    fi && \
    usermod -aG docker "${CONTAINER_USER}" && \
    sed -i 's/ulimit -Hn 524288/#ulimit -Hn 524288/' /etc/init.d/docker && \
# install kubectl CNPG plugin
    curl -sSfL https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | \
    sh -s -- -b /usr/local/bin && \
    ln -s /usr/local/bin/kubectl-cnpg /usr/local/bin/cnpgctl && \
    cnpgctl completion bash > /usr/share/bash-completion/completions/kubectl-cnpg && \
# install kubectl RabbitMQ plugin
    curl -sSfL https://raw.githubusercontent.com/rabbitmq/cluster-operator/refs/heads/main/bin/kubectl-rabbitmq > /usr/local/bin/kubectl-rabbitmq && \
    chmod a+x /usr/local/bin/kubectl-rabbitmq && \
    ln -s /usr/local/bin/kubectl-rabbitmq /usr/local/bin/rmqctl

# install kubectl cert-manager plugin
SHELL ["/bin/bash", "-c"]
RUN export CMCTL_VERSION=$(git ls-remote --refs --sort='version:refname' --tags "https://github.com/cert-manager/cmctl" | awk -F"/" '!($0 ~ /alpha|beta|rc|dev|nightly|\{/){print $NF}' | tail -n 1) && \
    wget https://github.com/cert-manager/cmctl/releases/download/${CMCTL_VERSION}/cmctl_linux_amd64 -O /usr/local/bin/kubectl-cert_manager && \
    chmod a+x /usr/local/bin/kubectl-cert_manager && \
    ln -s /usr/local/bin/kubectl-cert_manager /usr/local/bin/cmctl && \
    cmctl completion bash > /usr/share/bash-completion/completions/cmctl

# user home directory as workdir
WORKDIR "/home/${CONTAINER_USER}"

# container user and group
USER "${CONTAINER_USER}:${CONTAINER_GROUP}"

# open shell
CMD ["bash"]
