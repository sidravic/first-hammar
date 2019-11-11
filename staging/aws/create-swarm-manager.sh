#!/bin/bash


source ./security-groups.sh

function create_manager_nodes(){
    docker-machine create --driver amazonec2 \
                          --amazonec2-region $DEFAULT_REGION \
                          --amazonec2-ami $DEFAULT_AMI_ID \
                          --amazonec2-instance-type t2.small \
                          --amazonec2-keypair-name $DEFAULT_KEY_NAME \
                          --amazonec2-monitoring \
                          --amazonec2-root-size 30 \
                          --amazonec2-security-group $swarm_security_group_id \
                          --amazonec2-tags swarm_manager,true,environment,staging
                          --amazonec2-volume-type gp2
                          --amazonec2-vpc-id $DEFAULT_VPC_ID "$node_name"


}


function create_3_manager_nodes(){
    echo "Getting security group for swarm"
    swarm_security_group_id=get_swarm_security_group_id
    
    for i in 1 2 3;
    do 
        node_name="vm${i}"
        echo "Creating swarm manager nodes $node_name"
        create_manager_nodes
    done
}
