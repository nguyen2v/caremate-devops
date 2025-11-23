#!/bin/bash

set -xe

SERVER_NAME=$1

case "${SERVER_NAME}" in
caremate-server | doculus-server | jitsi-server)
  echo "Creating snapshot for ${SERVER_NAME}"
  ;;
*)
  echo "Usage: ./scripts/create-snapshot.sh SERVER_NAME"
  echo "SERVER_NAME must be one of caremate-server|jitsi-server"
  exit 1
  ;;
esac

set -x

SNAPSHOT_NAME=${SERVER_NAME}-$(date +"%Y-%m-%d")
SOURCE_DISK=${SERVER_NAME}-disk

gcloud compute snapshots create "${SNAPSHOT_NAME}" \
  --async \
  --source-disk="${SOURCE_DISK}" \
  --source-disk-zone=asia-southeast1-c \
  --storage-location=asia
