FROM postgres:12.0

RUN apt-get update 

COPY  init-user-db.sh /docker-entrypoint-initdb.d/init-user-db.sh

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
    
ENV LANG en_US.utf8



