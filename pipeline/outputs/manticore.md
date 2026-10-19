---
description: Send logs to Manticore Search
---

# Manticore Search

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Manticore Search_ (`manticore`) output plugin lets you ingest your records into a [Manticore Search](https://manticoresearch.com) table. To use this plugin, you must have an operational Manticore Search service running in your environment, and the target table must exist.

The plugin sends records to the Manticore HTTP `/bulk` endpoint as newline-delimited JSON (NDJSON), in one of two modes:

- `Regular`, the default, writes every flush to the table as one `/bulk` request.
- `Shared` loads a finite source, such as a file read to its end, into one table with the Manticore `bulk_import` feature, and publishes the whole load once when Fluent Bit stops. See [Shared mode](#shared-mode).

If you compile Fluent Bit from source, the `FLB_OUT_MANTICORE` build option is enabled by default.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `action` | `Regular` mode: the `/bulk` operation for each record, `insert` or `create`. `Shared` mode ignores it. | `insert` |
| `buffer_size` | Specify the buffer size used to read the response from the Manticore HTTP service. | `64K` |
| `host` | IP address or hostname of the target Manticore Search instance. | `127.0.0.1` |
| `http_passwd` | Password for user defined in `http_user`. | _empty_ |
| `http_user` | Optional username for HTTP Basic authentication. | _none_ |
| `mode` | `Regular` or `Shared`. The value is case-insensitive. | `Regular` |
| `port` | TCP port of the target Manticore Search HTTP listener. | `9308` |
| `shared_indexers` | `Shared` mode: the number of indexers the daemon starts for the load. `0` lets the daemon choose. | `0` |
| `table` | Required. Name of an existing Manticore Search table. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

### TLS / SSL

The Manticore Search output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

### Record IDs

Fluent Bit sends the body of each record unchanged, without the Fluent Bit timestamp or metadata. To keep the timestamp, add it to the record body, for example with the [Lua](../filters/lua.md) filter. Manticore takes the `id` field of the record as the document ID, converted as in a regular `INSERT`, and generates an ID for a record without one or with an ID that converts to `0`. A record without an ID gets a new ID each time it's delivered, so a record that Fluent Bit delivers again, for example on a retry, is added again. To use another field as the ID, rename it to `id` with the [Modify](../filters/modify.md) filter.

A record must be a map with string keys. Fluent Bit converts the whole flush before sending it, so a record that isn't a map drops the whole flush, without a retry, and none of its records is sent.

### Bulk retries

In `Regular` mode, Fluent Bit sends each flush as one `/bulk` request, with one operation for each record:

```json
{"insert":{"table":"logs","doc":{"id":42,"message":"hello","status":200}}}
```

Manticore runs the request as one transaction and stops at its first failing record, so the result applies to the whole flush:

| Reply | Result |
| --- | --- |
| HTTP `2xx` with `"errors":false` | Success. |
| Connection or transport failure, HTTP `408` or `429`, an item status of `408`, `429` or `5xx`, or an HTTP `5xx` reply without item statuses | Fluent Bit retries the flush. |
| Any other reply, including a permanent item status inside an HTTP `5xx` reply | Fluent Bit drops the flush. |

To keep the dropped chunks, use the [dead letter queue](../../administration/dead-letter-queue.md).

## Shared mode

`Shared` mode loads one finite source into one table with the Manticore `bulk_import` feature. Data requests stage the records, and when Fluent Bit stops, the plugin sends one Finish request that publishes the load. Use it for a source that ends, such as a [Tail](../inputs/tail.md) input with `exit_on_eof` enabled.

{% hint style="info" %}
`Shared` mode needs a Manticore version with shared `bulk_import`, available in the 29.15.0 development packages and later, and a Fluent Bit build with output delivery metrics, which official builds include.
{% endhint %}

Data requests go to `/bulk?bulk_import=<table>&shared`, or `&shared=<n>` when `shared_indexers` is a positive `<n>`, and carry the records unchanged:

```json
{"id":42,"message":"hello","status":200}
```

After the first successful data request, the next requests add `&shared_join` to the URI and only join the open load. If the daemon lost the load to a restart or a cancel, the load fails instead of starting a new load with only the later records.

The plugin sends the Finish only if all of the following are true: at least one data request succeeded, no data request failed permanently, and Fluent Bit kept no pending task or chunk. No record can have been dropped, and no chunk can have used up its retries. A request that fails and then succeeds on a retry doesn't block the Finish. The Fluent Bit exit code doesn't report the result: the plugin logs `shared bulk_import complete: table=<table>` or `shared bulk_import failed: table=<table>`.

If no data request succeeded, for example because the source was empty, the plugin sends no Finish but still logs `complete`. The `complete` line alone doesn't show that records were published, so check the table.

A failed load stays unpublished, and the log names the statement that cancels its staged data:

```sql
PURGE BULK_IMPORT FROM TABLE logs OPTION clear_sessions=1;
```

A lost or malformed reply to the Finish leaves the result unknown. In that case the plugin also logs `failed`, but the log doesn't name the `PURGE` statement and tells you to coordinate recovery before replay. Check the table before you load the source again.

`shared_indexers` sets how many indexers the daemon starts for the load, and so how many disk chunks the load adds to the table. The indexers run on the Manticore host and don't depend on `workers`. `0` lets the daemon choose.

Every `Shared` output sends its own Finish, so only one `Shared` output can load a table at a time. Several outputs that load one table leave the result undefined. To load several inputs into one table, route them to one output with `match`.

## Get started

To insert records into a Manticore Search table, create the table, for example with `CREATE TABLE logs (message TEXT, status INTEGER)`, then run the plugin from the command line or through the configuration file.

### Command line

The `manticore` plugin can read the parameters from the command line through the `-p` argument (property):

```shell
fluent-bit -i dummy -p 'dummy={"message": "hello", "status": 200}' \
    -o manticore -p host=127.0.0.1 -p port=9308 -p table=logs -m '*'
```

### Configuration file

In your main configuration file append the following sections.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: app.logs
      dummy: '{"message": "hello from Fluent Bit", "status": 200}'

  outputs:
    - name: manticore
      match: '*'
      host: 127.0.0.1
      port: 9308
      table: logs
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name   dummy
  Tag    app.logs
  Dummy  {"message": "hello from Fluent Bit", "status": 200}

[OUTPUT]
  Name   manticore
  Match  *
  Host   127.0.0.1
  Port   9308
  Table  logs
```

{% endtab %}
{% endtabs %}

### Load a file with Shared mode

The following example loads a JSON lines file into the table, and publishes it when Fluent Bit reaches the end of the file. The `json` parser comes from a parsers file, such as the `parsers.conf` file that ships with Fluent Bit, loaded with `parsers_file` in the `service` section.

At the end of the file, Fluent Bit waits at most [`grace`](../../administration/configuring-fluent-bit/yaml/service-section.md) seconds, `5` by default, for the records it still has to send, and stops as soon as they're sent. Records still pending after that leave the load unpublished, so set `grace` generously: a long grace doesn't slow down a load that ends earlier.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  grace: 300

pipeline:
  inputs:
    - name: tail
      path: /data/import.json
      read_from_head: true
      exit_on_eof: true
      parser: json

  outputs:
    - name: manticore
      match: '*'
      host: 127.0.0.1
      port: 9308
      table: logs
      mode: Shared
      shared_indexers: 4
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Grace  300

[INPUT]
  Name            tail
  Path            /data/import.json
  Read_From_Head  On
  Exit_On_Eof     On
  Parser          json

[OUTPUT]
  Name             manticore
  Match            *
  Host             127.0.0.1
  Port             9308
  Table            logs
  Mode             Shared
  Shared_Indexers  4
```

{% endtab %}
{% endtabs %}
