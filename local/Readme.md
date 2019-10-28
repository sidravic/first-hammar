# Create VMs

### 1. In the local environment create 3 vms by executing the `create-swarm.sh`


### 2. Run `docker-machine ls`

```
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER     ERRORS
vm1    -        virtualbox   Running   tcp://192.168.99.102:2376           v19.03.4   
vm2    -        virtualbox   Running   tcp://192.168.99.103:2376           v19.03.4   
vm3    -        virtualbox   Running   tcp://192.168.99.104:2376           v19.03.4   
```

This lists the 3 vms we just created.


### 3. Log on to node 1 `(vm1)` and initialize the swarm as a manager node

```
local git:(master) ✗ docker-machine ssh vm1  
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net


```

Now we initialize the node as a swarm manager

```
docker@vm1:~$ docker swarm init --advertise-addr 192.168.99.102                                                                                         
Swarm initialized: current node (y9l9zt0324qc5n6r1oln44cuf) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-2zb853fxwchy2ctlpcwz8h0vvq2kj960ev3yg73ayn3lrwpoxe-calnvdykwvmnm6j5nnedlrq7u 192.168.99.102:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```


### 4. Now create the worker nodes for the swarm

```
➜  local git:(master) ✗ docker-machine ssh vm2
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

docker@vm2:~$ docker swarm join --token SWMTKN-1-2zb853fxwchy2ctlpcwz8h0vvq2kj960ev3yg73ayn3lrwpoxe-calnvdykwvmnm6j5nnedlrq7u 192.168.99.102:2377
This node joined a swarm as a worker.
docker@vm2:~$ exit                                                                                                                                      
logout
➜  local git:(master) ✗ docker-machine ssh vm3
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

docker@vm3:~$ docker swarm join --token SWMTKN-1-2zb853fxwchy2ctlpcwz8h0vvq2kj960ev3yg73ayn3lrwpoxe-calnvdykwvmnm6j5nnedlrq7u 192.168.99.102:2377
This node joined a swarm as a worker.
```


### 5. List your nodes and verify if all is good

Access the swarm manager configuration

```
swarm-setup git:(master) ✗ docker-machine env vm1 
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.102:2376"
export DOCKER_CERT_PATH="/home/sidravic/.docker/machine/machines/vm1"
export DOCKER_MACHINE_NAME="vm1"
# Run this command to configure your shell: 
# eval $(docker-machine env vm1)
```

Connect to the swarm manager by running 

```
$ eval $(docker-machine env vm1)
```

Now you're connected to the `vm1` which is our dev swarm manager

```
swarm-setup git:(master) ✗ docker node ls         
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
vhnz9ywgvr8aov29mk7iskdy3 *   vm1                 Ready               Active              Leader              19.03.4
k8g650b55dn9lhca8o28qfg0f     vm2                 Ready               Active                                  19.03.4
34d4shrb3ihvbmueisio2pnxk     vm3                 Ready               Active                                  19.03.4

```

### 6. Add Labels to our stateful nodes

From the previous step we know our node IDs. We're going to use vm3 as our stateful node for postgres and redis. 
Let's 3 labels to it. 

1. stateful=true
2. redis=true
3. postgres=true

We do this by running the  following command

```
docker node update --label-add stateful=true 34d4shrb3ihvbmueisio2pnxk
docker node update --label-add postgres=true 34d4shrb3ihvbmueisio2pnxk
docker node update --label-add redis=true 34d4shrb3ihvbmueisio2pnxk
```
