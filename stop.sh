#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-k8s"

docker stop  \
  "${DOCKER_IMAGE_NAME}"
