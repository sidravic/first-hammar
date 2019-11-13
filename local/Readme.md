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

Similarly, let's add tags for ELK logging stack

```
docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
vhnz9ywgvr8aov29mk7iskdy3 *   vm1                 Ready               Active              Leader              19.03.4
k8g650b55dn9lhca8o28qfg0f     vm2                 Ready               Active                                  19.03.4
34d4shrb3ihvbmueisio2pnxk     vm3                 Ready               Active                                  19.03.4
➜  databases git:(master) ✗ docker node update --label-add logging=true k8g650b55dn9lhca8o28qfg0f
k8g650b55dn9lhca8o28qfg0f
➜  databases git:(master) ✗ docker node update --label-add stateful=true k8g650b55dn9lhca8o28qfg0f
k8g650b55dn9lhca8o28qfg0f
➜  databases git:(master) ✗ docker node update --label-add elasticsearch=true k8g650b55dn9lhca8o28qfg0f
k8g650b55dn9lhca8o28qfg0f
➜  databases git:(master) ✗ docker node update --label-add kibana=true k8g650b55dn9lhca8o28qfg0f 
k8g650b55dn9lhca8o28qfg0f
➜  databases git:(master) ✗ docker node update --label-add logstash=true k8g650b55dn9lhca8o28qfg0f
k8g650b55dn9lhca8o28qfg0f

```

# Create our Postgres Image (glorious-tower)

We build our image from the default postgres 12.0 image on dockerhub.

1. Our primary postgres image is codenamed `glorious-tower`
2. To build your image run

```
$ cd ./local/postgres
$ docker build -t glorious-tower .
```

Now `docker images glorious-tower` should return 

```
docker images glorious-tower
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
glorious-tower      latest              cefea7c1cb7f        3 minutes ago       369MB
```

Launch the postgres container using the `development.env` file in the folder

```
$ ./start_postgres.sh
```

This creates 
1. a super user with value specified in the `$POSTGRES_USER` environment variable
2. a database with the value specified in `$POSTGRES_DB`

An additional set of users with password, permissions and database is created using the 
`init-user-db.sh` file loaded on boot using the `/docker-entrypoint-initdb.d/init-user-db.sh`
configurations executed. This is described in more detail here https://hub.docker.com/_/postgres?tab=description


# Creating our Redis image

Our redis image is based off the `redis:5.0` base image

We add a custom configuration file to the `/etc/redis/redis.conf`. Our conf file ensures that `AOF` persistence is enabled so that it behaves as much as a persistent store as it possibly can.

```
$ cd ./local/redis
$ docker build -t ephemeral-tower .
```

The `docker images ephemeral-tower` should return

```
➜  redis git:(master) ✗ docker images ephemeral-tower   
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ephemeral-tower     latest              ca3fab28f2c5        3 days ago          98.3MB
```

We can run the container by using the shell script in the same folder

```
$ ./start_redis.sh
```

# Deploying Stacks

Before deploying stacks ensure that we have container images up on gitlab registry.

The primary images needed for all stacks to be running are 

1. Elasticsearch (No local modified copy is used. We use the source image provided by elasticsearch)
2. Kibana. (No local modified copy is used. We use the source image provided by elastic)
3. Logstash. (Local copy is used. )


To create `logstash` 
```
(first-hammar) $ cd local/logstash 
(first-hammar) $ ./build.sh
```
This creates a tagged image and pushes it to registy.gitlab.com/first-hammar
The images are tagger in the following format `first-hammar:<application-name>-<timestamp>`

Gitlab does not allow multiple namespaces under the same project for the time being.


4. Postgres

```
(first-hammar) $ cd local/postgres 
(first-hammar) $ ./build.sh
```

5. Redis

```
(first-hammar) $ cd local/redis 
(first-hammar) $ ./build.sh
```

6. Finally the application images

### Holding volumes for stateful services

7. We use `vm3` described earlier as our stateful containers machine. This node needs to be able
have the mountable volumes described in the `docker-compose.yml` file.

For example in the `docker-compose.yml` file for postgres and redis

