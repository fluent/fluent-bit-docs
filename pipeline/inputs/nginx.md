# NGINX exporter metrics

The _NGINX exporter metrics_ input plugin scrapes metrics from the NGINX stub status handler.

{% hint style="info" %}

Metrics collected with NGINX Exporter Metrics flow through a separate pipeline from logs, and current filters don't operate on top of metrics.

{% endhint %}

## Configuration parameters

The plugin supports the following configuration parameters:

| Key               | Description                                                                                             | Default     |
|:------------------|:--------------------------------------------------------------------------------------------------------|:------------|
| `host`            | Name of the target host or IP address.                                                                  | `localhost` |
| `nginx_plus`      | Turn on NGINX Plus mode.                                                                                | `true`      |
| `port`            | Port of the target NGINX service to connect to.                                                         | `80`        |
| `scrape_interval` | The interval to scrape metrics from the NGINX service.                                                  | `5s`        |
| `status_url`      | The URL of the stub status handler.                                                                     | `/status`   |
| `threaded`        | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false`     |

### TLS / SSL

The NGINX exporter metrics input plugin supports TLS/SSL. For more details about the properties available and general configuration, refer to [Transport Security](../../administration/transport-security.md).

## Get started

NGINX must be configured with a location that invokes the stub status handler. The following is an example configuration with such a location:

```text
server {
  listen       80;
  listen  [::]:80;
  server_name  localhost;
  location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
  }
  # Configure the stub status handler.
  location /status {
    stub_status;
  }
}
```

### Configuration with NGINX Plus REST API

Another metrics API is available with NGINX Plus. You must first configure a path in NGINX Plus.

```text
server {
  listen       80;
  listen  [::]:80;
  server_name  localhost;

  # Enable /api/ location with appropriate access control in order
  # to make use of NGINX Plus API.
  location /api/ {
    api write=on;
    # Configure to allow requests from the server running Fluent Bit.
    allow 192.168.1.*;
    deny all;
  }
}
```

### Command line

From the command line you can let Fluent Bit generate the checks with the following options:

```shell
fluent-bit -i nginx_metrics -p host=127.0.0.1 -p port=80 -p status_url=/status -p nginx_plus=off -o stdout
```

To gather metrics from the command line with the NGINX Plus REST API, turn on the
`nginx_plus` property:

```shell
fluent-bit -i nginx_metrics -p host=127.0.0.1 -p port=80 -p nginx_plus=on -p status_url=/api -o stdout
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: nginx_metrics
      host: 127.0.0.1
      port: 80
      status_url: /status
      nginx_plus: off
      scrape_interval: 5s

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name            nginx_metrics
  Host            127.0.0.1
  Port            80
  Status_URL      /status
  Nginx_Plus      off
  Scrape_Interval 5s

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

And for NGINX Plus API:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: nginx_metrics
      host: 127.0.0.1
      port: 80
      status_url: /api
      nginx_plus: on
      scrape_interval: 5s

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name            nginx_metrics
  Host            127.0.0.1
  Port            80
  Status_URL      /api
  Nginx_Plus      on
  Scrape_Interval 5s

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

## Test your configuration

You can test against the NGINX server running on localhost by invoking it directly from the command line:

```shell
fluent-bit -i nginx_metrics -p host=127.0.0.1 -p nginx_plus=off -o stdout -p match=* -f 1
```

This returns output similar to the following:

```text
...
2021-10-14T19:37:37.228691854Z nginx_connections_accepted = 788253884
2021-10-14T19:37:37.228691854Z nginx_connections_handled = 788253884
2021-10-14T19:37:37.228691854Z nginx_http_requests_total = 42045501
2021-10-14T19:37:37.228691854Z nginx_connections_active = 2009
2021-10-14T19:37:37.228691854Z nginx_connections_reading = 0
2021-10-14T19:37:37.228691854Z nginx_connections_writing = 1
2021-10-14T19:37:37.228691854Z nginx_connections_waiting = 2008
2021-10-14T19:37:35.229919621Z nginx_up = 1
...
```

## Exported metrics

For a list of available metrics, see the [NGINX Prometheus Exporter metrics documentation](https://github.com/nginxinc/nginx-prometheus-exporter/blob/main/README.md) on GitHub.
