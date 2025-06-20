# NGINX Exporter metrics

The _NGINX Exporter metrics_ input plugin scrapes metrics from the NGINX stub status handler.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Host` | Name of the target host or IP address. | `localhost` |
| `Port` | Port of the target Nginx service to connect to. | `80` |
| `Status_URL` | The URL of the stub status Handler. | `/status` |
| `Nginx_Plus` | Turn on NGINX plus mode. | `true` |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

NGINX must be configured with a location that invokes the stub status handler. Here is an example configuration with such a location:

```text
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

### Configuration with NGINX Plus REST API

Another metrics API is available with NGINX Plus. You must first configure a path in
NGINX Plus.

```text
server {
	listen       80;
	listen  [::]:80;
	server_name  localhost;

	# enable /api/ location with appropriate access control in order
	# to make use of NGINX Plus API
	#
	location /api/ {
		api write=on;
		# configure to allow requests from the server running fluent-bit
		allow 192.168.1.*;
		deny all;
	}
}
```

### Command line

From the command line you can let Fluent Bit generate the checks with the following options:

```bash
fluent-bit -i nginx_metrics -p host=127.0.0.1 -p port=80 -p status_url=/status -p nginx_plus=off -o stdout
```

To gather metrics from the command line with the NGINX Plus REST API you need to turn on the
`nginx_plus` property:

```bash
fluent-bit -i nginx_metrics -p host=127.0.0.1 -p port=80 -p nginx_plus=on -p status_url=/api -o stdout
```

### Configuration File

In your main configuration file append the following `Input` and `Output` sections:

```python
[INPUT]
    Name          nginx_metrics
    Host          127.0.0.1
    Port          80
    Status_URL    /status
    Nginx_Plus    off

[OUTPUT]
    Name   stdout
    Match  *
```

And for NGINX Plus API:

```python
    Name          nginx_metrics
    Nginx_Plus    on
    Host          127.0.0.1
    Port          80
    Status_URL    /api

[OUTPUT]
    Name   stdout
    Match  *
```

## Test your configuration

You can test against the NGINX server running on localhost by invoking it directly from the command line:

```bash
fluent-bit -i nginx_metrics -p host=127.0.0.1 -p nginx_plus=off -o stdout -p match=* -f 1
```

Which should return something like the following:

```text
Fluent Bit v2.x.x
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

## Exported metrics

For a list of available metrics, see the [NGINX Prometheus Exporter metrics documentation](https://github.com/nginxinc/nginx-prometheus-exporter/blob/main/README.md) on GitHub.
