---
description: The HTTP input plugin allows you to send custom records to an HTTP endpoint.
---

# HTTP

## Configuration Parameters

| **Key**                  | Description                                                                                                                                   | default |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------|
| listen                   | The address to listen on                                                                                                                      | 0.0.0.0 |
| port                     | The port for Fluent Bit to listen on                                                                                                          | 9880    |
| tag_key                  | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                           |         |
| buffer_max_size          | Specify the maximum buffer size in KB to receive a JSON message.                                                                              | 4M      |
| buffer_chunk_size        | This sets the chunk size for incoming incoming JSON messages. These chunks are then stored/managed in the space available by buffer_max_size. | 512K    |
| successful_response_code | It allows to set successful response code. `200`, `201` and `204` are supported.                                                              | 201     |
| success_header           | Add an HTTP header key/value pair on success. Multiple headers can be set. Example: `X-Custom custom-answer`                                  |         |

### TLS / SSL

HTTP input plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [Transport Security](../../administration/transport-security.md) section.

## Getting Started

The http input plugin allows Fluent Bit to open up an HTTP port that you can then route data to in a dynamic way. This plugin supports dynamic tags which allow you to send data with different tags through the same input. An example video and curl message can be seen below

[Link to video](https://asciinema.org/a/375571)

#### How to set tag

The tag for the HTTP input plugin is set by adding the tag to the end of the request URL. This tag is then used to route the event through the system. For example, in the following curl message below the tag set is `app.log**. **` because the end end path is `/app_log`:

### Curl request

```
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration File

```
[INPUT]
    name http
    listen 0.0.0.0
    port 8888

[OUTPUT]
    name stdout
    match app.log
```

If you do not set the tag `http.0` is automatically used. If you have multiple HTTP inputs then they will follow a pattern of `http.N` where N is an integer representing the input.

### Curl request

```
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888
```

### Configuration File

```
[INPUT]
    name http
    listen 0.0.0.0
    port 8888

[OUTPUT]
    name  stdout
    match  http.0
```


#### How to set tag_key

The tag_key configuration option allows to specify the key name that will be used to overwrite a tag. The tag's value will be replaced with the value associated with the specified key. For example, setting tag_key to "custom_tag" and the log event contains a json field with the key "custom_tag" Fluent Bit will use the value of that field as the new tag for routing the event through the system.

### Curl request

```
curl -d '{"key1":"value1","key2":"value2"}' -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration File

```
[INPUT]
    name http
    listen 0.0.0.0
    port 8888
    tag_key key1

[OUTPUT]
    name stdout
    match value1
```


#### How to set multiple custom HTTP header on success

The `success_header` parameter allows to set multiple HTTP headers on success. The format is:

```ini
[INPUT]
    name http
    success_header X-Custom custom-answer
    success_header X-Another another-answer
```


#### Example Curl message

```
curl -d @app.log -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration File

```
[INPUT]
    name http
    listen 0.0.0.0
    port 8888

[OUTPUT]
    name stdout
    match *
```

### Command Line

```
$> fluent-bit -i http -p port=8888 -o stdout
```