```yml
version: '3'

services:
  glorious-tower-postgres:
    image: registry.gitlab.com/goglance/first-hammar:postgres-1572596571
    env_file:
      - development.env
    volumes:
      - /postgres-data:/var/lib/postgresql/data
    ports:
      - 5433:5432
    networks:
      - development-db-network
      - dev-global-network
    deploy:
      placement:
        constraints:
          - node.labels.postgres == true
  
  ephemeral-tower-redis:
    image: registry.gitlab.com/goglance/first-hammar:redis-1572596611
    env_file: 
      - development.env
    volumes:
      - /redis-data:/data  
    ports:
      - 6380:6379
    networks:
      - development-db-network
      - dev-global-network
    command: redis-server /etc/redis/redis.conf
    deploy:
      placement:
        constraints:
          - node.labels.redis == true


networks:
  development-db-network:

  dev-global-network:
    external: true
```

We use to mounted volumes called `/redis-data` and `/postgres-data`
These folders need to accessible in every node that is tagged with labels `redis=true` and `postgres=true`

So for now we manually log on to `vm3` and create these folders. For production systems we could use a standard `AMI` or a bootstrap script to achieve this.

Creating these folders as below

```
$ docker-machine ssh vm3

docker@vm3:~$
docker@vm3:~$ sudo su
root@vm3:~$ cd /
root@vm3:~$ mkdir -p /redis-data /postgres-data
root@vm3:~$ chmod docker:staff /redis-data
root@vm3:~$ chmod docker:staff /postgres-data
```

We now have the folders on `vm3`

### Bridge networks for Swarm Scope

We need to ensure that our stacks can communicate with each other. Our `docker-compose.yml` includes 2 networks

```
networks:
  development-db-network:

  dev-global-network:
    external: true
```

1. The `develpment-db-network` which is bridge network in the local scope created even when we run the `docker-compose up` outside swarm mode.


2. The `dev-global-network` which is an external network which is a `bridge` network created for the swarm for our stacks to speak to each other.

The `dev-global-network` needs to exists before we deploy our stack. This needs to be run manually on the `master` node. `vm1` in our case.

So we go ahead and create that by accessing the manager node

```
(first-hammar) $ eval $(docker-machine env vm1)
docker network create dev-global-network --scope swarm
```

Now we should see the networks and their scopes

```
(first-hammar) $ docker network ls
NETWORK ID          NAME                                    DRIVER              SCOPE
c3867f2f83f0        bridge                                  bridge              local
n80md3pnd4mr        dev-global-network                      bridge              swarm
c1a67bef5e66        docker_gwbridge                         bridge              local
27b5ca6e803c        host                                    host                local
s5xvxu1r0zbs        ingress                                 overlay             swarm
a1368031f913        none                                    null                local
9uokg5b8zbhv        postgres_redis_development-db-network   overlay             swarm

```

Almost there. 

### Authenticating from private registries and deploying our stack.

`registry.gitlab.com` is a private registry and the nodes need to be able to pull the images from there. For this we need to ensure that the manager node has accessing

The `docker-compose stack deploy` provides an attribute called `--with-registry-auth` which forwards the registry authentication to the manager/coordinator node.


```
(first-hammar) $ cd local/stacks/databases
(databases) $ docker stack deploy -c docker-compose.yml --with-registry-auth postgres_redis

Creating network postgres_redis_development-db-network
Creating service postgres_redis_ephemeral-tower-redis
Creating service postgres_redis_glorious-tower-postgres
```

That's it. Praise Be!

### Validating our containers are up and running

1. Check our stack exists.

```
$ (databases) docker stack ls  
NAME                SERVICES            ORCHESTRATOR
postgres_redis      2                   Swarm

```

2. Check the services in the stacks are running

```
$ (database) docker stack services postgres_redis
ID                  NAME                                     MODE                REPLICAS            IMAGE                                                           PORTS
8v1hdvnrponc        postgres_redis_glorious-tower-postgres   replicated          1/1                 registry.gitlab.com/goglance/first-hammar:postgres-1572596571   *:5433->5432/tcp
ucqxc69y5niv        postgres_redis_ephemeral-tower-redis     replicated          1/1                 registry.gitlab.com/goglance/first-hammar:redis-1572596611      *:6380->6379/tcp

```

