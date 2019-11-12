#!/bin/bash

# Runs this command on all docker swarm nodes
DOCKER_COMMAND="docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=$AWS_ACCESS_KEY_ID EBS_SECRETKEY=$AWS_SECRET_ACCESS_KEY --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true"
docker-machine ls | cut -c 1-4 | grep vm* | xargs -t -I"SERVER" /bin/bash -c "docker-machine ssh SERVER '${DOCKER_COMMAND}'"