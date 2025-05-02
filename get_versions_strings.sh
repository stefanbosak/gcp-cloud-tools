#!/bin/bash
#
# Wrapper for recognizing latest available tools versions
#
cwd=$(dirname $(realpath "${0}"))

# site prefix
URI_PREFIX="https://github.com/"

# amount of latest versions strings to show
CLI_VERSIONS_AMOUNT=${CLI_VERSIONS_AMOUNT:-1}

# check prerequisites (if all required tools are available)
TOOLS="git"

for tool in ${TOOLS}; do
  if [ -z "$(which ${tool})" ]; then
    echo "Tool ${tool} has not been found, please install tool in your system"
    exit 1
  fi
done

# array of special version resources (need specific version handling)
declare -a resources_array=("TERRAFORM_CLI_VERSION"
                           )

declare -A resources_dictionary

resources_dictionary["ANSIBLE_CLI_VERSION"]="ansible/ansible"
resources_dictionary["HELM_CLI_VERSION"]="helm/helm"
resources_dictionary["K9S_CLI_VERSION"]="derailed/k9s"
resources_dictionary["KOPS_CLI_VERSION"]="kubernetes/kops"
resources_dictionary["KUBECTL_CLI_VERSION"]="kubernetes/kubernetes"
resources_dictionary["TERRAFORM_CLI_VERSION"]="hashicorp/terraform"
resources_dictionary["TERRAGRUNT_CLI_VERSION"]="gruntwork-io/terragrunt"

# sort resources dictionary keys
keys=$(echo "${!resources_dictionary[@]}" | tr ' ' '\n' | sort -V | tr '\n' ' ')

for key in ${keys}; do
  echo "${key}:"

  special_version_string_handling=0

  for resource in "${resources_array[@]}"; do
    if [ "${resource}" == "${key}" ]; then
      special_version_string_handling=1
      break
    fi
  done

  if [ ${special_version_string_handling} -eq 1 ]; then
    # specific handling of version string is required ("v" at the beggining has to be removed from version string)
    git ls-remote --refs --sort='version:refname' --tags "${URI_PREFIX}${resources_dictionary[$key]}" | awk -F"/" '!($0 ~ /alpha|beta|rc|dev|None|list|nightly|\{/){print $NF}' | tail -n ${CLI_VERSIONS_AMOUNT} | sed 's/^v//g'
  else
    git ls-remote --refs --sort='version:refname' --tags "${URI_PREFIX}${resources_dictionary[$key]}" | awk -F"/" '!($0 ~ /alpha|beta|rc|dev|None|list|nightly|\{/){print $NF}' | tail -n ${CLI_VERSIONS_AMOUNT}
  fi

  echo ";"
done

echo "GCLOUD_CLI_VERSION:"
curl -s "https://hub.docker.com/v2/repositories/google/cloud-sdk/tags?page=1&page_size=100" | jq -r '.results[].name | select(test("^\\d{3}\\.\\d+\\.\\d+$"))' | head -n ${CLI_VERSIONS_AMOUNT}
echo ";"
