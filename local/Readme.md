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


