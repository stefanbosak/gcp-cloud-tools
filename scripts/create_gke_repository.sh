#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# load environment details
source "${cwd}/set_gcp_environment.sh"

export REPOSITORY_NAME="${PROJECT_NAME}-repo"
export REPOSITORY_FORMAT="docker"

# create GCP cloud artifactory repository
gcloud artifacts repositories create "${REPOSITORY_NAME}" \
                                     --repository-format="${REPOSITORY_FORMAT}" \
                                     --location="${REGION}"
