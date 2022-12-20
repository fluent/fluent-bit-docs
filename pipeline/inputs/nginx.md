# NGINX Exporter Metrics

_NGINX Exporter Metrics_ input plugin scrapes metrics from the NGINX stub status handler.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Host | Name of the target host or IP address to check. | localhost |
| Port | Port of the target nginx service to connect to. | 80 |
| Status_URL | The URL of the Stub Status Handler. | /status |
| Nginx_Plus | Turn on NGINX plus mode. | true |

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

### Configuration with NGINX Plus REST API

A much more powerful and flexible metrics API is available with NGINX Plus. A path needs to be configured 
in NGINX Plus first.

```
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

### Command Line

From the command line you can let Fluent Bit generate the checks with the following options:

```bash
$ fluent-bit -i nginx_metrics -p host=127.0.0.1 -p port=80 -p status_url=/status -p nginx_plus=off -o stdout
```

To gather metrics from the command line with the NGINX Plus REST API we need to turn on the
nginx_plus property, like so:

```bash
$ fluent-bit -i nginx_metrics -p host=127.0.0.1 -p port=80 -p nginx_plus=on -p status_url=/api -o stdout
```


### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```ini
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

```ini
[INPUT]
    Name          nginx_metrics
    Nginx_Plus    on
    Host          127.0.0.1
    Port          80
    Status_URL    /api

[OUTPUT]
    Name   stdout
    Match  *
```



## Testing

You can quickly test against the NGINX server running on localhost by invoking it directly from the command line:

