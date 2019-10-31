#!/bin/bash

source ./../../login-registry-gitlab.sh

project_name=postgres
registry_path=${GITLAB_REGISTRY}/$project_name
timestamp=$(date +%s)
tag_name="${project_name}-${timestamp}"
latest_tag_name="${project_name}-latest"

echo "Registry path is ${registry_path}"
echo "tag_name-${tag_name}"

docker build -t postgres .
docker tag postgres:latest ${GITLAB_REGISTRY}/goglance/first-hammar:$tag_name 
echo "Tag created: ${tag_name}"
docker tag logstash:latest ${GITLAB_REGISTRY}/goglance/first-hammar:$latest_tag_name
echo "Tag create: $latest_tag_name"

echo "Pushing ${GITLAB_REGISTRY}/goglance/first-hammar:$tag_name"
docker push ${GITLAB_REGISTRY}/goglance/first-hammar:$tag_name

#echo "Pushing latest tag"
#docker push ${GITLAB_REGISTRY}/goglance/first-hammar:$latest_tag_name
