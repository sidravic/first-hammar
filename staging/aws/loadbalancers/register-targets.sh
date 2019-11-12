#!/bin/bash

function find_all_swarm_instances(){
    aws ec2 describe-instances --filters "Name=tag-key, Values=swarm" | jq -r '.Reservations | .[] | .Instances | .[] | .InstanceId' > .instance_ids
    instance_ids=$(grep i- .instance_ids | tr '\n' ' ')     
}

function register-targets(){
    find_all_swarm_instances
    prepare_targets

    echo "Registering $targets to target_group: $target_group_arn"
    aws elbv2 register-targets \
              --target-group-arn $target_group_arn \
              --targets $targets
}

function prepare_targets(){
    sed -i -e 's/^/Id=/' .instance_ids
    targets=$(grep i- .instance_ids | tr '\n' ' ')
    echo "Targets found: $targets"
}

# Sequence
#------------------------------
# find_all_swarm_instances
# prepare_targets
# register_targets