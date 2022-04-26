#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-chrome-k8s"

docker start \
  "${DOCKER_IMAGE_NAME}"
