#!/usr/bin/env bash

docker build --no-cache \
  -t "rubensa/ubuntu-tini-dev-k8s:20.04" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  .
