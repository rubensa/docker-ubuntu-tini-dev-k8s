#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-chrome-k8s"

docker stop  \
  "${DOCKER_IMAGE_NAME}"
