# AMQP (Advanced Message Queuing Protocol)

The _AMQP_ (Advanced Message Queuing Protocol) input plugin allows Fluent Bit to consume messages from an AMQP broker such as RabbitMQ. It connects to the specified broker, consumes messages from a queue, and processes them as log records.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
|:---|:---|:---|
| `uri` | Specify an AMQP URI to connect to the broker | `amqp://` |
| `queue` | Specify an AMQP queue name to consume from | _none_ (required) |
| `parser` | Specify a parser to process the message payload | _none_ |
| `reconnect.retry_limits` | Maximum number of retries to connect to the broker | `5` |
| `reconnect.retry_interval` | Retry interval (in seconds) to connect to the broker | `60` |
| `thread.ring_buffer.capacity` | Set the capacity of the ring buffer | 1024 |
| `thread.ring_buffer.window` | Set the window size of the ring buffer | 5 |

## How it works

The AMQP input plugin connects to an AMQP broker and consumes messages from a specified queue. Each message is processed and converted into a Fluent Bit log record with the following characteristics:

1. The message body becomes the main content of the record
2. AMQP message properties (like content type, routing key, and so on) are added as metadata
3. AMQP message headers are added as a nested metadata field
4. If a parser is specified, it's applied to the message body

### Message Properties Mapping

The following AMQP message properties are mapped to Fluent Bit record metadata:

- `routing_key` - The routing key used to route the message to the queue
- `content_type` - The MIME content type of the message
- `content_encoding` - The content encoding of the message
- `correlation_id` - Application correlation identifier
- `reply_to` - Address to reply to

### Message Headers

AMQP message headers are mapped to a `headers` field in the record metadata as a key-value map.

## Get started

To consume messages from an AMQP broker, you can run the plugin from the command line or through the configuration file.

### Command line

The following command will start Fluent Bit with the AMQP input plugin:

```shell
fluent-bit -i amqp -p queue=my_queue -o stdout
```

### Configuration file

In your main configuration file, append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: amqp
      queue: my_queue
      uri: amqp://guest:guest@localhost:5672/%2F

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  amqp
  Queue my_queue
  URI   amqp://guest:guest@localhost:5672/%2F

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

## Example: Consuming JSON messages

If your AMQP messages contain JSON data, you can use a parser to process them:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
  - name: json
    format: json

pipeline:
  inputs:
    - name: amqp
      queue: json_messages
      parser: json
      uri: amqp://

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  amqp
  Queue json_messages
  Parser json
  URI   amqp://

[PARSER]
  Name   json
  Format json

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

## Connection Management

If a connection is lost during operation or startup, the plugin will automatically attempt to reconnect based on the `reconnect.retry_limits` and `reconnect.retry_interval` properties.

## Requirements

The AMQP input plugin requires the RabbitMQ C client library (rabbitmq-c) to be installed on the system.
