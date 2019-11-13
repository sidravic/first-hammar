FROM redis:5.0

WORKDIR /data
ENV DATA_DIR /data

COPY redis.conf /etc/redis/redis.conf

RUN /bin/bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
RUN /bin/bash -c 'echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf'
RUN /bin/bash -c 'echo "net.core.somaxconn=65535" >> /etc/systcl.conf && sysctl -p'


#CMD ['redis-server', '/etc/redis/redis.conf']