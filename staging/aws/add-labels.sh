#!/bin/bash


eval (docker-machine env vm1)

docker node update --label-add stateless=true vm1
docker node update --label-add stateless=true vm2
docker node update --label-add stateless=true vm3

docker node update --label-add stateful=true vm4
docker node update --label-add elasticsearch=true vm4
docker node update --label-add kibana=true vm4
docker node update --label-add logstash=true vm4

docker node update --label-add stateful=true vm5
docker node update --label-add stateful=redis vm5

docker node update --label-add stateful=true vm6