3. Check each service in detail

```
$ (database) docker service ps postgres_redis_ephemeral-tower-redis
ID                  NAME                                     IMAGE                                                        NODE                DESIRED STATE       CURRENT STATE               ERROR               PORTS
tail3n20q6n7        postgres_redis_ephemeral-tower-redis.1   registry.gitlab.com/goglance/first-hammar:redis-1572596611   vm3                 Running             Running about an hour ago                       

```

4. Check service logstash

```
$ (database) docker service logs postgres_redis_ephemeral-tower-redis.1

postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:C 01 Nov 2019 08:33:18.462 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:C 01 Nov 2019 08:33:18.463 # Redis version=5.0.6, bits=64, commit=00000000, modified=0, pid=1, just started
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:C 01 Nov 2019 08:33:18.463 # Configuration loaded
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |                 _._                                                  
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |            _.-``__ ''-._                                             
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |       _.-``    `.  `_.  ''-._           Redis 5.0.6 (00000000/0) 64 bit
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |   .-`` .-```.  ```\/    _.,_ ''-._                                   
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  (    '      ,       .-`  | `,    )     Running in standalone mode
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  |    `-._   `._    /     _.-'    |     PID: 1
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |   `-._    `-._  `-./  _.-'    _.-'                                   
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  |`-._`-._    `-.__.-'    _.-'_.-'|                                  
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  |    `-._`-._        _.-'_.-'    |           http://redis.io        
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |   `-._    `-._`-.__.-'_.-'    _.-'                                   
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  |`-._`-._    `-.__.-'    _.-'_.-'|                                  
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |  |    `-._`-._        _.-'_.-'    |                                  
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |   `-._    `-._`-.__.-'_.-'    _.-'                                   
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |       `-._    `-.__.-'    _.-'                                       
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |           `-._        _.-'                                           
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    |               `-.__.-'                                               
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:M 01 Nov 2019 08:33:18.466 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:M 01 Nov 2019 08:33:18.466 # Server initialized
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:M 01 Nov 2019 08:33:18.466 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
postgres_redis_ephemeral-tower-redis.1.tail3n20q6n7@vm3    | 1:M 01 Nov 2019 08:33:18.466 * Ready to accept connections

```

Great! We see some VM specific configuration issues but they can be resolved on the node level. 


# Removing a node and destroyin the container

Assuming we want to resize the vm2 from the default 1026 mb to a 3078 mb machine.

1. Exit the swarm
2. Remove the node
3. Delete the vm1


```
# Logging into vm2
$ docker-machine ssh vm2

docker@vm2:~$ docker swarm leave                             
Node left the swarm.

$ exit 
```

We've now left the swarm

We delete the node from the master node
```
$ eval $(docker-machine env vm1)

$ docker node rm vm2
$ docker node ls                          
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
vhnz9ywgvr8aov29mk7iskdy3 *   vm1                 Ready               Active              Leader              19.03.4
34d4shrb3ihvbmueisio2pnxk     vm3                 Ready               Active                                  19.03.4
```

Now we see only two nodes

We now delete the virtual machine

```
$ docker-machine rm vm2
WARNING: This action will delete both local reference and remote instance.
Are you sure? (y/n): y
Successfully removed vm2
```

Now we create a new resized vm with the additional memory

```
$  docker-machine create --driver virtualbox --virtualbox-memory 3072 vm2
Running pre-create checks...
Creating machine...
(vm2) Copying /home/sidravic/.docker/machine/cache/boot2docker.iso to /home/sidravic/.docker/machine/machines/vm2/boot2docker.iso...
(vm2) Creating VirtualBox VM...
(vm2) Creating SSH key...
(vm2) Starting the VM...
(vm2) Check network to re-create if needed...
(vm2) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env vm2

````


# Installing Rexraxy

URL for curl script to be run on docker-machine vm1

