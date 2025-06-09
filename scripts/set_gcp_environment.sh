#!/bin/bash
# try to gather data about account
export ACCOUNT=$(gcloud config get account 2> /dev/null)

# test if any account data has been extracted:
# - not empty: user already passed login procedure successfully
# - empty: user need to go through login procedure
if [ -z "${ACCOUNT}" ]; then
  # login to GCP
  gcloud auth login --no-launch-browser

  # gather account data
  export ACCOUNT=$(gcloud config get account)
fi

# organization attributes
# gcloud organizations list
# gcloud organizations describe ${ORGANIZATION_ID}
export ORGANIZATION_ID=
export ORGANIZATION_NUMBER=${ORGANIZATION_ID}
export ORGANIZATION_NAME=$( gcloud organizations describe "${ORGANIZATION_ID}" --format="json" | jq -r '.displayName')

# project attributes
# gcloud projects list
# gcloud config get-value project

# gcloud projects list --format="table(projectId)"
export PROJECT_ID=

# PROJECT_ID is required attribute, if empty terminate
if [ -z "${PROJECT_ID}" ]; then
  echo "PROJECT_ID is not set, exitting..."
  exit 1
fi

# gcloud projects describe ${PROJECT_ID}
export PROJECT_NAME=$(gcloud projects describe "${PROJECT_ID}" --format="json(name)" | jq -r .name)

# gcloud projects list --format="table(projectNumber)"
export PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="json(projectNumber)" | jq -r .projectNumber)

# location attributes
# gcloud compute regions list
# gcloud config get-value compute/region
export REGION=$(gcloud config get-value compute/region)

# REGION is required attribute, if empty terminate
if [ -z "${REGION}" ]; then
  echo "REGION is not set, exitting..."
  exit 1
fi

# cluster attributes
#
# NOTE: currently only one cluster is supported, working with more clusters would be added later
#
# gcloud container clusters list
# gcloud container clusters describe ${CLUSTER_NAME}
export CLUSTER_NAME=$(gcloud container clusters list --project "${PROJECT_ID}" --filter="zone:(${REGION})" --format="value(name)")

# GGP access token extraction
#
# NOTE: try to eliminate using of access tokens in general (not recommended)
#
#export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)

# configuration details
# gcloud config list
gcloud config set project "${PROJECT_ID}"
gcloud config set compute/zone "${REGION}"
gcloud config set compute/region "${REGION}"

# extract cluster credentails for kubectl only when cluster previously recognized
if [ ! -z "${CLUSTER_NAME}" ]; then
  # get kube config file
  gcloud container clusters get-credentials "${CLUSTER_NAME}" --region "${REGION}" --project "${PROJECT_ID}"
fi

export REGION=$(echo "${REGION}" | sed 's/-.$//')

# authentication to artifact repository
gcloud auth configure-docker ${REGION}-docker.pkg.dev
