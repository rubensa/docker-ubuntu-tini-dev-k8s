#!/usr/bin/env bash

docker build --no-cache \
  -t "rubensa/ubuntu-tini-dev-k8s:18.04" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  .
