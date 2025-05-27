#!/bin/bash
#
# Wrapper to obtain version metadata of tools inside docker container
#
# NOTEs:
# - any execution and modification(s) is only in responsibility of user
# - modify/align to fit user needs/requirements at your own
#
cwd=$(dirname $(realpath "${0}"))

DOCKER_CMD="${cwd}/docker-run.sh "

echo -ne "Try to run docker container and get hostname: "
${DOCKER_CMD} "hostname"

if [ ${?} -ne 0 ]; then
  echo "Docker run failed, see more above."
  exit 1
fi

echo -ne "ANSIBLE_CLI_VERSION="
ANSIBLE_CLI_VERSION_STR=$(${DOCKER_CMD} "ansible --version")
echo "${ANSIBLE_CLI_VERSION_STR}" | awk -F"core " '/core/{print "v"$2}' | sed 's/]//'

echo -ne "HELM_CLI_VERSION="
HELM_CLI_VERSION_STR=$(${DOCKER_CMD} "helm version --short")
echo "${HELM_CLI_VERSION_STR}" | awk -F'+' '{print $1}'

echo -ne "K9S_CLI_VERSION="
K9S_CLI_VERSION_STR=$(${DOCKER_CMD} "k9s version")
echo "${K9S_CLI_VERSION_STR}" | awk '/Version:/ {print $2}'

echo -ne "KOPS_CLI_VERSION="
KOPS_CLI_VERSION_STR=$(${DOCKER_CMD} "kops version")
echo "${KOPS_CLI_VERSION_STR}" | awk -F'git-' 'NR==1 {print $2}' | sed 's/)//'

echo -ne "KUBECTL_CLI_VERSION="
KUBECTL_CLI_VERSION_STR=$(${DOCKER_CMD} "kubectl version --client")
echo "${KUBECTL_CLI_VERSION_STR}" | awk -F': ' 'NR==1 {print $2}'
echo -ne "KUBECTL_CLI_VERSION="

echo -ne "TERRAFORM_CLI_VERSION="
TERRAFORM_CLI_VERSION_STR=$(${DOCKER_CMD} "terraform version")
echo "${TERRAFORM_CLI_VERSION_STR}" | awk -F'v' 'NR==1 {print $2}'

echo -ne "TERRAGRUNT_CLI_VERSION="
TERRAGRUNT_CLI_VERSION_STR=$(${DOCKER_CMD} "terragrunt --version")
echo "${TERRAGRUNT_CLI_VERSION_STR}" | awk 'NR==1 {print $NF}'

echo -ne "GCLOUD_CLI_VERSION="
GCLOUD_CLI_VERSION_STR=$(${DOCKER_CMD} "gcloud version")
echo "${GCLOUD_CLI_VERSION_STR}" | awk '/Google Cloud SDK/{print $NF}'
