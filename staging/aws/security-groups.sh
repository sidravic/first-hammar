#!/bin/bash
# set -e
# set -u
# set -o pipefail

function create_security_group(){
    echo "aws ec2 create-security-group --group-name $group_name \
                                  --description "$description" \
                                  --vpc-id $vpc_id"


    security_group_id=$(aws ec2 create-security-group --group-name $group_name \
                                  --description "$description" \
                                  --vpc-id $vpc_id | jq -r ".GroupId")      
}

function destroy_security_group(){
    echo "destroying security groups..."
    output=$(aws ec2 delete-security-group --group-id $security_group_id)
}

function open_ssh_for_my_ip(){
    my_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    echo "My ip: ${my_ip} "
    echo "Allowing ssh..."
    aws ec2 authorize-security-group-ingress --group-id $group_id --protocol 'tcp' --port 22 --cidr "${my_ip}/32"
}

function open_ports(){
    echo "Opening ports..."    
    aws ec2 authorize-security-group-ingress --group-id $group_id --protocol $protocol --source-group $source_security_group_id
}

function close_ports(){
    echo "Closing port access..."
    aws ec2 revoke-security-group-ingress --group-id $group_id --source-group $source_security_group_id --protocol $protocol
}

function invoke(){
    operation=$1

    echo $1 $2 $3
    if [ "$operation" = "create" ]; then

        group_name="$2"
        description="$3"
        vpc_id="$4"
       
        create_security_group
    elif [ "$operation" = "delete" ]; then
        security_group_id=$2

        destroy_security_group
    elif [ "$operation" = "open-port" ]; then
        group_id=$2
        protocol=$3
        source_security_group_id=$4

        open_ports
    elif [ "$operation" = "close-port" ]; then
        group_id=$2
        protocol=$3
        source_security_group_id=$4

        close_ports
    elif [ "$operation" = "open-ssh" ]; then
        group_id=$2   
        open_ssh_for_my_ip     
    else 
        echo "Usage: ./security-groups.sh delete sg-0f00b3472f24887f0 "
        echo "Usage: ./security-groups.sh create jumpbox-security-group \"jumpbox security group\" \$DEFAULT_VPC_ID "
        echo "Active security groups "
        aws ec2 describe-security-groups | jq '.SecurityGroups | .[] | "\(.GroupName): \(.GroupId)"'
    fi
}


function create_swarm_sg(){
    echo "Creating security group for swarm..."
    invoke create swarm-security-group "SwarmSecurityGroupForSwarmNodes" $DEFAULT_VPC_ID
    swarm_security_group_id=$security_group_id
    invoke open-port $swarm_security_group_id all $swarm_security_group_id
    invoke open-ssh $swarm_security_group_id
}

function create_jump_box_sg(){
    echo "Creating security group for jumpbox..."
    invoke create jumpbox-security-group "JumpBoxSecurityGroup" $DEFAULT_VPC_ID
    jumpbox_security_group_id=$security_group_id    
    invoke open-ssh $jumpbox_security_group_id
}

function allow_jumpbox_to_access_swarm(){
    echo "Allowing jumpbox access to swarm..."
    invoke open-port $swarm_security_group_id all $jumpbox_security_group_id
}

function list_security_groups(){
    invoke asd
}

function get_swarm_security_group_id(){
    swarm_security_group_id=$(aws ec2 describe-security-groups --group-name swarm-security-group | jq -r '.SecurityGroups | .[] | .GroupId')
}

function get_load_balancer_security_group_id(){
    loadbalancer_security_group_id=$(aws ec2 describe-security-groups --group-name lb-security-group | jq -r '.SecurityGroups | .[] | .GroupId')
}

function get_jumpbox_security_group_id(){
    jumpbox_security_group_id=$(aws ec2 describe-security-groups --group-name jumpbox-security-group | jq -r '.SecurityGroups | .[] | .GroupId')
}

function destroy_swarm_sg(){
    get_swarm_security_group_id
    invoke delete $swarm_security_group_id
}

function delete_jumpbox_security_group(){
    get_jumpbox_security_group_id
    get_swarm_security_group_id
    invoke close-port $swarm_security_group_id all $jumpbox_security_group_id
    invoke delete $jumpbox_security_group_id
}

