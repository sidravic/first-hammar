#!/usr/bin/env bash
function login_ecs(){
    echo "Logging to Gitlab"
    docker login -u $GITLAB_USERNAME -p $GITLAB_PERSONAL_ACCESS_TOKEN $GITLAB_REGISTRY

    if [ $? -eq 0 ]
    then
        echo "Successfully logged into Gitlab"
    else
        echo "Login failed"
        exit 1
    fi
}

login_ecs