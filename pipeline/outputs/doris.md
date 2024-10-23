---
description: Send logs to Apache Doris
---

# Apache Doris

The **doris** output plugin lets you ingest your records into an
[Apache Doris](https://doris.apache.org) database. To use this plugin, you must have an
operational Doris service running in your environment.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `host` | HTTP address of the target Doris fe or be | `127.0.0.1` |
| `port` | HTTP port of the target Doris fe or be | `8300` |
| `user` | Username for Doris access | _none_ |
| `password` | Password for Doris access | _none_ |
| `database` | The target Doris database | _none_ |
| `table` | The target Doris table | _none_ |
| `time_key` | The name of the time key in the output record | `date` |
| `columns` | The column mappings, details in [Doris stream load](https://doris.apache.org/docs/data-operate/import/import-way/stream-load-manual) | `date, log` |
| `timeout_second` | Timeout seconds for Doris stream load | `60` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

### TLS / SSL

Doris output plugin supports TLS/SSL. For more details about the properties
available and general configuration, refer to[TLS/SSL](../../administration/transport-security.md).

