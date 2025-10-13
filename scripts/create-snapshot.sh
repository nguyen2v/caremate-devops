#!/bin/bash

SERVER_NAME=$1

case "${SERVER_NAME}" in
dhp-server | doculus-server | jitsi-server)
  echo "Creating snapshot for ${SERVER_NAME}"
  ;;
*)
  echo "Usage: ./scripts/create-snapshot.sh SERVER_NAME"
  echo "SERVER_NAME must be one of dhp-server|jitsi-server"
  exit 1
  ;;
esac

set -x

SNAPSHOT_NAME=${SERVER_NAME}-$(date +"%Y-%m-%d")
SOURCE_DISK=${SERVER_NAME}-disk

gcloud compute snapshots create "${SNAPSHOT_NAME}" \
  --async \
  --source-disk-zone=asia-southeast1-c \
  --source-disk="${SOURCE_DISK}" \
  --storage-location=asia-southeast1
