# Kibana stack

1. The stack uses the official elastic image for kibana available here to run Kibana 7.4.1. The image is available here https://hub.docker.com/_/kibana
2. It specifies the configurations needed for `kibana.yml` stored in the Centos image via a volume mounted configurations file present in the `kibana` folder.

The sample `kibana.yml` is listed here

```
server.port: 5601
server.host: "0.0.0.0"
server.name: "logs-home"
kibana.index: ".kibana-test"
elasticsearch.hosts:
  - http://es01:9200
```

3. It passes the `elasticsearch.hosts` parameter explicitly here.