```
$ curl -sSL https://rexray.io/install | sh -s -- stable 0.11.1

generating self-signed certificate...
  /etc/rexray/tls/rexray.crt
  /etc/rexray/tls/rexray.key

rexray has been installed to /usr/bin/rexray

REX-Ray
-------
Binary: /usr/bin/rexray
Flavor: client+agent+controller
SemVer: 0.11.1
OsArch: Linux-x86_64
Commit: 1608180686ac4426b04941b4002fb33b9efd972e
Formed: Tue, 19 Dec 2017 22:26:34 UTC


```

### To install random libraries like `vim` `nmap` or `tcpdump` use 

```
sudo su - docker -c 'tce-load -wi vim.tcz &' 
```

### Solution for Rexray having trouble creating the necessary volumes and IDs

From https://github.com/rexray/rexray/issues/255
```
$ wget http://tinycorelinux.net/6.x/x86_64/tcz/udev-extra.tcz
$ sudo tce-load -i udev-extra.tcz
$ sudo udevadm trigger

```

While running it from jumpbox or host machine

```
➜  first-hammar git:(master) ✗ docker-machine scp local/rexray/rexray-volume-error.sh vm3:/tmp/volume.sh
rexray-volume-error.sh                                                   100%  105   282.3KB/s   00:00    
➜  first-hammar git:(master) ✗ docker-machine scp local/rexray/rexray-volume-error.sh vm2:/tmp/volume.sh
rexray-volume-error.sh                                                   100%  105   228.6KB/s   00:00    
➜  first-hammar git:(master) ✗ docker-machine scp local/rexray/rexray-volume-error.sh vm1:/tmp/volume.sh
rexray-volume-error.sh                                                   100%  105   266.6KB/s   00:00 
```

Then execute it by

```
docker-machine ssh vm1 "./tmp/volume.sh"
docker-machine ssh vm2 "./tmp/volume.sh"
docker-machine ssh vm3 "./tmp/volume.sh"
docker-machine ssh vm4 "./tmp/volume.sh"
```
### Copy the rexray configuration files onto each machine

1. Create a `config.yml` file locally

```

```
### Login to each machine and launch rexray

```
rexray:
  loglevel: warn
  storageDrivers:
    - virtualbox
  volumeDrivers:
    - docker

  docker:
    size: 1

libstorage:
  service: virtualbox
  integration:
    volume:
      operations:
        mount:
          preempt: true

virtualbox:
  endpoint: http://10.0.0.6:18083
  volumePath: "/home/sidravic/VirtualBox VMs"
  controllerName: SATA
  tls: false
```

The libstorage configuration points to the machine where the virtual box web service is running. We need to launch this using
on your local machine with 

```
When using the VirtualBox SOAP API service for the first time, disable authentication:

$ VBoxManage setproperty websrvauthlibrary null

Start the VirtualBox SOAP API to accept API requests from the REX-Ray service in a new terminal window:

$ vboxwebsrv -H 0.0.0.0 -v
```

Now rexray running on each node can communicate with this web service to access the volume information.

### Start Rexray

Note: Rexray service seems to exist when not launched from the node itself so login and run it as a background process. 
```
$ docker-machine ssh vm1 
docker@vm1 $ sudo rexray start -c /etc/rexray/config.xml &

... watch the logs scroll Binary
docker@vm1 $ sudo rexray STATUS
rexray is running on PID 5974

```


### Create Volumes that can be attached onto each service

```
$ rexray volume create postgres_redis_postgres-data --attachable --size=13 -c /etc/rexray/config.xml
9ecaddb2-c922-4d44-9b6a-ae896211d91c

$ rexray volume ls -c 

ID                                    Name                          Status       Size
fe2922c3-2c2c-4eef-a63d-c255481fb05d  disk.vmdk                     attached     19
b1224e55-def2-483b-953d-02329b2096a9  disk.vmdk                     unavailable  19
ca7b00e0-58c3-409e-9837-cc37bc74cc94  disk.vmdk                     unavailable  19
d7c12bcf-5b8b-4095-9842-3df850c1eb7d  disk.vmdk                     unavailable  19
d151f7a3-769d-4a84-9dc3-161faa46362a  logging_elastic-data          unavailable  16
b110bacf-4d86-40c6-9830-7ea446f51282  postgres_redis-postgres-data  attached     16
9ecaddb2-c922-4d44-9b6a-ae896211d91c  postgres_redis-redis-data     attached     2
b7f336e3-dff4-4d20-bbd1-34a1b5588d99  postgres_redis_postgres-data  unavailable  16
f8031b6d-069a-423c-a22f-6b37c49d5d38  postgres_redis_redis-data     unavailable  16

```

