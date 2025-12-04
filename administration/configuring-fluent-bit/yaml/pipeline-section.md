# Pipeline

The `pipeline` section defines the flow of how data is collected, processed, and sent to its final destination. This section contains the following subsections:

| Name | Description |
| ---- | ----------- |
| `inputs` | Specifies the name of the plugin responsible for collecting or receiving data. This component serves as the data source in the pipeline. Examples of input plugins include `tail`, `http`, and `random`. |
| `filters` | Filters are used to transform, enrich, or discard events based on specific criteria. They allow matching tags using strings or regular expressions, providing a more flexible way to manipulate data. Filters run as part of the main event loop and can be applied across multiple inputs and filters. Examples of filters include `modify`, `grep`, and `nest`. |
| `outputs` | Defines the destination for processed data. Outputs specify where the data will be sent, such as to a remote server, a file, or another service. Each output plugin is configured with matching rules to determine which events are sent to that destination. Common output plugins include `stdout`, `elasticsearch`, and `kafka`. |

{% hint style="info" %}

Unlike filters, processors and parsers aren't defined within a unified section of YAML configuration files and don't use tag matching. Instead, each input or output defined in the configuration file can have a `parsers` key and `processors` key to configure the parsers and processors for that specific plugin.

{% endhint %}

## Format

A `pipeline` section will define a complete pipeline configuration, including `inputs`, `filters`, and `outputs` subsections. You can define multiple `pipeline` sections, but they won't operate independently. Instead, all components will be merged into a single pipeline internally.

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

```yaml
pipeline:
    inputs:
        - name: tail
          tag: syslog
          path: /var/log/syslog
        - name: http
          tag: http_server
          port: 8080
```

This pipeline consists of two `inputs`: a tail plugin and an HTTP server plugin. Each plugin has its own map in the array of `inputs` consisting of basic properties. To use more advanced properties that consist of multiple values the property itself can be defined using an array, such as the `record` and `allowlist_key` properties for the `record_modifier` `filter`:

```yaml
pipeline:
    inputs:
        - name: tail
          tag: syslog
          path: /var/log/syslog
    filters:
        - name: record_modifier
          match: syslog
          record:
              - powered_by calyptia
        - name: record_modifier
          match: syslog
          allowlist_key:
              - powered_by
              - message
```

In the cases where each value in a list requires two values they must be separated by a space, such as in the `record` property for the `record_modifier` filter.

### Inputs

An `input` section defines a source (related to an input plugin). Each section has a base configuration. Each input plugin can add it own configuration keys:

| Key | Description |
| --- |------------ |
| `Name` | Name of the input plugin. Defined as subsection of the `inputs` section. |
| `Tag` | Tag name associated to all records coming from this plugin. |
| `Log_Level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

The `Name` is mandatory and defines for Fluent Bit which input plugin should be loaded. `Tag` is mandatory for all plugins except for the `input forward` plugin which provides dynamic tags.

#### Example input

The following is an example of an `input` section for the `cpu` plugin.

```yaml
pipeline:
    inputs:
        - name: cpu
          tag: my_cpu
```

### Filters

A `filter` section defines a filter (related to a filter plugin). Each section has a base configuration and each filter plugin can add its own configuration keys:

| Key         | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `Name`        | Name of the filter plugin. Defined as a subsection of the `filters` section. |
| `Match`       | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `Match_Regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `Log_Level`   | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

`Name` is mandatory and lets Fluent Bit know which filter plugin should be loaded. The `Match` or `Match_Regex` is mandatory for all plugins. If both are specified, `Match_Regex` takes precedence.

#### Example filter

The following is an example of a `filter` section for the `grep` plugin:

```yaml
pipeline:
    filters:
        - name: grep
          match: '*'
          regex: log aa
```

### Outputs

The `outputs` section specifies a destination that certain records should follow after a `Tag` match. Fluent Bit can route up to 256 `OUTPUT` plugins. The configuration supports the following keys:

| Key         | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `Name`        | Name of the output plugin. Defined as a subsection of the `outputs` section. |
| `Match`       | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `Match_Regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `Log_Level`   | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. The output log level defaults to the `SERVICE` section's `Log_Level`. |

#### Example output

The following is an example of an `output` section:

```yaml
pipeline:
    outputs:
        - name: stdout
          match: 'my*cpu'
```

## Example configuration

Here's an example of a pipeline configuration:

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
