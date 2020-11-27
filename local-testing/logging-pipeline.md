# Running a Logging Pipeline Locally

You may wish to test a logging pipeline locally to observe how it deals with log messages. The following is a walk-through for running Fluent Bit and Elasticsearch locally with [Docker Compose](https://docs.docker.com/compose/) which can serve as an example for testing other plugins locally.

## Create a Configuration File

Refer to the [Configuration File section](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file) to create a configuration to test.

`fluent-bit.conf`:

```text
[INPUT]
  Name dummy
  Dummy {"top": {".dotted": "value"}}

[OUTPUT]
  Name es
  Host elasticsearch
  Replace_Dots On
```

## Docker Compose

Use [Docker Compose](https://docs.docker.com/compose/) to run Fluent Bit \(with the configuration file mounted\) and Elasticsearch.

`docker-compose.yaml`:

```yaml
version: "3.7"

services:
  fluent-bit:
    image: fluent/fluent-bit
    volumes:
      - ./fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf
    depends_on:
      - elasticsearch
  elasticsearch:
    image: elasticsearch:7.6.2
    ports:
      - "9200:9200"
    environment:
      - discovery.type=single-node
```

## View indexed logs

To view indexed logs run:

```bash
curl "localhost:9200/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d'{ "query": { "match_all": {} }}'
```

To "start fresh", delete the index by running:

```bash
curl -X DELETE "localhost:9200/fluent-bit?pretty"
```

