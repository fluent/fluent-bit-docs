---
description: The HTTP input plugin allows you to send custom records to an HTTP endpoint.
---

# HTTP

## Configuration Parameters

| **Key** | Description | default |
| :--- | :--- | :--- |
| host | The address to listen on | 0.0.0.0 |
| port | The port for Fluent Bit to listen on | 9880 |
| buffer\_max\_size | Specify the maximum buffer size in KB to receive a JSON message. | 4M |
| buffer\_chunk\_size | This sets the chunk size for incoming incoming JSON messages. These chunks are then stored/managed in the space available by buffer\_max\_size.  | 512K |

## Getting Started

The http input plugin allows Fluent Bit to open up an HTTP port that you can then route data to in a dynamic way. This plugin supports dynamic tags which allow you to send data with different tags through the same input. An example video and curl message can be seen below

[Link to video](https://asciinema.org/a/375571)

**How to set tag**

The tag for the HTTP input plugin is set by adding the tag to the end of the request URL. This tag is then used to route the event through the system. For example, in the following curl message below the tag set is `app.log`**.** If you do not set the tag `http.0` is automatically used. If you have multiple HTTP inputs then they will follow a pattern of `http.N` where N is an integer representing the input.

**Example Curl message**

```text
curl -d @app.log -XPOST -H "content-type: application/json" http://localhost:8888/app.log
```

### Configuration File

```text
[INPUT]
    name http
    host 0.0.0.0
    port 8888

[OUTPUT]
    type stdout
    match *
```

### Command Line

```text
$> fluent-bit -i http -p port=8888 -o stdout
```

#### 

