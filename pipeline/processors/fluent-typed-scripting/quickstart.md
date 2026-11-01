# Quickstart

This example uses the `dummy` input to generate one log. Fluent Typed Scripting (FTS) redacts a password and adds an environment field. You need a native Fluent Bit build containing FTS; see [Availability](../fluent-typed-scripting.md#availability).

## Create the policy

In an empty directory, save this script as `policy.lua`:

```lua
local fb = require("fluentbit")

function process(log)
    fb.redact(log.body, {"password"})
    log.body:set("environment", "production")
end
```

## Configure the pipeline

Save the following as `fluent-bit.yaml` in the same directory. The `dummy` value is the input record. `samples: 1` generates it once.

```yaml
service:
  flush: 1
  grace: 1

pipeline:
  inputs:
    - name: dummy
      tag: fts.quickstart
      samples: 1
      dummy: '{"message":"login","password":"example-secret"}'
      processors:
        logs:
          - name: fts
            script: policy.lua
  outputs:
    - name: stdout
      match: '*'
      format: json_lines
      json_date_key: false
```

Processors require YAML; there is no classic configuration equivalent. Run from the directory containing both files:

```shell
fluent-bit -c fluent-bit.yaml
```

After the next flush, standard output contains the following JSON body. Field order can differ, and Fluent Bit also prints startup messages.

```json
{"message":"login","password":"[REDACTED]","environment":"production"}
```

Stop Fluent Bit with Ctrl+C. The process continues running after the single sample is emitted.

If startup reports that `fts` isn't registered, check the build options in [Availability](../fluent-typed-scripting.md#availability). If the script can't be loaded, check the path and run directory. If no record appears, inspect policy errors: `error_mode` defaults to `drop`.

## Change the transformation

To remove a record, return `fb.DROP`. To commit edits, return nothing or `fb.KEEP`. For example, add this at the beginning of `process` to discard health checks:

```lua
if log.body:get_string("path") == "/health" then
    return fb.DROP
end
```

A missing `path` returns `nil`; a present value of a different type raises an error. See [Typed values](typed-values.md) and [Errors and limits](errors-and-limits.md) before applying a policy to mixed input.

Key-based redaction doesn't inspect free-form strings. A password inside the `message` text requires an explicit string policy. Continue with the complete [log redaction recipe](recipes.md#redact-logs).
