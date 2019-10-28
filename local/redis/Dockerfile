FROM redis:5.0

WORKDIR /data
ENV DATA_DIR /data

COPY redis.conf /etc/redis/redis.conf

CMD ['redis-server', '/etc/redis/redis.conf']