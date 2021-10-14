# Health

_NGINX Exporter Metrics_ input plugin scrapes metrics from the NGINX stub status handler.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Host | Name of the target host or IP address to check. |
| Host | Port of the target nginx service to connect to. |
| Status_URL | The URL of the Stub Status Handler. |

## Getting Started

NGINX must be configured with a location that invokes the stub status handler. Here is an example configuration with such a location:

```
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    // configure the stub status handler.
    location /status {
        stub_status;
    }
}
```



### Command Line

From the command line you can let Fluent Bit generate the checks with the following options:

```bash
$ fluent-bit -i health://127.0.0.1:80 -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          health
    Host          127.0.0.1
    Port          80
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

You can quickly test against the NGINX server running on localhost by invoking it directly from the command line:

```bash
$ fluent-bit -i nginx_metrics -p host=127.0.0.1 -o stdout -p match=* -f 1
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

2021-10-14T19:37:37.228691854Z nginx_connections_accepted = 788253884
2021-10-14T19:37:37.228691854Z nginx_connections_handled = 788253884
2021-10-14T19:37:37.228691854Z nginx_http_requests_total = 42045501
2021-10-14T19:37:37.228691854Z nginx_connections_active = 2009
2021-10-14T19:37:37.228691854Z nginx_connections_reading = 0
2021-10-14T19:37:37.228691854Z nginx_connections_writing = 1
2021-10-14T19:37:37.228691854Z nginx_connections_waiting = 2008
2021-10-14T19:37:35.229919621Z nginx_up = 1
```
