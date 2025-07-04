# Sampling

The _Sampling_ processor is designed with a pluggable architecture, allowing easy extension to support multiple trace sampling strategies and backends. It provides you with the ability to apply head or tail sampling to incoming trace telemetry data.

{% hint style="info" %}

**Note:** Both processors and this specific component can be enabled only by using
the YAML configuration format. Classic mode configuration format doesn't support processors.

{% endhint %}

Available samplers:

- `probabilistic` (head sampling)
- `tail` (tail sampling)

Conditions:

- `latency`
- `span_count`
- `status_code`
- `string_attribute`
- `numeric_attribute`
- `boolean_attribute`
- `trace_state`

## Configuration Parameters

The processor does not provide any extra configuration parameter, it can be used directly in your _processors_ Yaml directive.

## Sampling types

Sampling has both a name and a type with the following possible settings:

| Key    |     Possible values     |
| :----- | :---------------------: |
| `name` |       `sampling`        |
| `type` | `probabilistic`, `tail` |

## Head sampling

In this example, head sampling will be used to process a smaller percentage of the overall ingested traces and spans. This is done by setting up the pipeline to ingest on the OpenTelemetry defined port as shown below using the OpenTelemetry Protocol (OTLP). The processor section defines traces for head sampling and the sampling percentage defining the total ingested traces and spans to be forwarded to the defined output plugins.

![](../../.gitbook/assets/traces_head_sampling.png)

| Sampling settings     | Description                                                                                                         |
| :-------------------- | :------------------------------------------------------------------------------------------------------------------ |
| `sampling_percentage` | This sets the probability of sampling trace, can be between 0-100%. For example, 40 samples 40% of traces randomly. |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Head sampling of traces (percentage)
                  - name: sampling
                    type: probabilistic
                    sampling_settings:
                    sampling_percentage: 40

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

With this head sampling configuration, a sample set of ingested traces will randomly send 40% of the total traces to the standard output.

## Tail sampling

Tail sampling is used to obtain a more selective and fine grained control over the collection of traces and spans without collecting everything. Below is an example showing the process is a combination of waiting on making a sampling decision together followed by configuration defined conditions to determine the spans to be sampled.

![](../../.gitbook/assets/traces_tail_sampling.png)

The following samplings settings are available with their default values:

| Sampling settings | Description                                                                                                                | Default value |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `decision_wait`   | Specifies how long to buffer spans before making a sampling decision, allowing full trace evaluation.                      |      30s      |
| `max_traces`      | Specifies the maximum number of traces that can be held in memory. When the limit is reached, the oldest trace is deleted. |               |

The tail-based sampler supports various conditionals to sample traces if their spans meet a specific condition.

### Condition: latency

This condition samples traces based on span duration. It uses `threshold_ms_low` to capture short traces and `threshold_ms_high` for long traces.

| Condition settings  | Description                                                                                  | Default value |
| :------------------ | :------------------------------------------------------------------------------------------- | :-----------: |
| `threshold_ms_low`  | Specifies the lower latency threshold. Traces with a duration <= this value will be sampled. |       0       |
| `threshold_ms_high` | Specifies the upper latency threshold. Traces with a duration >= this value will be sampled. |       0       |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (latency)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 5s
                    conditions:
                      - type: latency
                        threshold_ms_low: 200
                        threshold_ms_high: 3000

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

This tail-based sampling configuration waits 5 seconds before making a decision. It samples traces based on latency, capturing short traces of 200ms or less and long traces of 3000ms or more. Traces between 200ms and 3000ms are not sampled unless another condition applies.

### Condition: span_count

This condition samples traces that have specific span counts defined in a configurable range. It uses `min_spans` and `max_spans` to specify the number of spans a trace can have to be sampled.

| Condition settings | Description                                                            | Default value |
| :----------------- | :--------------------------------------------------------------------- | :-----------: |
| `max_spans`        | Specifies the minimum number of spans a trace must have to be sampled. |               |
| `min_spans`        | Specifies the maximum number of spans a trace can have to be sampled.  |               |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (span_count)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 5s
                    conditions:
                        - type: span_count
                          min_spans: 3
                          max_spans: 5

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

This tail-based sampling configuration waits 5 seconds before making a decision. It samples traces based on having a minimum of 3 spans and a maximum of 5 spans. Traces with less than 3 and more than 5 spans are not sampled unless another condition applies.

### Condition: status_code

This condition samples traces based on span status codes (`OK`, `ERROR`, `UNSET`).

| Condition settings | Description                                                                                                                                                                                                                              | Default value |
| :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `status_codes`     | Defines an array of span status codes (`OK`, `ERROR`, `UNSET`) to filter traces. Traces are sampled if any span matches a listed status code. For example, `status_codes: [ERROR, UNSET]` captures traces with errors or unset statuses. |               |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (status_code)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 5s
                    conditions:
                        - type: status_code
                          status_codes: [ERROR]

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

