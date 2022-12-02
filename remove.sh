#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-dev-k8s"

docker rm \
  "${DOCKER_IMAGE_NAME}"
