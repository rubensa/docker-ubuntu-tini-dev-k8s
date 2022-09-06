#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-k8"

docker exec -it \
  "${DOCKER_IMAGE_NAME}" \
  bash -l
