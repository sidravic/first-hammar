#!/bin/bash

#!/bin/bash


source ./security-groups.sh

function create_worker_nodes(){
    docker-machine create --driver amazonec2 \
                          --amazonec2-region $DEFAULT_REGION \
                          --amazonec2-ami $DEFAULT_AMI_ID \
                          --amazonec2-instance-type t2.medium \
                          --amazonec2-keypair-name $DEFAULT_KEY_NAME \
                          --amazonec2-monitoring \
                          --amazonec2-root-size 30 \
                          --amazonec2-security-group swarm-security-group \
                          --amazonec2-tags swarm_worker,true,environment,staging,swarm,true \
                          --amazonec2-use-private-address \
                          --amazonec2-volume-type gp2 \
                          --amazonec2-vpc-id $DEFAULT_VPC_ID \
                          --amazonec2-monitoring \
                          --amazonec2-ssh-keypath $DEFAULT_KEY_PATH \
                          --amazonec2-zone $subnet_zone "$node_name" 
}

function find_subnet_zone(){
    if [ $(($i % 2)) -eq 0 ];
    then
        subnet_zone="c"
    else
        subnet_zone="b"
    fi
}

function create_3_manager_nodes(){
    for i in 1 2 3;
    do
        find_subnet_zone         
        create_worker_node
    done
}
