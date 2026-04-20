# Pipeline

The `pipeline` section of YAML configuration files defines the flow of how data is collected, processed, and sent to its final destination. This section contains the following subsections:

- [`inputs`](#inputs): Configures input plugins.
- [`filters`](#filters): Configures filters.
- [`outputs`](#outputs): Configures output plugins.


{% hint style="info" %}

Unlike filters, processors and parsers aren't defined within a unified section of YAML configuration files and don't use tag matching. Instead, each input or output plugin defined in the configuration file can have a `parsers` key and a `processors` key to configure the parsers and processors for that specific plugin.

{% endhint %}

## Syntax

The `pipeline` section of a YAML configuration file uses the following syntax:

```yaml
pipeline:
    inputs:
        ...
    filters:
        ...
    outputs:
        ...
```

Each of the subsections for `inputs`, `filters`, and `outputs` constitutes an array of maps that has the parameters for each. Most properties are either strings or numbers and can be defined directly.

For example:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: tail
          path: /var/log/example.log
          parser: json

          processors:
              logs:
                  - name: record_modifier

    filters:
        - name: grep
          match: '*'
          regex: key pattern

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% endtabs %}


{% hint style="info" %}

It's possible to define multiple `pipeline` sections, but they won't operate independently. Instead, Fluent Bit merges all defined pipelines into a single pipeline internally.

{% endhint %}

## Inputs

The `inputs` section defines one or more [input plugins](../../../pipeline/inputs.md). In addition to the settings unique to each plugin, all input plugins support the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `name` | Name of the input plugin. Defined as subsection of the `inputs` section. |
| `tag` | Tag name associated to all records coming from this plugin. |
| `log_level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `service` section's `log_level`. |

The `name` parameter is required and defines for Fluent Bit which input plugin should be loaded. The `tag` parameter is required for all plugins except for the `forward` plugin, which provides dynamic tags.

### Shared HTTP listener settings for inputs

Some HTTP-based input plugins share the same listener implementation and support the following common settings in addition to their plugin-specific parameters:

These settings are shared by HTTP-based inputs such as `http`, `splunk`,
`elasticsearch`, `opentelemetry`, and `prometheus_remote_write`.
Use these keys the same way across those plugins.

If a plugin page shows one of the `http_server.*` keys in its configuration
table, it is documenting one of these shared listener settings, not a
plugin-specific behavior.

| Key | Description | Default |
| --- | ----------- | ------- |
| `http_server.http2` | Enable HTTP/2 support for the input listener. | `true` |
| `http_server.buffer_max_size` | Set the maximum size of the HTTP request buffer. | `4M` |
| `http_server.buffer_chunk_size` | Set the allocation chunk size used for the HTTP request buffer. | `512K` |
| `http_server.max_connections` | Set the maximum number of concurrent active HTTP connections. `0` means unlimited. | `0` |
| `http_server.workers` | Set the number of HTTP listener worker threads. | `1` |
| `http_server.ingress_queue_event_limit` | Set the maximum number of deferred ingress queue entries. This setting applies only when `http_server.workers` is greater than `1`. | `8192` |
| `http_server.ingress_queue_byte_limit` | Set the maximum size of the deferred ingress queue. This setting applies only when `http_server.workers` is greater than `1`. | `256M` |

When `http_server.workers` is `1`, Fluent Bit does not use the deferred
ingress queue, so the two `http_server.ingress_queue_*` settings have no
effect.

For backward compatibility, some plugins also accept the legacy aliases `http2`, `buffer_max_size`, `buffer_chunk_size`, `max_connections`, and `workers`.

### Incoming `OAuth 2.0` `JWT` validation settings

The HTTP-based input plugins that support bearer token validation share the following `oauth2.*` settings:

| Key | Description | Default |
| --- | ----------- | ------- |
| `oauth2.validate` | Enable `OAuth 2.0` `JWT` validation for incoming requests. | `false` |
| `oauth2.issuer` | Expected issuer (`iss`) claim. Required when `oauth2.validate` is `true`. | _none_ |
| `oauth2.jwks_url` | `JWKS` endpoint URL used to fetch public keys for token validation. Required when `oauth2.validate` is `true`. | _none_ |
| `oauth2.allowed_audience` | Audience claim to enforce when validating tokens. | _none_ |
| `oauth2.allowed_clients` | Authorized `client_id` or `azp` claim values. This key can be specified multiple times. | _none_ |
| `oauth2.jwks_refresh_interval` | How often in seconds to refresh cached `JWKS` keys. | `300` |

When validation is enabled, requests without a valid `Authorization: Bearer <token>` header are rejected.

### Example input configuration

The following is an example of an `inputs` section that contains a `cpu` plugin.

```yaml
pipeline:
    inputs:
        - name: cpu
          tag: my_cpu
```

## Filters

The `filters` section defines one or more [filters](../../../pipeline/filters.md). In addition to the settings unique to each filter, all filters support the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `name` | Name of the filter plugin. Defined as a subsection of the `filters` section. |
| `match` | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `match_regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `log_level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `service` section's `log_level`. |

The `name` parameter is required and lets Fluent Bit know which filter should be loaded. One of either the `match` or `match_regex` parameters is required. If both are specified, `match_regex` takes precedence.

### Example filter configuration

The following is an example of a `filters` section that contains a `grep` plugin:

```yaml
pipeline:
    filters:
        - name: grep
          match: '*'
          regex: log aa
```


## Outputs

The `outputs` section defines one or more [output plugins](../../../pipeline/outputs.md). In addition to the settings unique to each plugin, all output plugins support the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `name` | Name of the output plugin. Defined as a subsection of the `outputs` section. |
| `match` | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `match_regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `log_level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. The output log level defaults to the `service` section's `log_level`. |

Fluent Bit can route up to 256 output plugins.

### Outgoing `OAuth 2.0` client credentials settings

Output plugins that support outgoing `OAuth 2.0` authentication can expose the following shared `oauth2.*` settings:

| Key | Description | Default |
| --- | ----------- | ------- |
| `oauth2.enable` | Enable `OAuth 2.0` client credentials for outgoing requests. | `false` |
| `oauth2.token_url` | Token endpoint URL. | _none_ |
| `oauth2.client_id` | Client ID. | _none_ |
| `oauth2.client_secret` | Client secret. | _none_ |
| `oauth2.scope` | Optional scope parameter. | _none_ |
| `oauth2.audience` | Optional audience parameter. | _none_ |
| `oauth2.resource` | Optional resource parameter. | _none_ |
| `oauth2.auth_method` | Client authentication method. Supported values: `basic`, `post`, `private_key_jwt`. | `basic` |
| `oauth2.jwt_key_file` | PEM private key file used with `private_key_jwt`. | _none_ |
| `oauth2.jwt_cert_file` | Certificate file used to derive the `kid` or `x5t` header value for `private_key_jwt`. | _none_ |
| `oauth2.jwt_aud` | Audience to use in `private_key_jwt` assertions. Defaults to `oauth2.token_url` when unset. | _none_ |
| `oauth2.jwt_header` | JWT header claim name used for the thumbprint. Supported values: `kid`, `x5t`. | `kid` |
| `oauth2.jwt_ttl_seconds` | Lifetime in seconds for `private_key_jwt` client assertions. | `300` |
| `oauth2.refresh_skew_seconds` | Seconds before expiry at which to refresh the access token. | `60` |
| `oauth2.timeout` | Timeout for token requests. | `0s` |
| `oauth2.connect_timeout` | Connect timeout for token requests. | `0s` |

### Example output configuration

The following is an example of an `outputs` section that contains a `stdout` plugin:

```yaml
pipeline:
    outputs:
        - name: stdout
          match: 'my*cpu'
```