This creates an unattached, available volume ready for use. This can be explicitly using the `attach` command or implicitly attached using the `docker-compose.yml` file using the `external` attribute

Our docker-compose.yml file now looks like this while referencing the volumes 


```
version: '3.2'

services:
  glorious-tower-postgres:
    image: registry.gitlab.com/goglance/first-hammar:postgres-1572939467
    env_file:
      - development.env
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - 5433:5432
    networks:      
      - core-infra 
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 10
        window: 180s
      placement:
        constraints:
          - node.labels.postgres == true
  
  ephemeral-tower-redis:
    image: registry.gitlab.com/goglance/first-hammar:redis-1572596611
    env_file: 
      - development.env
    volumes:
      - redis-data:/data  
    ports:
      - 6380:6379
    networks:
      - core-infra
    command: redis-server /etc/redis/redis.conf
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 10
        window: 180s      
      placement:
        constraints:
          - node.labels.redis == true


volumes:
  postgres-data:            
    driver: rexray 
  redis-data:
    driver: rexray 
      

networks:
  core-infra:
    external: true  

```

These volumes no reflect in the folder referenced in each `/etc/rexray/config.yml` file under the `libstorage.VolumePath`. It also reflects under each node where the volumes are stored under

```
/var/lib/rexray/volumes

total 8
drwxr-xr-x    4 root     root            80 Nov  6 11:21 .
drwxr-xr-x    4 root     root            80 Nov  4 23:08 ..
drwxr-xr-x    4 root     root          4096 Nov  4 23:08 postgres_redis_postgres-data
drwxr-xr-x    4 root     root          4096 Nov  4 23:08 postgres_redis_redis-data

```

## Ensuring that all the containers in the Swarm can speak with each others

We use an `attachable` overlay network that runs across the entire infrastructure.

We create that using

```
 docker network create --driver overlay --attachable=true core-infra  
```

Now we use this network as the primary network in each of our `docker-compose.yml` files as an external network.

For example

```
version: '3.2'

services:
  glorious-tower-postgres:
    image: registry.gitlab.com/goglance/first-hammar:postgres-1572939467
    env_file:
      - development.env
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - 5433:5432
    networks:      
      - core-infra 
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 10
        window: 180s
      placement:
        constraints:
          - node.labels.postgres == true
  
  ephemeral-tower-redis:
    image: registry.gitlab.com/goglance/first-hammar:redis-1572596611
    env_file: 
      - development.env
    volumes:
      - redis-data:/data  
    ports:
      - 6380:6379
    networks:
      - core-infra
    command: redis-server /etc/redis/redis.conf
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 10
        window: 180s      
      placement:
        constraints:
          - node.labels.redis == true


volumes:
  postgres-data:            
    driver: rexray 
  redis-data:
    driver: rexray 
      

networks:
  core-infra:
    external: true  

```

# Staging deployment of elasticsearch and redis

Increase `somaxconn` at `/etc/sysctl.conf`

```
vm.max_map_count=262144
fs.file-max = 65535
```

At `/etc/security/limits.conf`

```
root soft     nproc          65535    
root hard     nproc          65535   
root soft     nofile         65535   
root hard     nofile         65535
```

### Addition component in the docker-compose file as long as you're running docker > v19.0.4

For redis
```
...
      ports:
        - 6380:6379
      networks:
        - core-infra
      sysctls:
        net.core.somaxconn: 65535    
...
```

For elasticsearch

```
...
    ports:
      - 9200:9200
      - 9300:9300
    networks:
      - core-infra
    sysctls:
        net.core.somaxconn: 65535  
        vm.max_map_count: 262144
    ulimits:
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
    deploy:
  ...

```



