#!/bin/bash

source ./security-groups.sh



if [ $1 == "create" ]; then
    create_swarm_sg
    list_security_groups
    export SWARM_SECURITY_GROUP_ID=swarm_security_group_id
    echo $SWARM_SECURITY_GROUP_ID
elif [ $1 == "delete" ]; then    
    destroy_swarm_sg
fi