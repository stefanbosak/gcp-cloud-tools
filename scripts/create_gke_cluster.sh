#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# load environment details
source "${cwd}/set_gcp_environment.sh"

# create GKE cluster via autopilot
gcloud beta container --project "${PROJECT_NAME}" clusters create-auto "${CLUSTER_NAME}" \
                      --region "${REGION}" --release-channel "${CLUSTER_RELEASE_CHANNEL}" --tier "${CLUSTER_TIER}" \
                      --enable-dns-access --enable-ip-access --no-enable-google-cloud-access \
                      --network "projects/${PROJECT_ID}/global/networks/default" \
                      --subnetwork "projects/${PROJECT_NAME}/regions/${REGION}/subnetworks/default" \
                      --cluster-ipv4-cidr "${CLUSTER_POD_CDIR}" --services-ipv4-cidr "${CLUSTER_SERVICE_CDIR}" \
                      --binauthz-evaluation-mode=DISABLED --fleet-project="${PROJECT_NAME}"
