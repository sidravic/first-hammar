#!/bin/bash


eval $(docker-machine env vm1)

docker node update --label-add stateless=true vm1
docker node update --label-add stateless=true vm2

#unallocated
docker node update --label-add stateful=true vm3
docker node update --label-add elasticsearch=true vm3


# Logging
docker node update --label-add stateful=true vm4
docker node update --label-add elasticsearch=true vm4
docker node update --label-add kibana=true vm4
docker node update --label-add logstash=true vm4


#Redis
docker node update --label-add stateful=true vm5
docker node update --label-add redis=true vm5

#Unallocated
docker node update --label-add stateful=true vm6
docker node update --label-add elasticsearch=true vm6
docker node update --label-add kibana=true vm6
