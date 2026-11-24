---
description: Rehydrate logs from a Google Cloud Storage bucket
---

# Google Cloud Storage

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Google Cloud Storage_ (`gcs`) input plugin reads log objects from a [Google Cloud Storage](https://cloud.google.com/storage) bucket and turns them back into records, so you can rehydrate archived logs into your pipeline. For example, you can re-ship a day of logs to a different backend or reprocess them with new filters.

This plugin is the counterpart of the [Google Cloud Storage output plugin](../outputs/gcs.md). By default, it reads the objects that the output plugin writes. To archive logs to a bucket, refer to that page.

This plugin is available in Fluent Bit version 5.2 and greater. If you compile Fluent Bit from source, the `FLB_IN_GCS` build option is enabled by default, but the plugin requires a build with TLS support. When TLS support is disabled, the build system turns `FLB_IN_GCS` off.

## How it works

The plugin performs a one-shot rehydration. It doesn't poll for new objects. When Fluent Bit starts, the plugin does the following:

1. Lists the objects in the bucket that match `prefix`, `start_offset`, and `end_offset`, one page at a time. Cloud Storage returns object names in lexicographic order, and the plugin processes them in that order.
1. Downloads each object, one at a time, and decompresses it if needed.
1. Splits the object into lines and emits one record for each line.
1. Stops after the last object. The plugin doesn't list the bucket again, so objects uploaded afterward aren't read until you start Fluent Bit again.

Set `exit_on_complete` to `true` to also stop Fluent Bit when the plugin finishes. Otherwise, Fluent Bit keeps running and flushes remaining data to the outputs until you stop it.

The plugin skips entries whose name ends with `/`, because Cloud Storage tools use them as folder placeholders. It holds one object in memory at a time, and applies `max_object_size` to both the downloaded and the decompressed content.

This input always runs in its own [thread](../../administration/multithreading.md#inputs).

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `batch_size` | Maximum number of records to ingest on every collector cycle. The collector runs every 100 ms. Must be greater than `0`. | `1000` |
| `bucket` | Name of the Cloud Storage bucket to read objects from. Required. | _none_ |
| `compression` | Compression of the objects. Accepted values: `auto` (detect gzip from the object header), `gzip`, and `none`. Values aren't case-sensitive. See [Compression](#compression). | `auto` |
| `db` | Path to a SQLite database file that tracks the objects already processed, so they aren't ingested twice. Available only when Fluent Bit is built with SQLite support. See [State database](#state-database). | _none_ |
| `enable_identity_federation` | Authenticate with Workload Identity Federation instead of a service account key. Mutually exclusive with `google_service_credentials`. See [Workload Identity Federation](#workload-identity-federation). | `false` |
| `end_offset` | Only read objects whose name is lexicographically lower than this value. See [Select objects](#select-objects). | _none_ |
| `endpoint` | Cloud Storage API endpoint. Use `http://` only for tests and emulators. See [Use an emulator](#use-an-emulator). | `https://storage.googleapis.com` |
| `exit_on_complete` | Stop Fluent Bit after the plugin has processed all the objects. Exits with a non-zero status if the run fails or an object failed. | `false` |
| `google_service_account` | Email address of the service account to impersonate after the token exchange. When unset, the federated token is used directly against Cloud Storage. Only used when `enable_identity_federation` is `true`. See [Workload Identity Federation](#workload-identity-federation). | _none_ |
| `google_service_credentials` | Absolute path to a Google Cloud service account credentials JSON file. See [Authentication](#authentication). | _none_ |
| `identity_token_file` | Path to the file that holds the `OIDC` subject token used as the federation credential source. Required when `enable_identity_federation` is `true`. See [Workload Identity Federation](#workload-identity-federation). | _none_ |
| `max_object_size` | Maximum size of an object. The limit also applies to the uncompressed content. The plugin skips larger objects. See [Limits and error handling](#limits-and-error-handling). | `128M` |
| `metadata_server` | Address of the Compute Engine or Google Kubernetes Engine metadata server, used to request an access token when no credentials file is configured. See [Authentication](#authentication). | `http://metadata.google.internal` |
| `object_key` | When set, adds the name of the source object to every record under this key. | _none_ |
| `page_size` | Maximum number of objects to request on every page of the listing. Must be greater than `0`. | `1000` |
| `parser` | Name of a [parser](../parsers.md) to apply to every line. When unset, a line that is a JSON object becomes the record, and any other line becomes `{"log": line}`. See [Record format](#record-format). | _none_ |
| `pool_id` | Workload identity pool ID. Required when `enable_identity_federation` is `true`. See [Workload Identity Federation](#workload-identity-federation). | _none_ |
| `prefix` | Only read objects whose name starts with this prefix. See [Select objects](#select-objects). | _none_ |
| `project_number` | Number of the Google Cloud project that owns the workload identity pool. Required when `enable_identity_federation` is `true`. See [Workload Identity Federation](#workload-identity-federation). | _none_ |
| `provider_id` | Workload identity pool provider ID. Required when `enable_identity_federation` is `true`. See [Workload Identity Federation](#workload-identity-federation). | _none_ |
| `retry_limit` | Number of times to repeat a request after a temporary error (connection problems, `429`, and `5xx` responses) before giving up. Can't be negative. See [Limits and error handling](#limits-and-error-handling). | `3` |
| `start_offset` | Only read objects whose name is lexicographically greater than or equal to this value. See [Select objects](#select-objects). | _none_ |
| `subject_token_type` | `OIDC` subject token type presented to the Google Security Token Service. Only used when `enable_identity_federation` is `true`. See [Workload Identity Federation](#workload-identity-federation). | `urn:ietf:params:oauth:token-type:jwt` |
| `tag_regex` | Regular expression applied to the object name. Its first capture group becomes the tag of the records. If the expression doesn't match, the tag of the input is used. See [Tags](#tags). | _none_ |
| `time_format` | Format of the timestamp. Accepted values: `auto`, `iso8601`, `java_sql_timestamp`, `double`, `epoch`, and `epoch_ms`. See [Timestamps](#timestamps). | `auto` |
| `time_keep` | Keep the time key in the record after the plugin uses it as the timestamp. | `false` |
| `time_key` | Key of the record that holds its timestamp. Ignored when `parser` is set. Set to `false`, `off`, or `none` to disable timestamp extraction. See [Timestamps](#timestamps). | `date` |

This plugin also supports the common [networking](../../administration/networking.md) (`net.*`) and [TLS](../../administration/transport-security.md) (`tls.*`) settings, which apply to the connection to the Cloud Storage API. Because the default endpoint uses HTTPS, you don't need to set `tls` to `on`.

## Google Cloud configuration

Before using the plugin, you must:

1. Identify or create a [Google Cloud service account](https://docs.cloud.google.com/iam/docs/service-accounts-create) for Fluent Bit, unless you use Workload Identity Federation with direct resource access. If you plan to authenticate with a credentials file, also [create a JSON key](https://docs.cloud.google.com/iam/docs/keys-create-delete) for that service account. A JSON key isn't required when you use metadata server authentication, or Workload Identity Federation.
1. Grant the identity that Fluent Bit authenticates as permission to list and read objects in the bucket. The plugin needs the following permissions:
   - `storage.objects.list`, to list the objects.
   - `storage.objects.get`, to download them.

   The predefined [Storage Object Viewer](https://docs.cloud.google.com/storage/docs/access-control/iam-roles) role (`roles/storage.objectViewer`) includes both permissions. The plugin never writes to the bucket. For the scope that the plugin requests in each authentication mode, see [Authentication](#authentication).
1. Make the credentials available to Fluent Bit. See [Authentication](#authentication).

For credentials file, metadata server, and impersonated federation modes, the identity is the service account. For Workload Identity Federation with `google_service_account` unset, it's the federated principal itself, so grant that principal bucket access directly.

### Authentication

The plugin supports two authentication paths. Setting `enable_identity_federation` to `true` selects [Workload Identity Federation](#workload-identity-federation). Otherwise, the plugin uses a [service account key or the metadata server](#service-account-key-or-metadata-server).

#### Service account key or metadata server

The plugin looks for service account credentials in the following order, and uses the first source it finds:

1. The `google_service_credentials` option, set to the absolute path of a service account JSON key file.
1. The `GOOGLE_APPLICATION_CREDENTIALS` environment variable, set to that path.
1. The `GOOGLE_SERVICE_CREDENTIALS` environment variable, set to that path. This variable is retained for backward compatibility. If both environment variables are set, the plugin uses `GOOGLE_APPLICATION_CREDENTIALS` and logs a warning.
1. The Compute Engine or Google Kubernetes Engine metadata server. When no credentials file is configured, the plugin requests an access token from the address set in `metadata_server`. Use this mode when Fluent Bit runs on a Compute Engine instance or a Google Kubernetes Engine node whose attached service account can read the bucket.

The metadata server isn't a fallback for a failed credentials file. It's used only when no credentials file is configured through the option or either environment variable. If a credentials path is configured but the file can't be opened, read, or parsed as a service account key, the plugin logs an error such as `cannot open credentials file` or `invalid JSON credentials file` and fails to initialize. If you intend to use the metadata server, verify that the plugin logs `using GCE/GKE metadata server authentication` at startup.

#### Access scopes

The plugin never writes to the bucket in any authentication mode. The scope of the access token depends on the mode:

- **Service account key**: the plugin requests the read-only `https://www.googleapis.com/auth/devstorage.read_only` `OAuth 2.0` scope.
- **Workload Identity Federation**: the plugin requests the read-only scope in the `STS` token exchange when you use direct resource access, and in the `IAM` `generateAccessToken` call when you use impersonation.
- **Metadata server**: the plugin doesn't request a scope. The token carries the access scopes of the instance or node and the permissions of its attached service account. To keep the input read-only in this mode, attach a service account that only has read access to the bucket, for example Storage Object Viewer.

#### Workload Identity Federation

[Workload Identity Federation](https://docs.cloud.google.com/iam/docs/workload-identity-federation) lets Fluent Bit authenticate to Cloud Storage without a service account key. Use it when Fluent Bit runs outside Google Cloud, or on Google Kubernetes Engine where the workload receives a projected `OIDC` token. Set `enable_identity_federation` to `true` to select this mode.

When this mode is enabled, the plugin ignores the credentials file, both credentials environment variables, and the metadata server. Setting both `enable_identity_federation` and `google_service_credentials` fails at startup with `'google_service_credentials' and 'enable_identity_federation' are mutually exclusive`.

This mode requires the following options. If any of them is missing, the plugin logs `'<option>' is required when 'enable_identity_federation' is true` and fails to initialize:

- `project_number`: the number of the Google Cloud project that owns the workload identity pool.
- `pool_id`: the workload identity pool ID.
- `provider_id`: the workload identity pool provider ID.
- `identity_token_file`: the path to the file holding the `OIDC` subject token.

The plugin builds the `STS` audience from the first three of these values as `//iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID`. This string must match the audience configured on the pool provider.

The plugin re-reads `identity_token_file` on every token exchange, so platforms that rotate the token in place, such as a `kubelet` projected token, work without a restart.

The federated token can be used two ways:

- **Impersonation**: set `google_service_account` to the email address of a service account that can read the bucket. Grant the pool principal the `roles/iam.workloadIdentityUser` role on that service account.
- **Direct resource access**: leave `google_service_account` unset. The plugin uses the federated token directly against Cloud Storage, so the pool principal itself must have the permissions listed in [Google Cloud configuration](#google-cloud-configuration). The bucket must also have [uniform bucket-level access](https://docs.cloud.google.com/storage/docs/uniform-bucket-level-access) enabled.

For more details about this mode, refer to [Workload Identity Federation](../outputs/gcs.md#workload-identity-federation) in the Google Cloud Storage output plugin. The options and behavior are the same, except that the input requests the read-only scope. See [Access scopes](#access-scopes).

## Select objects

The plugin sends `prefix`, `start_offset`, and `end_offset` to Cloud Storage as filters on the object listing, so objects outside the selection are never downloaded.

- `prefix`: only objects whose name starts with this value.
- `start_offset`: only objects whose name is lexicographically greater than or equal to this value. The value is inclusive.
- `end_offset`: only objects whose name is lexicographically lower than this value. The value is exclusive.

You can combine the three options. If you set none of them, the plugin reads every object in the bucket.

By default, the output plugin names objects `fluent-bit-logs/$TAG/%Y/%m/%d/%H/%M/%S`, with a random suffix such as `-object1a2b3c4d` appended. Because the tag comes before the date, objects of the same tag are contiguous and sorted by time, so you can select a time window for one tag with offsets. For example, the following options select every object that the `app.log` tag wrote on 23 November 2026:

```text
prefix:       fluent-bit-logs/app.log/
start_offset: fluent-bit-logs/app.log/2026/11/23/
end_offset:   fluent-bit-logs/app.log/2026/11/24/
```

To select a time window across all tags with a single input, change `gcs_key_format` in the output plugin to put the date first, for example `fluent-bit-logs/%Y/%m/%d/%H/$TAG/$UUID`. Otherwise, add one input instance for each tag.

## Record format

The plugin splits each object on newline characters (`\n`). It removes a trailing carriage return (`\r`) from each line, skips empty lines, and emits the last line even when the object doesn't end with a newline. Each remaining line becomes one record:

- If a line is a complete JSON object, the plugin uses it as the record. This is the format that the output plugin writes by default (`json_lines`).
- Any other line, including JSON that isn't an object or an object followed by other text, becomes a record with the line as the value of the `log` key: `{"log": "<line>"}`.
- If you set `parser`, the plugin applies that [parser](../parsers.md) to every line instead. If the parser can't process a line, that line becomes a `{"log": "<line>"}` record.

If the plugin can't encode a line, it logs an error and retries the batch on the next cycle, up to `retry_limit` times. If it still fails, the object counts as failed, the plugin doesn't record it in the [state database](#state-database), and it continues with the next object. Records of that object that the plugin emitted in earlier batches stay in the pipeline.

Use `object_key` to add the name of the source object to each record. If the record already has a key with that name, the plugin replaces its value.

Objects in formats other than line-delimited text, such as Parquet files that the output plugin writes when `format` is `parquet`, aren't supported.

## Timestamps

By default, the plugin looks in each JSON record for the `date` key (`time_key`), uses its value as the record timestamp, and removes the key from the record. This matches what the output plugin writes by default: a `date` key with an ISO 8601 timestamp, such as `2026-11-23T10:15:30.123456Z`. Rehydrated records keep their original timestamps without extra configuration.

`time_format` controls how the plugin interprets the value:

| Value | Accepted input |
| :--- | :--- |
| `auto` | A string in ISO 8601 or Java SQL timestamp format, or a number. A number greater than `100000000000`, integer or with a fractional part, is read as milliseconds since the epoch. Any other number is read as seconds, and a floating-point number can have a fractional part. |
| `iso8601` | A string such as `2026-11-23T10:15:30Z`, `2026-11-23T10:15:30.123Z`, or `2026-11-23T10:15:30+02:00`. The fraction of a second and the time zone are optional. A value without a time zone is read as UTC. |
| `java_sql_timestamp` | A string such as `2026-11-23 10:15:30` or `2026-11-23 10:15:30.123`, read as UTC. |
| `double` | A number of seconds since the epoch. |
| `epoch` | A number of seconds since the epoch. |
| `epoch_ms` | A number of milliseconds since the epoch. |

Strings are accepted only by `auto`, `iso8601`, and `java_sql_timestamp`. Numbers are accepted only by `auto`, `double`, `epoch`, and `epoch_ms`. Negative numbers aren't valid timestamps.

Set `time_keep` to `true` to keep the time key in the record after using it. If the key is missing or its value can't be parsed, the plugin uses the time of ingestion as the timestamp and leaves the record unchanged. A value that Fluent Bit can't represent as an event time, for example seconds beyond the 32-bit range, is treated the same way: the plugin uses the time of ingestion and leaves the field in the record.

When you set `parser`, the plugin ignores `time_key` and `time_format`. It uses the timestamp that the parser extracts, and falls back to the time of ingestion when the parser doesn't extract one. Set `time_key` to `false`, `off`, or `none` to use the time of ingestion for every record.

## Tags

By default, all records have the tag of the input (`tag`). To restore the tags the records had when they were archived, use `tag_regex`. The plugin applies the regular expression to the object name and uses the first capture group as the tag of every record in that object. If the expression doesn't match the object name, or has no capture group that matched, the plugin uses the tag of the input.

With the default `gcs_key_format` of the output plugin (`fluent-bit-logs/$TAG/%Y/%m/%d/%H/%M/%S`), the following expression extracts the original tag from the object name:

```text
^fluent-bit-logs/([^/]+)/
```

For an object named `fluent-bit-logs/app.log/2026/11/23/10/15/30-object1a2b3c4d`, the tag is `app.log`. This expression assumes that the original tag doesn't contain a `/` character. If you changed `gcs_key_format`, adjust the expression to match your key layout.

Because the plugin tags records when it ingests them, an output with `match app.log` receives the rehydrated records the same way it received the original ones.

## Compression

The `compression` option controls how the plugin handles the downloaded content:

- `auto`: the plugin decompresses an object if its content starts with the gzip header. Otherwise, it reads the content as is. This is the default, and works for objects that the output plugin writes with `compression gzip`.
- `gzip`: the plugin always decompresses the content as gzip. An object that isn't valid gzip data is skipped.
- `none`: the plugin never decompresses the content.

The plugin applies `max_object_size` to the decompressed content too. If decompression produces more data than the limit, the plugin skips the object.

## State database

Set `db` to the path of a SQLite file to make the plugin remember which objects it already processed. For each object that the plugin finishes emitting, it records the bucket, the object name, and the object generation in the `in_gcs_objects` table. On later runs, the plugin skips any object already recorded, so you can start the same rehydration again and only unprocessed objects are read.

Because the key includes the generation, an object that someone overwrites in the bucket has a new generation and is read again.

The plugin records an object only after it hands all of its records to the Fluent Bit engine. If Fluent Bit stops or restarts in the middle of an object, the plugin reads that object again in full on the next run, so your destination might receive duplicates of the records from that one object.

The database doesn't protect records that the engine has buffered but not yet delivered. If the process is killed or crashes, those records can be lost, as with other inputs, and because the plugin already recorded the object, it doesn't read the object again. [Filesystem buffering](../buffering.md#filesystem-buffering-hybrid) reduces this exposure but doesn't remove it, because this input hands records to the engine from its own thread.

Without `db`, the plugin doesn't keep any state, and every run reads all the selected objects again.

## Limits and error handling

The plugin processes one object at a time, doing a bounded amount of work on every collector cycle.

| Condition | Behavior |
| :--- | :--- |
| Object larger than `max_object_size` | The plugin logs an error and skips the object. It checks the size reported by the listing, the size of the downloaded content, and the size after decompression. |
| `batch_size` | The plugin appends up to `batch_size` records to the pipeline on every cycle. Lower this value to reduce memory pressure on the pipeline, or raise it to speed up rehydration. When the input is paused because of backpressure, the plugin resumes from the same line. |
| `401` (unauthorized) | The plugin invalidates the cached access token, requests a new one, and repeats the request once. This retry doesn't count against `retry_limit`. If the request fails with `401` again, the run fails. |
| `403` (forbidden) | The run fails. Check the IAM permissions described in [Google Cloud configuration](#google-cloud-configuration). |
| `404` (not found) while downloading | The plugin logs a warning and skips the object, for example when someone deleted it after the listing. The run continues. |
| `429`, `5xx`, connection errors, or no access token | The plugin repeats the request, up to `retry_limit` times. If all attempts fail, the plugin skips the object when downloading, or fails the run when listing. |
| Any other failure while downloading, including a corrupt gzip object | The plugin logs an error and skips the object. The run continues. |
| Record encoding failure | The plugin retries the batch on the next cycle, up to `retry_limit` times. If it still fails, the object counts as failed and the plugin doesn't record it in the state database. The plugin continues with the next object. |
| Any failure while listing | The run fails, after the retries described for `429` and `5xx`. A `404` while listing, for example when the bucket doesn't exist, also fails the run. |

`retry_limit` counts retries after the first attempt. With the default value of `3`, the plugin makes up to four attempts for a request: the first one and three retries. Retries run on the next collector cycle, without an additional backoff delay. Set `retry_limit` to `0` to disable retries.

When the run fails, the plugin logs the error, stops processing, and doesn't process any remaining objects. If `exit_on_complete` is `true`, Fluent Bit also exits, with a non-zero status. It also exits with a non-zero status when the run completes but at least one object failed. Objects skipped because they no longer exist (`404`) don't count as failures. A skipped object isn't recorded in the [state database](#state-database), so a later run tries it again.

When the plugin finishes, successfully or not, it logs a summary with the number of objects processed, skipped, and failed, and the number of records emitted.

## Use an emulator

Set `endpoint` to point the plugin at a Cloud Storage emulator or a compatible server instead of `storage.googleapis.com`. The value must start with `http://` or `https://`, and can include a port and a base path. Use `http://` only for tests and emulators, because requests sent over plain HTTP aren't encrypted.

The plugin still requests an access token, so also set `metadata_server` to an address that returns one, or configure credentials your emulator accepts.

## Get started

The following examples use the object layout that the [output plugin](../outputs/gcs.md) writes by default. Replace `my-logs` with the name of your bucket.

### Rehydrate a day of logs and exit

The following configuration reads the objects that the `app.log` tag wrote on 23 November 2026, prints the records on the console, and exits when it finishes:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: gcs
      tag: rehydrated
      bucket: my-logs
      google_service_credentials: /path/to/credentials.json
      prefix: fluent-bit-logs/app.log/
      start_offset: fluent-bit-logs/app.log/2026/11/23/
      end_offset: fluent-bit-logs/app.log/2026/11/24/
      exit_on_complete: true

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush      1
  Log_Level  info

[INPUT]
  Name                        gcs
  Tag                         rehydrated
  Bucket                      my-logs
  Google_Service_Credentials  /path/to/credentials.json
  Prefix                      fluent-bit-logs/app.log/
  Start_Offset                fluent-bit-logs/app.log/2026/11/23/
  End_Offset                  fluent-bit-logs/app.log/2026/11/24/
  Exit_On_Complete            true

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

### Rehydrate with the original tags and re-ship

The following configuration restores the original tag of every record from the object name, adds the object name to each record, and forwards the records to another Fluent Bit or Fluentd instance. The input falls back to the `gcs` tag for objects whose name doesn't match `tag_regex`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: gcs
      tag: gcs
      bucket: my-logs
      google_service_credentials: /path/to/credentials.json
      prefix: fluent-bit-logs/
      tag_regex: '^fluent-bit-logs/([^/]+)/'
      object_key: gcs_object
      exit_on_complete: true

  outputs:
    - name: forward
      match: '*'
      host: aggregator.example.com
      port: 24224
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name                        gcs
  Tag                         gcs
  Bucket                      my-logs
  Google_Service_Credentials  /path/to/credentials.json
  Prefix                      fluent-bit-logs/
  Tag_Regex                   ^fluent-bit-logs/([^/]+)/
  Object_Key                  gcs_object
  Exit_On_Complete            true

[OUTPUT]
  Name   forward
  Match  *
  Host   aggregator.example.com
  Port   24224
```

{% endtab %}
{% endtabs %}

### Resume a rehydration with a state database

The following configuration rehydrates a whole prefix of a large bucket, using the metadata server of the Compute Engine instance for authentication and a state database to skip the objects it already processed. If Fluent Bit stops before it finishes, start it again with the same configuration to continue where it left off.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: gcs
      tag: rehydrated
      bucket: my-logs
      prefix: fluent-bit-logs/
      db: /var/lib/fluent-bit/gcs.db
      batch_size: 500
      max_object_size: 64M
      exit_on_complete: true

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name              gcs
  Tag               rehydrated
  Bucket            my-logs
  Prefix            fluent-bit-logs/
  DB                /var/lib/fluent-bit/gcs.db
  Batch_Size        500
  Max_Object_Size   64M
  Exit_On_Complete  true

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}
