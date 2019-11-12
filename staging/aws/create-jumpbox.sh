#!/bin/bash
source ./security-groups.sh

function create() {
    echo "Creating instance"

    aws ec2 run-instances --image-id $DEFAULT_AMI_ID \
                          --count 1 \
                          --instance-type t2.small \
                          --key-name $DEFAULT_KEY_NAME \
                          --security-group-ids $jumpbox_security_group_id \
                          --subnet-id $DEFAULT_VPC_SUBNET1_ID \
                          --user-data file://jumpbox-user-data.txt --tag-specifications 'ResourceType=instance,Tags=[{Key=jumpbox,Value=true},{Key=Name,Value=staging-jumpbox,Key=environment,Value=staging}]' \
                          --associate-public-ip-address 

}

function terminate() {
    echo "terminating instance..."
    aws ec2 terminate-instances --instance-ids $jumpbox_instance_id
}

function get_jumpbox_instance_id(){
    jumpbox_instance_id=$(aws ec2 describe-instances --filters 'Name=tag-key,Values=jumpbox' | jq -r '.Reservations | .[] | .Instances | .[] | .InstanceId')
    echo "Instance id: $jumpbox_instance_id"
}


if [ $1 = "create" ]; then    
    create_jump_box_sg
    get_swarm_security_group_id
    allow_jumpbox_to_access_swarm
    get_jumpbox_security_group_id
    create
elif [ $1 = "delete" ]; then
    get_jumpbox_instance_id
    terminate
    sleep 4
    delete_jumpbox_security_group
fi