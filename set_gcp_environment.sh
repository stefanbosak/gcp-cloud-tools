#!/bin/bash
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
export PROJECT_ID=
export PROJECT_NUMBER=

# location attributes
# gcloud compute regions list
export REGION=

# cluster attributes
# gcloud container clusters list
# gcloud container clusters describe ${CLUSTER_NAME}
export CLUSTER_NAME=

# configuration details
# gcloud config list

gcloud auth login
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${REGION}
gcloud config set compute/region ${REGION}