With this tail-based sampling configuration, a sample set of ingested traces will select only the spans with status codes marked as `ERROR` to the standard output.

### Condition: string_attribute

This conditional allows traces to be sampled based on specific span or resource attributes. Users can define key-value filters (e.g., http.method=POST) to selectively capture relevant traces.

| Condition settings | Description                                                                                                                                                                               | Default value |
| :----------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `key`              | Specifies the span or resource attribute to match (e.g., "service.name").                                                                                                                 |               |
| `values`           | Defines an array of accepted values for the attribute. A trace is sampled if any span contains a matching key-value pair: `["payment-processing"]`                                        |               |
| `match_type`       | Defines how attributes are compared: `strict` ensures exact value matching, `exists` checks if the attribute is present regardless of its value, and `regex` enables regular expression pattern matching |   `strict`    |

#### Match Types

- **`strict`**: Exact value matching (case-sensitive)
- **`exists`**: Checks if the attribute key is present, regardless of its value
- **`regex`**: Matches values using regular expression patterns

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (string_attribute)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 2s
                    conditions:
                        # Exact matching
                        - type: string_attribute
                          match_type: strict
                          key: "http.method"
                          values: ["GET"]

                        # Check if attribute exists
                        - type: string_attribute
                          match_type: exists
                          key: "service.name"
        
                        # Regex pattern matching
                        - type: string_attribute
                          match_type: regex
                          key: "http.url"
                          values: ["^https://api\\..*", ".*\\/health$"]
        
                        # Multiple regex patterns for error conditions
                        - type: string_attribute
                          match_type: regex
                          key: "error.message"
                          values: ["timeout.*", "connection.*failed", ".*rate.?limit.*"]

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

This tail-based sampling configuration waits 2 seconds before making a decision. It samples traces based on string matching key value pairs:

- Traces with `http.method` exactly equal to `GET`
- Traces that have a `service.name` attribute (any value)
- Traces with `http.url` starting with `https://api.` or ending with `/health`
- Traces with `error.message` containing timeout, connection failed, or rate limit patterns

### Condition: numeric_attribute

This condition samples traces based on numeric attribute values of a defined key where users can configure minimum and maximum thresholds.

| Condition settings | Description                                                                                                                                           | Default value |
| :----------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `key`              | Specifies the span or resource attribute to match (e.g., "service.name").                                                                             |               |
| `min_value`        | The minimum inclusive value for the numeric attribute. Traces with values >= the `min_value` are sampled.                                             |               |
| `max_value`        | The maximum inclusive value for the numeric attribute. Traces with values <= the `max_value` are sampled.                                             |               |
| `match_type`       | This defines how attribute values are evaluated: `strict` matches exact values, `exists` checks if the attribute is present, regardless of its value. |   `strict`    |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (status_code)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 5s
                    conditions:
                        - type: numeric_attribute
                          key: "http.status_code"
                          min_value: 400
                          max_value: 504

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

With this tail-based sampling configuration, a sample set of ingested traces will select only the spans with a key `http.status code` with numeric values between 400 and 504 inclusive.

### Condition: boolean_attribute

This condition samples traces based on a boolean attribute value of a defined key. This allows for selection of traces based on flags such as error indicators or debug modes.

| Condition settings | Description                                                               | Default value |
| :----------------- | :------------------------------------------------------------------------ | :-----------: |
| `key`              | Specifies the span or resource attribute to match (e.g., "service.name"). |               |
| `value`            | Expected boolean value: `true` or `false`                                 |               |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (boolean_attribute)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 2s
                    conditions:
                        - type: boolean_attribute
                          key: "user.logged"
                          value: false

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

This tail-based sampling configuration waits 2 seconds before making a decision. It samples traces that do not have the key `user.logged` set to true. Traces are sampled if the key `user.logged` is set to `true`.

### Condition: trace_state

This condition samples traces based on metadata stored int he W3C `trace_state` field.

| Condition settings | Description                                                                                                                                                                                                                                             | Default value |
| :----------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :-----------: |
| `values`           | Defines a list of key, value pairs to match against the `trace_state`. A trace is sampled if any of the specified values exist in the `trace_state` field. Matching follows OR logic, meaning at least one value must be present for sampling to occur. |               |

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    hot_reload: on

pipeline:
    inputs:
        - name: opentelemetry
          port: 4318

          processors:
              traces:
                  # Tail sampling of traces (trace_state)
                  - name: sampling
                    type: tail
                    sampling_settings:
                        decision_wait: 2s
                    conditions:
                        - type: trace_state
                          values: [debug=false, priority=high]

    outputs:
        - name: stdout
          match: "*"
```

{% endtab %}
{% endtabs %}

This tail-based sampling configuration waits 2 seconds before making a decision. It samples traces that do not have the key `user.logged` set to true. Traces are sampled if the key `user.logged` is set to `true`.

For more details about further processing, read the [Content Modifier](../processors/content-modifier.md) processor documentation.