FROM redis:5.0

WORKDIR /data
ENV DATA_DIR /data

COPY redis.conf /etc/redis/redis.conf

# RUN /bin/bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
# RUN /bin/bash -c 'echo "1" > /proc/sys/vm/overcommit_memory'
# RUN /bin/bash -c 'echo "net.core.somaxconn=65535" >> /proc/sys/net/core/somaxconn'


#CMD ['redis-server', '/etc/redis/redis.conf']