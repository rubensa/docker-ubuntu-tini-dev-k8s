# Docker image with Kubernetes tools

This is a Docker image based on [rubensa/ubuntu-tini-dev](https://github.com/rubensa/docker-ubuntu-tini-dev) and includes various kubernetes tools.

## Building

You can build the image like this:

```
#!/usr/bin/env bash

docker build --no-cache \
  -t "rubensa/ubuntu-tini-dev-k8s" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  .
```

## Running

You can run the container like this (change --rm with -d if you don't want the container to be removed on stop):

```
#!/usr/bin/env bash

# Get current user UID
USER_ID=$(id -u)
# Get current user main GID
GROUP_ID=$(id -g)

prepare_docker_timezone() {
  # https://www.waysquare.com/how-to-change-docker-timezone/
  ENV_VARS+=" --env=TZ=$(cat /etc/timezone)"
}

prepare_docker_user_and_group() {
  RUNNER+=" --user=${USER_ID}:${GROUP_ID}"
}

prepare_docker_timezone
prepare_docker_user_and_group

docker run --rm -it \
  --name "ubuntu-tini-dev-k8s" \
  ${ENV_VARS} \
  ${RUNNER} \
  rubensa/ubuntu-tini-dev-k8s "$@"
```

*NOTE*: Mounting /etc/timezone and /etc/localtime allows you to use your host timezone on container.

This way, the internal user UID an group GID are changed to the current host user:group launching the container and the existing files under his internal HOME directory that where owned by user and group are also updated to belong to the new UID:GID.

## Connect

You can connect to the running container like this:

```
#!/usr/bin/env bash

docker exec -it \
  ubuntu-tini-dev-k8s \
  bash -l
```

This creates a bash shell run by the internal user.

Once connected...

You can check installed develpment software:

```
jq --version
helm version
kubectl version
aws-iam-authenticator version
eksctl version
kubectx
kubens
aws --version
```

## Stop

You can stop the running container like this:

```
#!/usr/bin/env bash

docker stop \
  ubuntu-tini-dev-k8s
```

## Start

If you run the container without --rm you can start it again like this:

```
#!/usr/bin/env bash

docker start \
  ubuntu-tini-dev-k8s
```

## Remove

If you run the container without --rm you can remove once stopped like this:

```
#!/usr/bin/env bash

docker rm \
  ubuntu-tini-dev-k8s
```
