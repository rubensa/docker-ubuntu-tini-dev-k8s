#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-k8"

docker stop  \
  "${DOCKER_IMAGE_NAME}"
