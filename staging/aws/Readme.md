# Creating the stack

Creating the stack requires the following steps

1. Create the swarm security groups (swarm-security-group)
2. Create the jumpbox security groups (jumpbox-security-group)
3. Create jumpbox
4. Log in to the jumpbox
5. Create swarm managers and workers. 
6. Connect them to the swarm
7. Install Rexray plugins


### 1. Create the swarm security group

```
(aws first-hammar/staging/aws) $ ./create-swarm-sg.sh create
```

### 2. Create jumpbox and security groups. Attach jumbox to swarm security group for full port access

```
(aws first-hammar/staging/aws) $ ./create-jumpbox.sh create
```

### 3 Create Swarm
```
(aws first-hammar/staging/aws) $ ./create-swarm-manager.sh
```

### 7. Install Rexray managed plugin for docker on the jumpbox and all swarm nodes

```
ssh ubuntu@jumpbox_ip

(jumpbox) $ docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=aws_key EBS_SECRETKEY=aws_secret --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true

```

This ensures that rexray is installed and running. However we need to install rexray on all docker swarm nodes (workers and manager). For this we use the `install-rexray.sh` script which executes the command on all nodes

The command that we run on all nodes is this.

```
$ docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=aws_key EBS_SECRETKEY=aws_secret --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true
```

However we use a script that can be executed from the jumpbox to install it rather than doing this manually

```
(aws first-hammar/staging/aws) ./install-rexray.sh
```

This runs the following command

```
DOCKER_COMMAND="docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=$AWS_ACCESS_KEY_ID EBS_SECRETKEY=$AWS_SECRET_ACCESS_KEY --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true"
docker-machine ls | cut -c 1-4 | grep vm* | xargs -t -I"SERVER" /bin/bash -c "docker-machine ssh SERVER '${DOCKER_COMMAND}'"
```

1. It stores the command to be run in the `DOCKER_COMMAND` variable
2. It then runs the `docker-machine ls` command which returns the entire list of vms
3. It `cut`s the characters from 1-4 which describe the hostname (vm1, vm2 etc)
4. We grep so that we don't end up with the title row (NAME)
5. We the send it to `xargs` which stores each output to the -I variable `SERVER` in this case and call the bash command via `/bin/bash -c` which sshs into each node and runs the command
