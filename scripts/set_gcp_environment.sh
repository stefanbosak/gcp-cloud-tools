#!/bin/bash
export ACCOUNT=$(gcloud config get account 2> /dev/null)

if [ -z "${ACCOUNT}" ]; then
  # login to GCP
  gcloud auth login --no-launch-browser
  export ACCOUNT=$(gcloud config get account)
fi

# organization attributes
# gcloud organizations list
# gcloud organizations describe ${ORGANIZATION_ID}
export ORGANIZATION_NAME=
export ORGANIZATION_ID=
export ORGANIZATION_NUMBER=

# project attributes
# gcloud projects list
# gcloud config get-value project
# gcloud projects describe ${PROJECT_ID}
export PROJECT_NAME=

# gcloud projects list --format="table(projectId)"
export PROJECT_ID=

if [ -z "${PROJECT_ID}" ]; then
  echo "PROJECT_ID is not set, exitting..."
  exit 1
fi

# gcloud projects list --format="table(projectNumber)"
export PROJECT_NUMBER=

# location attributes
# gcloud compute regions list
# gcloud config get-value compute/region
export REGION=

if [ -z "${REGION}" ]; then
  echo "REGION is not set, exitting..."
  exit 1
fi

# cluster attributes
# gcloud container clusters list
# gcloud container clusters describe ${CLUSTER_NAME}
export CLUSTER_NAME=$(gcloud container clusters list --project "${PROJECT_ID}" --filter="zone:(${REGION})" --format="value(name)")

#export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

# configuration details
# gcloud config list
gcloud config set project "${PROJECT_ID}"
gcloud config set compute/zone "${REGION}"
gcloud config set compute/region "${REGION}"

if [ ! -z "${CLUSTER_NAME}" ]; then
  # get kube config file
  gcloud container clusters get-credentials "${CLUSTER_NAME}" --region "${REGION}" --project "${PROJECT_ID}"
fi
