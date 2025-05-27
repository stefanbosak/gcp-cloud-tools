#!/bin/bash
#
# Wrapper for standalone installation of GCP cloud tools
#
# NOTEs:
# - user has to have root priviledges / sudo to execute standalone-install.sh
#
cwd=$(dirname $(realpath "${0}"))

# directory for storing capture of pushed versions
PUSHED_CLI_VERSIONS_FILE_DIR=$(mktemp -d)

# set variables
source "${cwd}/setvariables.sh"

# check if previous environment file exists and remove
if [ -f "${GITHUB_ENV_TAIL_FILE}" ]; then
  rm -f "${GITHUB_ENV_TAIL_FILE}"
fi

# set variables
source "${cwd}/setvariables.sh"

# create temporary directory as workspace
WORKSPACE_ROOT_DIR=${WORKSPACE_ROOT_DIR:-"$(mktemp -d)"}

# cleanup handler (tidy up workspace)
trap 'rm -vfr "${WORKSPACE_ROOT_DIR}" "${GITHUB_ENV_TAIL_FILE}"' EXIT

echo "Initializing workspace ${WORKSPACE_ROOT_DIR}..."

# create workspace directory
if [ ! -d "${WORKSPACE_ROOT_DIR}" ]; then
  mkdir -pv "${WORKSPACE_ROOT_DIR}"
fi

# go to workspace directory
pushd "${WORKSPACE_ROOT_DIR}"

bash_completion_dir="/usr/share/bash-completion/completions"

if [ ! -d "${bash_completion_dir}" ]; then
  mkdir -pv "${bash_completion_dir}"
fi

# uninstallation
if [ "${1}" == "-u" ]; then
  # list of applications supported by this standalone-install script
  declare -a applications_array=("helm" "k9s" "kops" "kubectl" "terraform" "terragrunt")

  echo "Removing applications installed by ${cwd}/${0}..."

  for application in "${applications_array[@]}"; do
    # search for application and make sure not removing variant installed by default system package utility
    application_path="$(which ${application} | grep local)"

    if [ ! -z "${application_path}" ]; then
      if [ -f "${application_path}" ]; then
        rm -vf "${application_path}"
      fi
    fi

    application_completion_path="${bash_completion_dir}/${application}"

    if [ -f "${application_completion_path}" ]; then
      echo "Removing completion for ${application}"
      rm -vf "${application_completion_path}"
    fi
  done

  echo "Removing has been finnished."
  exit 0
fi

# install required packages
declare -a tools_array=("curl" "dialog" "unzip")

for tool in "${tools_array[@]}"; do
  if [ -z "$(which ${tool})" ]; then
    echo -ne "Installing ${tool}..."

    if [ -f "/etc/debian_version" ]; then
      LINUX_DISTRIBUTION="ubuntu"
      PACKAGE_MANAGER_SUFFIX="deb"
      PACKAGE_MANAGER_CMD="dpkg -i"
      apt-get -y --no-install-recommends install "${tool}"
    elif [ -f "/etc/redhat-release" ]; then
      LINUX_DISTRIBUTION="linux"
      PACKAGE_MANAGER_SUFFIX="rpm"
      PACKAGE_MANAGER_CMD="rpm -i"
      rpm --nosuggest install unzip
    elif [ -f "/etc/centos-release" ]; then
      LINUX_DISTRIBUTION="linux"
      PACKAGE_MANAGER_SUFFIX="rpm"
      PACKAGE_MANAGER_CMD="yum localinstall"
      yum install "${tool}"
    fi

    if [ -z "$(which ${tool})" ]; then
      echo "Installation of ${tool} has failed (check details in your system), terminating..."
      exit 1
    fi
  fi
done

# dictionary of resources for download
declare -A resources_dictionary

resources_dictionary["kops"]="https://github.com/kubernetes/kops/releases/download/${KOPS_CLI_VERSION}/kops-${TARGETOS}-${TARGETARCH}"
resources_dictionary["kubectl"]="https://dl.k8s.io/release/${KUBECTL_CLI_VERSION}/bin/linux/${TARGETARCH}/kubectl"
resources_dictionary["k9s"]="https://github.com/derailed/k9s/releases/download/${K9S_CLI_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz"
resources_dictionary["helm"]="https://get.helm.sh/helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz"
resources_dictionary["terraform"]="https://releases.hashicorp.com/terraform/${TERRAFORM_CLI_VERSION}/terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip"
resources_dictionary["terragrunt"]="https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_CLI_VERSION}/terragrunt_${TARGETOS}_${TARGETARCH}"

