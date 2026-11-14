# Recipes

These recipes use complete policies and sample inputs. Run commands from the directory containing the named files, using a native Fluent Bit binary with Fluent Typed Scripting (FTS) enabled. All configurations use YAML because processors don't support classic configuration.

## Redact logs

This policy redacts selected structured keys, removes a free-form field, drops health checks, and adds OpenTelemetry context. Save it as `logs.lua`:

```lua
local fb = require("fluentbit")

function process(log)
    local path = log.body:get("path")
    if path and path:type() == "string" and path:value() == "/health" then
        return fb.DROP
    end

    fb.redact(log.body, {"authorization", "password", "access_token"})
    log.body:remove("debug_text")

    if fb.is_otel(log) then
        log.resource.attributes:set("deployment.environment.name", "production")
        log.attributes:set("sanitized", true)
        fb.set_severity(log, "info")
    end
end
```

Save this configuration as `logs.yaml`. The envelope runs before FTS so that the dummy log has OpenTelemetry context.

```yaml
service:
  flush: 1
  grace: 1

pipeline:
  inputs:
    - name: dummy
      tag: fts.logs
      samples: 1
      dummy: '{"event":"login","password":"example-secret","nested":{"Authorization":"Bearer example"},"debug_text":"password=example-secret"}'
      processors:
        logs:
          - name: opentelemetry_envelope
          - name: fts
            script: logs.lua
            error_mode: drop
  outputs:
    - name: stdout
      match: '*'
      format: otlp_json
```

Run:

```shell
fluent-bit -c logs.yaml
```

Expected output is an OTLP JSON log with this body content, redacted at both nesting levels:

```json
{"event":"login","password":"[REDACTED]","nested":{"Authorization":"[REDACTED]"}}
```

The sample uses `event` instead of `message` because the OTLP JSON encoder of the `stdout` output selects `log` or `message` as the body when present. With this sample, the full structured map appears in the OTLP body.

The enclosing OTLP data also contains resource attribute `deployment.environment.name=production`, log attribute `sanitized=true`, severity text `info`, and severity number `9`. `debug_text` is absent because the policy removes that field explicitly. Key redaction alone wouldn't remove its embedded secret. This policy doesn't inspect secrets inside `message` or other text fields; adapt it to your data before using it as a privacy policy. Stop the process with Ctrl+C.

## Normalize and aggregate metrics

This policy converts a duration gauge from milliseconds to seconds and combines data points after retaining only the `route` attribute. Save it as `metrics.lua`:

```lua
local fb = require("fluentbit")

function process(metric)
    if metric.name ~= "request.duration" or metric.type ~= "gauge" then
        return
    end

    metric.name = "request.duration.mean"
    fb.scale_metric(metric, 0.001, "s")
    fb.aggregate_metric(metric, {"route"}, "mean")
end
```

The mean is over data points with equal retained attributes and equal start/end timestamps in this family. It isn't weighted by request count and doesn't aggregate across callbacks. For counters, choose a sum policy with the appropriate temporality instead.

Save this configuration as `metrics.yaml`:

```yaml
service:
  flush: 1
  grace: 1

pipeline:
  inputs:
    - name: opentelemetry
      listen: 127.0.0.1
      port: 4318
      processors:
        metrics:
          - name: fts
            script: metrics.lua
            error_mode: drop
  outputs:
    - name: stdout
      match: '*'
      format: otlp_json
```

Save this OTLP JSON payload as `metrics.json`:

```json
{
  "resourceMetrics": [{
    "scopeMetrics": [{
      "metrics": [{
        "name": "request.duration",
        "unit": "ms",
        "gauge": {
          "dataPoints": [
            {
              "attributes": [
                {"key": "route", "value": {"stringValue": "/login"}},
                {"key": "instance", "value": {"stringValue": "a"}}
              ],
              "startTimeUnixNano": "1790812800000000000",
              "timeUnixNano": "1790812801000000000",
              "asDouble": 100
            },
            {
              "attributes": [
                {"key": "route", "value": {"stringValue": "/login"}},
                {"key": "instance", "value": {"stringValue": "b"}}
              ],
              "startTimeUnixNano": "1790812800000000000",
              "timeUnixNano": "1790812801000000000",
              "asDouble": 300
            }
          ]
        }
      }]
    }]
  }]
}
```

