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

### Example output configuration

The following is an example of an `outputs` section that contains a `stdout` plugin:

```yaml
pipeline:
    outputs:
        - name: stdout
          match: 'my*cpu'
```
