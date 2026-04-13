
# HTTP

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _HTTP_ input plugin lets Fluent Bit open an HTTP port that you can then route data to in a dynamic way.

## Configuration parameters

The table below includes both:

- settings specific to the HTTP input plugin
- shared `http_server.*` listener settings that are used by several HTTP-based inputs

For a cross-plugin explanation of the shared listener settings, see
[Shared HTTP listener settings for inputs](../../administration/configuring-fluent-bit/yaml/pipeline-section.md#shared-http-listener-settings-for-inputs).

| Key                        | Description                                                                                                                                         | Default   |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| `add_remote_addr`          | Adds a `REMOTE_ADDR` field to the record. The value of `REMOTE_ADDR` is the client's address, which is extracted from the `X-Forwarded-For` header. | `false`   |
| `buffer_chunk_size`        | This sets the chunk size for incoming JSON messages. These chunks are then stored and managed in the space available by `buffer_max_size`. Compatibility alias for `http_server.buffer_chunk_size`. | `512K`    |
| `buffer_max_size`          | Specify the maximum buffer size to receive a JSON message. Compatibility alias for `http_server.buffer_max_size`.                                   | `4M`      |
| `http2`                    | Enable HTTP/2 support. Compatibility alias for `http_server.http2`.                                                                                 | `true`    |
| `http_server.max_connections` | Maximum number of concurrent active HTTP connections. `0` means unlimited.                                                                      | `0`       |
| `http_server.workers`      | Number of HTTP listener worker threads.                                                                                                             | `1`       |
| `http_server.ingress_queue_event_limit` | Maximum number of deferred ingress queue entries. Applies only when `http_server.workers` is greater than `1`.                          | `8192`    |
| `http_server.ingress_queue_byte_limit` | Maximum size of the deferred ingress queue. Applies only when `http_server.workers` is greater than `1`.                                | `256M`    |
| `listen`                   | The address to listen on.                                                                                                                           | `0.0.0.0` |
| `oauth2.allowed_audience`  | Audience claim to enforce when validating incoming `OAuth 2.0` `JWT` tokens.                                                                        | _none_    |
| `oauth2.allowed_clients`   | Authorized `client_id` or `azp` claim values. Can be specified multiple times.                                                                      | _none_    |
| `oauth2.issuer`            | Expected issuer (`iss`) claim. Required when `oauth2.validate` is `true`.                                                                           | _none_    |
| `oauth2.jwks_refresh_interval` | How often in seconds to refresh the cached `JWKS` keys from `oauth2.jwks_url`.                                                                 | `300`     |
| `oauth2.jwks_url`          | `JWKS` endpoint URL used to fetch public keys for `JWT` validation. Required when `oauth2.validate` is `true`.                                      | _none_    |
| `oauth2.validate`          | Enable `OAuth 2.0` `JWT` validation for incoming requests.                                                                                          | `false`   |
| `port`                     | The port for Fluent Bit to listen on.                                                                                                               | `9880`    |
| `remote_addr_key`          | Key name for the remote address field added to the record when `add_remote_addr` is enabled.                                                        | `REMOTE_ADDR` |
| `success_header`           | Add an HTTP header key/value pair on success. Multiple headers can be set. For example, `X-Custom custom-answer`.                                   | _none_    |
| `successful_response_code` | Allows setting successful response code. Supported values: `200`, `201`, and `204`.                                                                 | `201`     |
| `tag_key`                  | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                                 | _none_    |
| `threaded`                 | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                             | `false`   |

The `http_server.ingress_queue_event_limit` and
`http_server.ingress_queue_byte_limit` settings matter only when
`http_server.workers` is greater than `1`.

### TLS / SSL

HTTP input plugin supports TLS/SSL. For more details about the properties available and general configuration, refer to [Transport Security](../../administration/transport-security.md).

### gzipped content

The HTTP input plugin will accept and automatically handle gzipped content in version 2.2.1 or later if the header `Content-Encoding: gzip` is set on the received data.

### `OAuth 2.0 JWT` validation

When `oauth2.validate` is set to `true`, the HTTP input plugin validates the `Authorization: Bearer <token>` header on every incoming request. Requests with a missing, expired, or invalid token are rejected with a `401` response.

`oauth2.issuer` and `oauth2.jwks_url` are both required when validation is enabled. `JWKS` keys are fetched lazily: the first request that requires validation triggers the initial retrieval from `oauth2.jwks_url`. Keys are then cached and refreshed every `oauth2.jwks_refresh_interval` seconds.

## Get started

This plugin supports dynamic tags which let you send data with different tags through the same input. See the following for an example:

[Link to video](https://asciinema.org/a/375571)

### Set a tag

The tag for the HTTP input plugin is set by adding the tag to the end of the request URL. This tag is then used to route the event through the system.

For example, in the following curl message the tag set is `app.log` because the end path is `/app.log`:

```shell
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Add a remote address field

The `add_remote_addr` configuration parameter, when activated, adds a `REMOTE_ADDR` field to the records. The value of `REMOTE_ADDR` is the client's address, which is extracted from the `X-Forwarded-For` header.

In most cases, only a single `X-Forwarded-For` header is in the request, so the following curl would add a `REMOTE_ADDR` field which would be set to `host1`:

```shell
curl -d '{"key1":"value1"}' -XPOST -H 'Content-Type: application/json' -H 'X-Forwarded-For: host1, host2' http://localhost:8888
```

However, if your system sets multiple `X-Forwarded-For` headers in the request, the one used (first, or last) depends on the value of the `http2` parameter. For example:

Assuming the following X-Forwarded-For headers are in the request:

```text
X-Forwarded-For: host1, host2
X-Forwarded-For: host3, host4
```

The value of `REMOTE_ADDR` will be:

| `http2` value    | `REMOTE_ADDR` value |
|------------------|---------------------|
| `true` (default) | `host3`             |
| `false`          | `host1`             |

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
  Name   http
  Listen 0.0.0.0
  Port   8888

[OUTPUT]
  Name  stdout
  Match app.log
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
  Name   http
  Listen 0.0.0.0
  Port   8888

[OUTPUT]
  Name  stdout
  Match http.0
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
  Name    http
  Listen  0.0.0.0
  Port    8888
  Tag_Key key1

[OUTPUT]
  Name  stdout
  Match value1
```

{% endtab %}
{% endtabs %}

#### Set `add_remote_addr`

The `add_remote_addr` configuration option lets you activate a feature that systematically adds the `REMOTE_ADDR` field to events, and set its value to the client's address. The address will be extracted from the `X-Forwarded-For` header of the request. The format is:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888
      add_remote_addr: true
  outputs:
    - name: stdout
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name http
  Listen 0.0.0.0
  Port 8888
  Add_Remote_Addr true

[OUTPUT]
  Name stdout
```

{% endtab %}
{% endtabs %}

#### Example curl to test this feature

```shell
curl -d '{"key1":"value1"}' -XPOST -H 'Content-Type: application/json' -H 'X-Forwarded-For: host1, host2' http://localhost:8888
```

#### Set multiple custom `HTTP` headers on success

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
  Name           http
  Success_Header X-Custom custom-answer
  Success_Header X-Another another-answer
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
  Name   http
  Listen 0.0.0.0
  Port   8888

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

### Enable `OAuth 2.0 JWT` validation

The following example enables `JWT` validation using a `JWKS` endpoint. All incoming requests must include a valid bearer token issued by the specified issuer.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888
      oauth2.validate: true
      oauth2.issuer: https://auth.example.com
      oauth2.jwks_url: https://auth.example.com/.well-known/jwks.json
      oauth2.allowed_audience: my-service
      oauth2.jwks_refresh_interval: 300

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name                      http
  Listen                    0.0.0.0
  Port                      8888
  Oauth2.validate           true
  Oauth2.issuer             https://auth.example.com
  Oauth2.jwks_url           https://auth.example.com/.well-known/jwks.json
  Oauth2.allowed_audience   my-service
  Oauth2.jwks_refresh_interval 300

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

### Command line

```shell
fluent-bit -i http -p port=8888 -o stdout
```
