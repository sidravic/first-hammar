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

./install-rexray.sh 
/bin/bash -c docker-machine ssh vm1  'docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=AKIA6FLNIRSTUU2FY2CO EBS_SECRETKEY=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 --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true' 
latest: Pulling from rexray/ebs
713b84867e46: Verifying Checksum
713b84867e46: Download complete
Digest: sha256:bbe1cfc5241d765c735e1d80fd790a0fc50e2e7064239255c4b61397a16c3355
Status: Downloaded newer image for rexray/ebs:latest
Installed plugin rexray/ebs:latest
/bin/bash -c docker-machine ssh vm2  'docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=AKIA6FLNIRSTUU2FY2CO EBS_SECRETKEY=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 --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true' 
latest: Pulling from rexray/ebs
713b84867e46: Verifying Checksum
713b84867e46: Download complete
Digest: sha256:bbe1cfc5241d765c735e1d80fd790a0fc50e2e7064239255c4b61397a16c3355
Status: Downloaded newer image for rexray/ebs:latest
Installed plugin rexray/ebs:latest
/bin/bash -c docker-machine ssh vm3  'docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=AKIA6FLNIRSTUU2FY2CO EBS_SECRETKEY=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 --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true' 
latest: Pulling from rexray/ebs
713b84867e46: Verifying Checksum
713b84867e46: Download complete
Digest: sha256:bbe1cfc5241d765c735e1d80fd790a0fc50e2e7064239255c4b61397a16c3355
Status: Downloaded newer image for rexray/ebs:latest
Installed plugin rexray/ebs:latest

```

This runs the following command

```
DOCKER_COMMAND="docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=$AWS_ACCESS_KEY_ID EBS_SECRETKEY=$AWS_SECRET_ACCESS_KEY --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true"
docker-machine ls | cut -c 1-4 | grep vm* | xargs -t -I"SERVER" /bin/bash -c "docker-machine ssh SERVER '${DOCKER_COMMAND}'"
```

Xargs examples: https://shapeshed.com/unix-xargs/

1. It stores the command to be run in the `DOCKER_COMMAND` variable
2. It then runs the `docker-machine ls` command which returns the entire list of vms
3. It `cut`s the characters from 1-4 which describe the hostname (vm1, vm2 etc)
4. We grep so that we don't end up with the title row (NAME)
5. We the send it to `xargs` which stores each output to the -I variable `SERVER` in this case and call the bash command via `/bin/bash -c` which sshs into each node and runs the command

### Verify if plugins are successfully installed

We use the `run-cmd.sh` script which runs commands on all vms

```
(aws first-hammer/staging/aws/) ./run-cmd 'docker plugin ls'

/bin/bash -c docker-machine ssh vm1  'docker plugin ls' 
ID                  NAME                DESCRIPTION              ENABLED
bf76c5ce7307        rexray/ebs:latest   REX-Ray for Amazon EBS   true
/bin/bash -c docker-machine ssh vm2  'docker plugin ls' 
ID                  NAME                DESCRIPTION              ENABLED
4137b4fe4308        rexray/ebs:latest   REX-Ray for Amazon EBS   true
/bin/bash -c docker-machine ssh vm3  'docker plugin ls' 
ID                  NAME                DESCRIPTION              ENABLED
832de09c0765        rexray/ebs:latest   REX-Ray for Amazon EBS   true

```
