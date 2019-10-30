FROM docker.elastic.co/logstash/logstash:7.4.1

RUN rm -f /usr/share/logstash/pipeline/logstash.conf

ADD pipeline/ /usr/share/logstash/pipeline/

ADD config/ /usr/share/logstash/config/

ENV UDP_PIPELINE_INPUT_HOST '0.0.0.0'
ENV UDP_PIPELINE_INPUT_PORT '5228'
ENV ELASTICSEARCH_HOST 'es01'

EXPOSE 9600
EXPOSE 5228/udp