```bash
$ fluent-bit -i nginx_metrics -p host=127.0.0.1 -p nginx_plus=off -o stdout -p match=* -f 1
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

## Exported Metrics

This documentation is copied from the nginx prometheus exporter metrics documentation: 
[https://github.com/nginxinc/nginx-prometheus-exporter/blob/master/README.md].

### Common metrics:
Name | Type | Description | Labels
----|----|----|----|
`nginx_up` | Gauge | Shows the status of the last metric scrape: `1` for a successful scrape and `0` for a failed one | [] |

### Metrics for NGINX OSS:
#### [Stub status metrics](https://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
Name | Type | Description | Labels
----|----|----|----|
`nginx_connections_accepted` | Counter | Accepted client connections. | [] |
`nginx_connections_active` | Gauge | Active client connections. | [] |
`nginx_connections_handled` | Counter | Handled client connections. | [] |
`nginx_connections_reading` | Gauge | Connections where NGINX is reading the request header. | [] |
`nginx_connections_waiting` | Gauge | Idle client connections. | [] |
`nginx_connections_writing` | Gauge | Connections where NGINX is writing the response back to the client. | [] |
`nginx_http_requests_total` | Counter | Total http requests. | [] |

### Metrics for NGINX Plus:
#### [Connections](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_connections)
Name | Type | Description | Labels
----|----|----|----|
`nginxplus_connections_accepted` | Counter | Accepted client connections | [] |
`nginxplus_connections_active` | Gauge | Active client connections | [] |
`nginxplus_connections_dropped` | Counter | Dropped client connections dropped | [] |
`nginxplus_connections_idle` | Gauge | Idle client connections | [] |

#### [HTTP](https://nginx.org/en/docs/http/ngx_http_api_module.html#http_)
Name | Type | Description | Labels
----|----|----|----|
`nginxplus_http_requests_total` | Counter | Total http requests | [] |
`nginxplus_http_requests_current` | Gauge | Current http requests | [] |

#### [SSL](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_ssl_object)
Name | Type | Description | Labels
----|----|----|----|
`nginxplus_ssl_handshakes` | Counter | Successful SSL handshakes | [] |
`nginxplus_ssl_handshakes_failed` | Counter | Failed SSL handshakes | [] |
`nginxplus_ssl_session_reuses` | Counter | Session reuses during SSL handshake | [] |

#### [HTTP Server Zones](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_http_server_zone)
Name | Type | Description | Labels
----|----|----|----|
`nginxplus_server_zone_processing` | Gauge | Client requests that are currently being processed | `server_zone` |
`nginxplus_server_zone_requests` | Counter | Total client requests | `server_zone` |
`nginxplus_server_zone_responses` | Counter | Total responses sent to clients | `code` (the response status code. The values are: `1xx`, `2xx`, `3xx`, `4xx` and `5xx`), `server_zone` |
`nginxplus_server_zone_discarded` | Counter | Requests completed without sending a response | `server_zone` |
`nginxplus_server_zone_received` | Counter | Bytes received from clients | `server_zone` |
`nginxplus_server_zone_sent` | Counter | Bytes sent to clients | `server_zone` |

#### [Stream Server Zones](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_stream_server_zone)
Name | Type | Description | Labels
----|----|----|----|
`nginxplus_stream_server_zone_processing` | Gauge | Client connections that are currently being processed | `server_zone` |
`nginxplus_stream_server_zone_connections` | Counter | Total connections | `server_zone` |
`nginxplus_stream_server_zone_sessions` | Counter | Total sessions completed | `code` (the response status code. The values are: `2xx`, `4xx`, and `5xx`), `server_zone` |
`nginxplus_stream_server_zone_discarded` | Counter | Connections completed without creating a session | `server_zone` |
`nginxplus_stream_server_zone_received` | Counter | Bytes received from clients | `server_zone` |
`nginxplus_stream_server_zone_sent` | Counter | Bytes sent to clients | `server_zone` |

#### [HTTP Upstreams](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_http_upstream)

> Note: for the `state` metric, the string values are converted to float64 using the following rule: `"up"` -> `1.0`, `"draining"` -> `2.0`, `"down"` -> `3.0`, `"unavail"` –> `4.0`, `"checking"` –> `5.0`, `"unhealthy"` -> `6.0`.

Name | Type | Description | Labels
----|----|----|----|
`nginxplus_upstream_server_state` | Gauge | Current state | `server`, `upstream` |
`nginxplus_upstream_server_active` | Gauge | Active connections | `server`, `upstream` |
`nginxplus_upstream_server_limit` | Gauge | Limit for connections which corresponds to the max_conns parameter of the upstream server. Zero value means there is no limit | `server`, `upstream` |
`nginxplus_upstream_server_requests` | Counter | Total client requests | `server`, `upstream` |
`nginxplus_upstream_server_responses` | Counter | Total responses sent to clients | `code` (the response status code. The values are: `1xx`, `2xx`, `3xx`, `4xx` and `5xx`), `server`, `upstream` |
`nginxplus_upstream_server_sent` | Counter | Bytes sent to this server | `server`, `upstream` |
`nginxplus_upstream_server_received` | Counter | Bytes received to this server | `server`, `upstream` |
`nginxplus_upstream_server_fails` | Counter | Number of unsuccessful attempts to communicate with the server | `server`, `upstream` |
`nginxplus_upstream_server_unavail` | Counter | How many times the server became unavailable for client requests (state 'unavail') due to the number of unsuccessful attempts reaching the max_fails threshold | `server`, `upstream` |
`nginxplus_upstream_server_header_time` | Gauge | Average time to get the response header from the server | `server`, `upstream` |
`nginxplus_upstream_server_response_time` | Gauge | Average time to get the full response from the server | `server`, `upstream` |
`nginxplus_upstream_keepalives` | Gauge | Idle keepalive connections | `upstream` |
`nginxplus_upstream_zombies` | Gauge | Servers removed from the group but still processing active client requests | `upstream` |

#### [Stream Upstreams](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_stream_upstream)

> Note: for the `state` metric, the string values are converted to float64 using the following rule: `"up"` -> `1.0`, `"down"` -> `3.0`, `"unavail"` –> `4.0`, `"checking"` –> `5.0`, `"unhealthy"` -> `6.0`.

Name | Type | Description | Labels
----|----|----|----|
`nginxplus_stream_upstream_server_state` | Gauge | Current state | `server`, `upstream` |
`nginxplus_stream_upstream_server_active` | Gauge | Active connections | `server` , `upstream` |
`nginxplus_stream_upstream_server_limit` | Gauge | Limit for connections which corresponds to the max_conns parameter of the upstream server. Zero value means there is no limit | `server` , `upstream` |
`nginxplus_stream_upstream_server_connections` | Counter | Total number of client connections forwarded to this server | `server`, `upstream` |
`nginxplus_stream_upstream_server_connect_time` | Gauge | Average time to connect to the upstream server | `server`, `upstream`
`nginxplus_stream_upstream_server_first_byte_time` | Gauge | Average time to receive the first byte of data | `server`, `upstream` |
`nginxplus_stream_upstream_server_response_time` | Gauge | Average time to receive the last byte of data | `server`, `upstream` |
`nginxplus_stream_upstream_server_sent` | Counter | Bytes sent to this server | `server`, `upstream` |
`nginxplus_stream_upstream_server_received` | Counter | Bytes received from this server | `server`, `upstream` |
`nginxplus_stream_upstream_server_fails` | Counter | Number of unsuccessful attempts to communicate with the server | `server`, `upstream` |
`nginxplus_stream_upstream_server_unavail` | Counter | How many times the server became unavailable for client connections (state 'unavail') due to the number of unsuccessful attempts reaching the max_fails threshold | `server`, `upstream` |
`nginxplus_stream_upstream_zombies` | Gauge | Servers removed from the group but still processing active client connections | `upstream`|

#### [Location Zones](https://nginx.org/en/docs/http/ngx_http_api_module.html#def_nginx_http_location_zone)
Name | Type | Description | Labels
----|----|----|----|
`nginxplus_location_zone_requests` | Counter | Total client requests | `location_zone` |
`nginxplus_location_zone_responses` | Counter | Total responses sent to clients | `code` (the response status code. The values are: `1xx`, `2xx`, `3xx`, `4xx` and `5xx`), `location_zone` |
`nginxplus_location_zone_discarded` | Counter | Requests completed without sending a response | `location_zone` |
`nginxplus_location_zone_received` | Counter | Bytes received from clients | `location_zone` |
`nginxplus_location_zone_sent` | Counter | Bytes sent to clients | `location_zone` |
