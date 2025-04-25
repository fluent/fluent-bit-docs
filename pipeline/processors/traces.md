# Traces

The _Traces_ sampling processor is designed with a pluggable architecture, allowing easy extension to support multiple sampling strategies and backends. It provides you with the ability to apply head or tail sampling to incoming trace telemetry data.

<!-- Available samplers:

- `probabilistic` (head sampling)
- `tail` (tail sampling)
  - conditions:
    - `status_code`
    - `latency`
    - `string_attribute`
    - `numeric_attribute`
    - `boolean_attribute`
    - `span_count`
    - `trace_state` -->

## Configuration Parameters

The processor does not provide any extra configuration parameter, it can be used directly in your _processors_ Yaml directive.

## Traces types

Traces have both a name and a type with the following possible settings:

| Key    |     Possible values     |
| :----- | :---------------------: |
| `name` |       `sampling`        |
| `type` | `probabilistic`, `tail` |

## Head sampling

In this example, head sampling will be used to process a smaller percentage of the overall ingested traces and spans. This is done by setting up the pipeline to ingest on the OpenTelemetry defined port as shown below using the OpenTelemetry Protocol (OTLP). The processor section defines traces for head sampling and the sampling percentage defining the total ingested traces and spans to be forwarded to the defined output plugins.

| Sampling settings     | Description                                                                                                         |
| :-------------------- | :------------------------------------------------------------------------------------------------------------------ |
| `sampling_percentage` | This sets the probability of sampling trace, can be between 0-100%. For example, 40 samples 40% of traces randomly. |

**fluent-bit.yaml**

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

With this head sampling configuration, a sample set of ingested traces will randomly send 40% of the total traces to the standard output.

## Tail sampling

Teal sampling is used to obtain a more selective and fine grained control over the collection of traces and spans without collecting everything. There are a few settings show here with their default values:

| Sampling settings | Description                                                                                                                | Default value |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `decision_wait`   | Specifies how long to buffer spans before making a sampling decision, allowing full trace evaluation.                      |      30s      |
| `max_traces`      | Specifies the maximum number of traces that can be held in memory. When the limit is reached, the oldest trace is deleted. |               |

The tail-based sampler supports various conditionals to sample traces if their spans meet a specific condition.

### Condition: status_code

This condition samples traces based on span status codes (`OK`, `ERROR`, `UNSET`).

| Condition settings | Description                                                                                                                                                                                                                              | Default value |
| :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `status_codes`     | Defines an array of span status codes (`OK`, `ERROR`, `UNSET`) to filter traces. Traces are sampled if any span matches a listed status code. For example, `status_codes: [ERROR, UNSET]` captures traces with errors or unset statuses. |               |

**fluent-bit.yaml**

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

With this tail-based sampling configuration, a sample set of ingested traces will select only the spans with status codes marked as `ERROR` to the standard output.

### Condition: latency

This condition samples traces based on span duration. It uses `threshold_ms_low` to capture short traces and `threshold_ms_high` for long traces.

| Condition settings  | Description                                                                                  | Default value |
| :------------------ | :------------------------------------------------------------------------------------------- | :-----------: |
| `threshold_ms_low`  | Specifies the lower latency threshold. Traces with a duration <= this value will be sampled. |       0       |
| `threshold_ms_high` | Specifies the upper latency threshold. Traces with a duration >= this value will be sampled. |       0       |

**fluent-bit.yaml**

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
            type: tail
            sampling_settings:
              decision_wait: 5s
            conditions:
              - type: latency
                  threshold_ms_high: 200
                  threshold_ms_high: 3000

  outputs:
    - name: stdout
      match: "*"
```

This tail-based sampling configuration waits 5 seconds before making a decision. It samples traces based on latency, capturing short traces of 200ms or less and long traces of 3000ms or more. Traces between 200ms and 3000ms are not sampled unless another condition applies.

### Condition: string_attribute

This conditional allows traces to be sampled based on specific span or resource attributes. Users can define key-value filters (e.g., http.method=POST) to selectively capture relevant traces.

| Condition settings | Description                                                                                                                                                                               | Default value |
| :----------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-----------: |
| `key`              | Specifies the span or resource attribute to match (e.g., "service.name").                                                                                                                 |               |
| `values`           | Defines an array of accepted values for the attribute. A trace is sampled if any span contains a matching key-value pair: `["payment-processing"]`                                        |               |
| `match_type`       | Defines how attributes are compared: `strict` ensures exact value matching, while `exists` checks if the attribute is present regardless of its value (note that string type is enforced) |   `strict`    |

**fluent-bit.yaml**

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
            type: tail
            sampling_settings:
              decision_wait: 2s
            conditions:
              - type: string_attribute
                match_type: strict
                key: "http.method"
                values: ["GET"]
              - type: string_attribute
                match_type: exists
                key: "service.name"

  outputs:
    - name: stdout
      match: "*"
```

This tail-based sampling configuration waits 2 seconds before making a decision. It samples traces based on string matching key value pairs. Traces are sampled if the key `http.method` is set to `GET` or they have a key `service.name`.

For more details about further processing, read the [Content Modifier](../processors/content-modifier.md) processor documentation.
