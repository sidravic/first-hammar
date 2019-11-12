# Creating the stack

Creating the stack requires the following steps

1. Create the swarm security groups (swarm-security-group)
2. Create jumpbox and security groups. Attach jumbox to swarm security group for full port access (jumpbox-security-group)
3. Create Swarm Manager nodes
5. Create swarm workers. 
6. Connect them to the swarm - This needs to be done manually at this point.
7. Install Rexray plugins
8. Great an global infra network


### 1. Create the swarm security group

```
(aws first-hammar/staging/aws) $ ./create-swarm-sg.sh create
```

### 2. Create jumpbox and security groups. Attach jumbox to swarm security group for full port access

```
(aws first-hammar/staging/aws) $ ./create-jumpbox.sh create
```

### 3 Create Swarm Security groups

```
(aws first-hammar/staging/aws) $ ./create-swarm-sg.sh create
```

### 4 Create Swarm Manager Nodes
```
(aws first-hammar/staging/aws) $ ./create-swarm-manager.sh
```

### 5 Create Swarm Manager Nodes

```
(aws first-hammar/staging/aws) $ ./create-swarm-worker.sh
```

### 6 Connect them to the swarm

```
(aws first-hammar/staging/aws) $ docker-machine ssh vm1
(aws first-hammar/staging/aws) $ docker swarm init 
(aws first-hammar/staging/aws) $ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-34elumx2nrs3b23jhlgkypr802pbwf9hw64f5cjyxsv1t30swb-5n2m5xsjv9lquskqyh1hcg8ok 172.31.4.120:2377

(aws first-hammar/staging/aws) $ docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-34elumx2nrs3b23jhlgkypr802pbwf9hw64f5cjyxsv1t30swb-8ldumao8dl45g1xc0mtb0pqjb 172.31.4.120:2377

```

Copy the token for the manager and paste it on each node by running `docker-machine ssh vm2` and `docker-machine ssh vm3`

Copy the token for the worker and paste it on `vm4`, `vm5` and `vm6`

Now `docker node ls` should display the swarm

```
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
5jla1ietv6rgmwf92rh7sdjrm *   vm1                 Ready               Active              Leader              19.03.4
b0741t0ma45nnvohqd61u5rt0     vm2                 Ready               Active              Reachable           19.03.4
zl1zw5u2ad0j8g4hyuezssw7f     vm3                 Ready               Active              Reachable           19.03.4
dzcntqh5faj705qyuq2d91d96     vm4                 Ready               Active                                  19.03.4
x2p6hyv3xpjd8o0c3isr75dba     vm5                 Ready               Active                                  19.03.4
tycin6q69vzx6oq6wvqua3p02     vm6                 Ready               Active                                  19.03.4
```

Praise Be!

### 6. Ensure Docker does not require sudo

```
(aws first-hammar/staging/aws) ./run-cmd.sh 'sudo usermod -aG docker ubuntu'

/bin/bash -c docker-machine ssh vm1  'sudo usermod -aG docker ubuntu' 
/bin/bash -c docker-machine ssh vm2  'sudo usermod -aG docker ubuntu' 
/bin/bash -c docker-machine ssh vm3  'sudo usermod -aG docker ubuntu' 
/bin/bash -c docker-machine ssh vm4  'sudo usermod -aG docker ubuntu' 
/bin/bash -c docker-machine ssh vm5  'sudo usermod -aG docker ubuntu' 
/bin/bash -c docker-machine ssh vm6  'sudo usermod -aG docker ubuntu' 
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
