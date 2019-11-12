#!/bin/bash

set -e
source ./register-targets.sh
source ./create-loadbalancer.sh
source ./create-listener.sh

function _create_target_group(){
    aws elbv2 create-target-group \
        --name $target_group_name \
        --protocol HTTP \
        --port $port \
        --target-type instance \
        --vpc-id $DEFAULT_VPC_ID \
        --health-check-protocol HTTP \
        --health-check-path /         
}

function create_target_group(){
    target_group_arn=$(_create_target_group | jq -r '.TargetGroups | .[] | .TargetGroupArn')
    echo "Target group arn: $target_group_arn"
}

target_group_name=$1
port=$2
load_balancer_name="${target_group_name}-lb"

echo "Creating target group with name: $target_group_name and port: $port"
create_target_group
register-targets
get_load_balancer_security_group_id
create_load_balancer
create_listener

# Usage
# ./create-target-groups staging-portainer 9000