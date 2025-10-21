# Run a logging pipeline locally

You can test logging pipelines locally to observe how they handles log messages. This guide explains how to use [Docker Compose](https://docs.docker.com/compose/) to run Fluent Bit and Elasticsearch locally, but you can use the same principles to test other plugins.

## Create a configuration file

Start by creating one of the corresponding Fluent Bit configuration files to start testing.


{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"top": {".dotted": "value"}}'
      
  outputs:       
    - name: es
      host: elasticsearch
      replace_dots: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Dummy {"top": {".dotted": "value"}}

[OUTPUT]
  Name es
  Host elasticsearch
  Replace_Dots On
```

{% endtab %}
{% endtabs %}

## Use Docker Compose

Use [Docker Compose](https://docs.docker.com/compose/) to run Fluent Bit (with the configuration file mounted) and Elasticsearch.

{% code title="docker-compose.yaml" %}

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
    image: elasticsearch:7.17.6
    ports:
      - "9200:9200"
    environment:
      - discovery.type=single-node
```

{% endcode %}

## View indexed logs

To view indexed logs, run the following command:

```shell
curl "localhost:9200/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d'{ "query": { "match_all": {} }}'
```

## Reset index

To reset your index, run the following command:

```shell
curl -X DELETE "localhost:9200/fluent-bit?pretty"
```