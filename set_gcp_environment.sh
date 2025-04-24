#!/bin/bash
export CLUSTER_NAME=
export REGION=
export PROJECT_ID=
export PROJECT_NUMBER=

gcloud auth login
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${REGION}
gcloud config set compute/region ${REGION}
