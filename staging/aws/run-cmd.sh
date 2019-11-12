#!/bin/bash

# Runs this command on all docker swarm nodes
DOCKER_COMMAND=$1

docker-machine ls | cut -c 1-4 | grep vm* | xargs -t -I"SERVER" /bin/bash -c "docker-machine ssh SERVER '$DOCKER_COMMAND'"