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
(aws) $ ./create-swarm.sh create
```

### 2. Create jumpbox and security groups. Attach jumbox to swarm security group for full port access

```
(aws) $ ./create-jumpbox.sh create
```

### 7. Install Rexray managed plugin for docker on the jumpbox and all swarm nodes

```
ssh ubuntu@jumpbox_ip

(jumpbox) $ docker plugin install rexray/ebs:latest REXRAY_PREEMPT=true EBS_REGION=us-west-1 EBS_ACCESSKEY=aws_key EBS_SECRETKEY=aws_secret --grant-all-permissions EBS_ENDPOINT=ec2.us-west-1.amazonaws.com EBS_USELARGEDEVICERANGE=true

```