# Kibana stack

1. The stack uses the official elastic image for logstash available here to run Kibana 7.4.1. The image is available here https://hub.docker.com/_/logstash
2. The image used is custom built to integrate certain pipeline configurations for UDP based log publishing.
3. The `Dockerfile` does the following things
   1. It deletes the existing pipeline configuration by deleting the `logstash.conf` file in the `/usr/share/logstash/pipeline/logstash.conf` folder
   
   2. It adds the custom `docker-logstash.conf` file which provides UDP listeners. 
    
   3. It copies the `logstash.yml` and `pipeline.yml` file to the `/usr/share/logstash/config/`

   4. Exposes port `9600` (not mandatory to expose this) and `5228`. 
   5. Ensure port `5228` is exposed as a UDP port with the `-p 5228:5228/udp` or `EXPOSE 5228/udp`.

    The `docker-logstash.conf` file looks as below

```
            input {
                udp {
                    host => "${UDP_PIPELINE_INPUT_HOST}"
                    port => "${UDP_PIPELINE_INPUT_PORT}"  
                    id => "sephora-crawler"      
                    workers => 4
                    codec => json_lines
                }
            }

            output {
                elasticsearch {
                    hosts => ["http://${ELASTICSEARCH_HOST}:9200"]
                    codec => json_lines

                }
                stdout {
                    codec => rubydebug
                }
            }
```
### Input 

This allows logstash to accept inputs on host `0.0.0.0` passed as an env var via the `logstash-development.env` file

The port is passed as an ENV VAR via the `logstash-development.env` file.

It uses the `json_lines` codec.

### Outputs

The accepts the `input` and passes it along to elasticsearch. The host is obtained from the ENV VAR passed via the `logstash-development.env` file.
It also prints out the received UDP messages via `stdout` using the `rubydebug` codec. 


### NOTE
1. While debugging ensure that you begin with only the STDOUT component and comment out the elasticsearch output.
2. Use Tcpdump to check if UDP messages are being forwarded to the port 5228.

Tcpdump example

```
sudo tcpdump -A -vvv -i any port 5228
```

Additional tcpdump reference https://hackertarget.com/tcpdump-examples/



```
server.port: 5601
server.host: "0.0.0.0"
server.name: "logs-home"
kibana.index: ".kibana-test"
elasticsearch.hosts:
  - http://es01:9200
```

1. It passes the `elasticsearch.hosts` parameter explicitly here.



