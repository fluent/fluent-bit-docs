
# HTTP

The _HTTP_ input plugin lets Fluent Bit open an HTTP port that you can then route data to in a dynamic way.

## Configuration parameters

| Key                        | Description                                                                                                                                | Default   |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| `listen`                   | The address to listen on.                                                                                                                  | `0.0.0.0` |
| `port`                     | The port for Fluent Bit to listen on.                                                                                                      | `9880`    |
| `tag_key`                  | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                        | _none_    |
| `buffer_max_size`          | Specify the maximum buffer size in KB to receive a JSON message.                                                                           | `4M`      |
| `buffer_chunk_size`        | This sets the chunk size for incoming JSON messages. These chunks are then stored and managed in the space available by `buffer_max_size`. | `512K`    |
| `successful_response_code` | Allows setting successful response code. Supported values: `200`, `201`, and `204`                                                         | `201`     |
| `success_header`           | Add an HTTP header key/value pair on success. Multiple headers can be set. For example, `X-Custom custom-answer`                           | _none_    |
| `threaded`                 | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                    | `false`   |

### TLS / SSL

HTTP input plugin supports TLS/SSL. For more details about the properties available and general configuration, refer to [Transport Security](../../administration/transport-security.md).

### gzipped content

The HTTP input plugin will accept and automatically handle gzipped content in version 2.2.1 or later if the header `Content-Encoding: gzip` is set on the received data.

## Get started

This plugin supports dynamic tags which let you send data with different tags through the same input. See the following for an example:

[Link to video](https://asciinema.org/a/375571)

### Set a tag

The tag for the HTTP input plugin is set by adding the tag to the end of the request URL. This tag is then used to route the event through the system.

For example, in the following curl message the tag set is `app.log**. **` because the end path is `/app_log`:

```shell
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888
      
  outputs:
    - name: stdout
      match: app.log
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name http
  listen 0.0.0.0
  port 8888

[OUTPUT]
  name stdout
  match app.log
```

{% endtab %}
{% endtabs %}

### Configuration file `http.0` example

If you don't set the tag, `http.0` is automatically used. If you have multiple HTTP inputs then they will follow a pattern of `http.N` where `N` is an integer representing the input.

```shell
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888
```

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888

  outputs:
    - name: stdout
      match: http.0
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name http
  listen 0.0.0.0
  port 8888

[OUTPUT]
  name  stdout
  match  http.0
```

{% endtab %}
{% endtabs %}

#### Set `tag_key`

The `tag_key` configuration option lets you specify the key name that will be used to overwrite a tag. The tag's value will be replaced with the value associated with the specified key. For example, setting `tag_key` to `custom_tag` and the log event contains a JSON field with the key `custom_tag`. Fluent Bit will use the value of that field as the new tag for routing the event through the system.

### Curl request

```shell
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration file `tag_key` example

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888
      tag_key: key1

  outputs:
    - name: stdout
      match: value1
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name http
  listen 0.0.0.0
  port 8888
  tag_key key1

[OUTPUT]
  name stdout
  match value1
```

{% endtab %}
{% endtabs %}

#### Set multiple custom HTTP headers on success

The `success_header` parameter lets you set multiple HTTP headers on success. The format is:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      success_header: 
        - X-Custom custom-answer
        - X-Another another-answer
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name http
  success_header X-Custom custom-answer
  success_header X-Another another-answer
```

{% endtab %}
{% endtabs %}

#### Example curl message

```shell
curl -d @app.log -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration file example 3

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name http
  listen 0.0.0.0
  port 8888

[OUTPUT]
  name stdout
  match *
```

{% endtab %}
{% endtabs %}

### Command line

```shell
 fluent-bit -i http -p port=8888 -o stdout
```