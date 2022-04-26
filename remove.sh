#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-chrome-k8s"

docker rm \
  "${DOCKER_IMAGE_NAME}"