Start Fluent Bit:

```shell
fluent-bit -c metrics.yaml
```

In another terminal in the same directory, send the payload:

```shell
curl --fail-with-body -H 'Content-Type: application/json' \
  --data-binary @metrics.json http://127.0.0.1:4318/v1/metrics
```

After a flush, expect one family named `request.duration.mean`, unit `s`, with one gauge datapoint: attribute `route=/login` and `asDouble` approximately `0.2`. The `instance` attribute is absent. Both timestamps are preserved. Removing `instance` without aggregation would create a series collision and fail the policy. Stop Fluent Bit before starting the next recipe, which uses the same port.

## Transform spans

This policy normalizes a span name from the route, redacts structured attributes on spans, events, and links, and adds a resource attribute. It preserves the trace structure. Save it as `traces.lua`:

```lua
local fb = require("fluentbit")

function process(span)
    local route = span.attributes:get("http.route")
    if route and route:type() == "string" then
        span.name = "HTTP " .. route:value()
    end

    fb.redact(span.attributes, {"authorization", "password"})
    fb.redact(span.events, {"authorization", "password"})
    fb.redact(span.links, {"authorization", "password"})
    span.resource.attributes:set("deployment.environment.name", "production")
end
```

Save this configuration as `traces.yaml`:

```yaml
service:
  flush: 1
  grace: 1

pipeline:
  inputs:
    - name: opentelemetry
      listen: 127.0.0.1
      port: 4318
      processors:
        traces:
          - name: fts
            script: traces.lua
            error_mode: drop
  outputs:
    - name: stdout
      match: '*'
      format: otlp_json
```

Save this OTLP JSON payload as `traces.json`. IDs in OTLP JSON use hexadecimal text; inside FTS link maps they're typed bytes.

```json
{
  "resourceSpans": [{
    "scopeSpans": [{
      "spans": [{
        "traceId": "0102030405060708090a0b0c0d0e0f10",
        "spanId": "0102030405060708",
        "name": "GET /login?user=example",
        "kind": 2,
        "startTimeUnixNano": "1790812800000000000",
        "endTimeUnixNano": "1790812801000000000",
        "attributes": [
          {"key": "http.route", "value": {"stringValue": "/login"}},
          {"key": "authorization", "value": {"stringValue": "Bearer example"}}
        ],
        "events": [{
          "name": "authenticated",
          "timeUnixNano": "1790812800500000000",
          "attributes": [
            {"key": "password", "value": {"stringValue": "example-secret"}}
          ]
        }],
        "links": [{
          "traceId": "1112131415161718191a1b1c1d1e1f20",
          "spanId": "1112131415161718",
          "attributes": [
            {"key": "authorization", "value": {"stringValue": "Bearer example"}}
          ]
        }]
      }]
    }]
  }]
}
```

Start Fluent Bit:

```shell
fluent-bit -c traces.yaml
```

In another terminal, send the payload:

```shell
curl --fail-with-body -H 'Content-Type: application/json' \
  --data-binary @traces.json http://127.0.0.1:4318/v1/traces
```

After a flush, expect a span named `HTTP /login`. The authorization attribute on the span and link and the password attribute on the event contain `[REDACTED]`. The resource contains `deployment.environment.name=production`. Trace and span IDs, timestamps, event name, and link targets are preserved. Stop Fluent Bit with Ctrl+C.

The policy doesn't inspect event names or other free-form text. Dropping spans or changing IDs would require a separate decision about trace structure: FTS doesn't repair references in other spans. See [Traces](traces.md#trace-topology).