## now loop through the above dictionary items
for key in "${!resources_dictionary[@]}"; do
  echo -ne "Downloading [${key}] ( ${resources_dictionary[$key]} ) ..."
  curl -sLJSO "${resources_dictionary[$key]}"

  if [ ${?} -eq 0 ]; then
    echo "[OK]"
  else
    echo "[FAIL]"
    exit 1
  fi
done

# install HELM
echo "Installing HELM CLI..."
tar -zxf "helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" -C "/usr/local/bin" --strip-components 1 --no-anchored "helm"

if [ ${?} -eq 0 ]; then
  echo "Tool helm has been installed successfully"
else
  echo "Tool helm has not been installed, terminating"
  exit 1
fi

# install kops
echo "Installing kops CLI..."
bash -c "install -v -o root -g root -m 0755 ${WORKSPACE_ROOT_DIR}/kops-${TARGETOS}-${TARGETARCH} /usr/local/bin/kops"

if [ ${?} -eq 0 ]; then
  echo "Tool kops has been installed successfully"
else
  echo "Tool kops has not been installed, terminating"
  exit 1
fi

# install kubectl
echo "Installing kubectl CLI..."
bash -c "install -v -o root -g root -m 0755 ${WORKSPACE_ROOT_DIR}/kubectl /usr/local/bin/"

if [ ${?} -eq 0 ]; then
  echo "Tool kubectl has been installed successfully"
else
  echo "Tool kubectl has not been installed, terminating"
  exit 1
fi

# install k9s
echo "Installing k9s CLI..."
tar -zxf "k9s_Linux_${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "k9s"

if [ ${?} -eq 0 ]; then
  echo "Tool k9s has been installed successfully"
else
  echo "Tool k9s has not been installed, terminating"
  exit 1
fi

# install TF CLI
echo "Installing terraform..."
unzip -o "terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" -d "/usr/local/bin/"

if [ ${?} -eq 0 ]; then
  echo "Tool terraform has been installed successfully"
else
  echo "Tool terraform has not been installed, terminating"
  exit 1
fi

# install Terragrunt CLI
echo "Installing terragrunt..."
bash -c "install -v -o root -g root -m 0755 ${WORKSPACE_ROOT_DIR}/terragrunt_${TARGETOS}_${TARGETARCH} /usr/local/bin/terragrunt"

if [ ${?} -eq 0 ]; then
  echo "Tool terragrunt has been installed successfully"
else
  echo "Tool terragrunt has not been installed, terminating"
  exit 1
fi

echo "Installing gcloud tools..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
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
    google-cloud-cli-docker-credential-gcr=${GCLOUD_CLI_VERSION}-0

if [ ${?} -eq 0 ]; then
  echo "Tool gcloud has been installed successfully"
else
  echo "Tool gcloud has not been installed, terminating"
  exit 1
fi

echo "Enabling completion for HELM CLI..."
bash -c "helm completion bash > ${bash_completion_dir}/helm"

echo "Enabling completion for k9s CLI..."
bash -c "k9s completion bash > ${bash_completion_dir}/k9s"

echo "Enabling completion for kops CLI..."
bash -c "kops completion bash > ${bash_completion_dir}/kops"

echo "Enabling completion for kubectl CLI..."
bash -c "kubectl completion bash > ${bash_completion_dir}/kubectl"

echo "Enabling completion for terraform..."
bash -c "echo 'complete -C terraform terraform' > ${bash_completion_dir}/terraform"

echo "Enabling completion for terragrunt..."
bash -c "echo 'complete -C terragrunt terragrunt' > ${bash_completion_dir}/terragrunt"

echo "Enabling completion for GCLOUD CLI..."
bash -c "gcloud completion bash > ${bash_completion_dir}/gcloud"

popd
