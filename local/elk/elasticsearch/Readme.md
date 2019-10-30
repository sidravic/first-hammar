# ElasticSearch stack

1. The stack uses the official elastic image for elasticsearch available here to run Elasticsearch 7.4.1. The image is available here https://hub.docker.com/_/elasticsearch
2. It specifies the configurations needed for `elasticsearch.yml` stored in the Centos image via the `development.env` file present in the parent folder `elk`

The sample `development.env` is listed here

```
node.name=es01
discovery.seed_hosts=es01
cluster.initial_master_nodes=es01
cluster.name=elastic-logs-cluster
bootstrap.memory_lock=true
"ES_JAVA_OPTS=-Xms1g -Xmx1g"
```

3. Remember to set the `Xms` and `Xmx` arguments to 50% of the available. Refer to this document for more details https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

