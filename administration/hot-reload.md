---
description: Enable hot reload through SIGHUP signal or an HTTP endpoint
---

# Hot reload

Fluent Bit supports the reloading feature when enabled in the configuration file or on the command line with `-Y` or `--enable-hot-reload` option.

Hot reloading is supported on Linux, macOS, and Windows operating systems.

## Update the configuration

To get started with reloading over HTTP, enable the HTTP Server in the configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  http_server: on
  http_listen: 0.0.0.0
  http_port: 2020
  hot_reload: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  HTTP_Server  On
  HTTP_Listen  0.0.0.0
  HTTP_PORT    2020
  Hot_Reload   On
```

{% endtab %}
{% endtabs %}

## Relative paths

A configuration file can reference other files with a relative path, including `parsers_file`, `plugins_file`, upstream high availability files, the stream processor `streams_file`, the Lua filter `script`, and the WASM filter `wasm_path`. Classic `@INCLUDE` files follow the same order; see [Config include file](configuring-fluent-bit/classic-mode/configuration-file.md#config-include-file). A relative wildcard `@INCLUDE` pattern is the exception: it's matched only in the directory of the main configuration file, with no fallback to the working directory. If matching files exist only in the working directory, Fluent Bit fails to load the configuration.

In v5.2 or later, Fluent Bit resolves a relative reference in two steps. It first looks for the file in the directory that holds the main configuration file. If no file exists there, it looks for the file at the path exactly as written, relative to the working directory of the Fluent Bit process. An absolute path is used as provided and isn't retried. If Fluent Bit starts without a configuration file, it uses the working directory.

Earlier versions checked the working directory first, and looked up WASM programs only relative to the working directory. In most setups, the new order matters only when a file with the same name exists in both directories: Fluent Bit now uses the file next to the main configuration file. If that path exists but can't be accessed, for example because of its permissions, Fluent Bit doesn't fall back to the working directory and fails to load the file.

Fluent Bit version 5.1.2 and greater keeps track of the main configuration file's directory across a hot reload. In earlier versions, the reloaded configuration lost that directory, so a relative reference that resolved at startup failed to resolve after a reload. On those versions, use absolute paths for referenced files if you rely on hot reload.

If Fluent Bit can't preserve the directory while reloading, it stops the reload, keeps the previous configuration running, and logs:

```text
[reload] copying configuration path failed. Reloading is halted
```

## Processor validation

Fluent Bit version 5.2 and greater validates the processors attached to every input and output before it replaces the running pipeline. If this validation fails, Fluent Bit stops the reload, keeps the previous configuration running, and logs:

```text
[reload] processor configuration preflight failed
[reload] reloaded config is invalid. Reloading is halted
```

Validation checks the property names and values of every processor, including [filters used as processors](../pipeline/processors/filters.md). Deeper checks run only for processors that support them: the `fts` processor, and the Lua and Wasm filters used as processors, unless the filter sets `active: false`.

Validation doesn't catch every error. Errors that only appear when a processor starts, such as an invalid regular expression in a `content_modifier` processor, are found after Fluent Bit has stopped the previous pipeline. In that case, the reload is aborted and Fluent Bit exits instead of keeping the previous configuration. Test configuration changes in a test environment before you reload a production instance. The `--dry-run` option runs the same validation, so it doesn't catch these errors either.

## How to reload

After updating the configuration, use one of the following methods to perform a hot reload:

### HTTP

Use the following HTTP endpoints to perform a hot reload:

- `PUT /api/v2/reload`
- `POST /api/v2/reload`

For using curl to reload Fluent Bit, users must specify an empty request body as:

```shell
curl -X POST -d '{}' localhost:2020/api/v2/reload
```

Obtain a count of hot reload using the HTTP endpoint:

- `GET /api/v2/reload`

The endpoint returns `hot_reload_count` as follows:

```json
{"hot_reload_count":3}
```

The default value of the counter is `0`.

### Signal

Hot reloading can be used with `SIGHUP`.

`SIGHUP` signal isn't supported on Windows.

## Confirm a reload

Use one of the following methods to confirm the reload occurred.
