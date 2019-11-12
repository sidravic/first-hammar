#!/bin/bash

source ./../security-groups.sh

function create_loadbalancer_security_group(){
    echo "Creating security group for loadbalancer..."
    invoke create lb-security-group "LoadBalancerSecurityGroup" $DEFAULT_VPC_ID
    loadbalancer_security_group_id=$security_group_id        
    get_swarm_security_group_id
    invoke open-port $swarm_security_group_id all $loadbalancer_security_group_id
}

create_loadbalancer_security_group