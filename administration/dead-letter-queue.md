# Dead letter queue

The dead letter queue preserves [chunks](../pipeline/buffering.md#chunks) that Fluent Bit fails to deliver to output destinations. Instead of losing this data, Fluent Bit copies the rejected chunks to a dedicated storage location for future analysis and troubleshooting.

To enable the dead letter queue, filesystem storage must be enabled by setting a value for [`storage.path`](.//configuring-fluent-bit/yaml/service-section.md#storage-configuration), and [`storage.keep.rejected`](.//configuring-fluent-bit/yaml/service-section.md#storage-configuration) must be set to `on`.

Chunks are copied to the dead letter queue in the following failure scenarios:

- **Permanent errors**: When an output plugin returns an unrecoverable error (`FLB_ERROR`).
- **Retry limit reached**: When a chunk exhausts all configured retry attempts.
- **Retries disabled**: When `retry_limit` is set to `no_retries` and a flush fails.
- **Scheduler failures**: When the retry scheduler can't schedule a retry (for example, due to resource constraints).

## Location

Rejected chunks are stored in the subdirectory defined by `storage.path`. For example, with the following configuration, rejected chunks are stored at `/var/log/flb-storage/rejected/`:

```yaml
service:
  storage.path: /var/log/flb-storage/
  storage.keep.rejected: on
  storage.rejected.path: rejected
```

## Format

Each dead letter queue file is named using this format:

```text
<sanitized_tag>_<status_code>_<output_name>_<unique_id>.flb
```

For example: `kube_var_log_containers_test_400_http_0x7f8b4c.flb`

The file contains the original chunk data in the internal format of Fluent Bit, preserving all records and metadata.

## Troubleshooting with dead letter queue

The dead letter queue feature enables the following capabilities:

- **Data preservation**: Invalid or rejected chunks are preserved instead of being permanently lost.
- **Root cause analysis**: Investigate why specific data failed to be delivered without impacting live processing.
- **Data recovery**: Replay or transform rejected chunks after fixing the underlying issue.
- **Debugging**: Analyze the exact content of problematic records.

To examine dead letter queue chunks, you can use the storage metrics endpoint (when `storage.metrics` is enabled) or directly inspect the files in the rejected directory.

{% hint style="info" %}
Dead letter queue files remain on disk until manually removed. Monitor disk usage in the rejected directory and implement a cleanup policy for older files.
{% endhint %}

A Service section will look like this:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info
  storage.path: /var/log/flb-storage/
  storage.sync: normal
  storage.checksum: off
  storage.backlog.mem_limit: 5M
  storage.backlog.flush_on_shutdown: off
  storage.keep.rejected: on
  storage.rejected.path: rejected
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush                     1
  log_Level                 info
  storage.path              /var/log/flb-storage/
  storage.sync              normal
  storage.checksum          off
  storage.backlog.mem_limit 5M
  storage.backlog.flush_on_shutdown off
  storage.keep.rejected     on
  storage.rejected.path     rejected
```

{% endtab %}
{% endtabs %}

This configuration sets an optional buffering mechanism where the route to the data is `/var/log/flb-storage/`. It uses `normal` synchronization mode, without running a checksum and up to a maximum of 5 MB of memory when processing backlog data. Additionally, the dead letter queue is enabled, and rejected chunks are stored in `/var/log/flb-storage/rejected/`.
