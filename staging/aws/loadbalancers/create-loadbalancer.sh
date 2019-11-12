#!/bin/bash
set -e 

source ./../security-groups.sh

function _create_load_balancer(){
    get_load_balancer_security_group_id
    aws elbv2 create-load-balancer --name $load_balancer_name \
                                --subnets $DEFAULT_VPC_SUBNET1_ID $DEFAULT_VPC_SUBNET2_ID \
                                --scheme internet-facing \
                                --security-groups $loadbalancer_security_group_id sg-846664fb \
                                --type application
}

function create_load_balancer(){
    load_balancer_arn=$(_create_load_balancer | jq -r '.LoadBalancers | .[] | .LoadBalancerArn')
    echo "LoadBalancer ARN: $load_balancer_arn"
}

# load_balancer_name=$1

# create_load_balancer

# Usage
# ./create-loadbalancer staging-portainer-lb