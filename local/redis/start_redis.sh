#!/bin/bash


# /usr/bin/docker run --name redis \
#                       --rm \
#                       --sysctl net.core.somaxconn=511 \
#                       --publish 127.0.0.1:6379:6379 \
#                       redis:4.0-alpine
#
# Docker-compose
#sysctls:
#  net.core.somaxconn: '511'




docker run -it --sysctl net.core.somaxconn=511 \
               --env-file ./development.env \
               -p '6380:6379' -v /home/sidravic/Dropbox/code/workspace/rails_apps/idylmynds/first-hammar/stateful_data/redis/development:/data \
               ephemeral-tower redis-server /etc/redis/redis.conf 