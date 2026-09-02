---
description: Send logs to Google Cloud Storage
---

# Google Cloud Storage

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Google Cloud Storage_ (`gcs`) output plugin lets you upload the records received through the input plugin to a [Google Cloud Storage](https://cloud.google.com/storage) bucket. Records are buffered locally and uploaded as objects when the configured upload timeout elapses.

This plugin is available in Fluent Bit version 5.1 and greater. It's included in official builds. If you compile Fluent Bit from source, the `FLB_OUT_GCS` build option is enabled by default.

## Google Cloud configuration

Before using the plugin, you must:

1. Identify or create a [Google Cloud service account](https://docs.cloud.google.com/iam/docs/service-accounts-create) for Fluent Bit. If you plan to authenticate with a credentials file, also [create a JSON key](https://docs.cloud.google.com/iam/docs/keys-create-delete) for that service account. A JSON key isn't required when you use metadata server authentication, because that mode uses the service account attached to the Compute Engine instance or Google Kubernetes Engine node and reads no credentials file.
1. [Create the bucket](https://docs.cloud.google.com/storage/docs/creating-buckets) that receives your data. Fluent Bit doesn't create buckets.
1. Grant the service account permission to write objects to that bucket. The plugin requests the `https://www.googleapis.com/auth/devstorage.read_write` `OAuth 2.0` scope.
1. Make the credentials available to Fluent Bit. See [Authentication](#authentication).

The plugin uploads objects to `storage.googleapis.com` over TLS using the Cloud Storage JSON API.

### Authentication

The plugin looks for service account credentials in the following order, and uses the first source it finds:

1. The `google_service_credentials` option, set to the absolute path of a service account JSON key file.
1. The `GOOGLE_APPLICATION_CREDENTIALS` environment variable, set to that path.
1. The `GOOGLE_SERVICE_CREDENTIALS` environment variable, set to that path. This variable is retained for backward compatibility. If both environment variables are set, the plugin uses `GOOGLE_APPLICATION_CREDENTIALS` and logs a warning.
1. The Compute Engine or Google Kubernetes Engine metadata server. When no credentials file is configured, the plugin requests an access token from the address set in `metadata_server`. Use this mode when Fluent Bit runs on a Compute Engine instance or a Google Kubernetes Engine node whose attached service account can write to the bucket.

The metadata server isn't a fallback for a failed credentials file. It's used only when no credentials file is configured through the option or either environment variable. If a credentials path is configured but the file can't be opened, read, or parsed as a service account key, the plugin logs an error such as `cannot open credentials file` or `invalid JSON credentials file` and fails to initialize. If you intend to use the metadata server, verify that the plugin logs `using GCE/GKE metadata server authentication` at startup.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `bucket` | Name of the Cloud Storage bucket that receives the objects. | _none_ |
| `canned_acl` | [Predefined ACL](https://docs.cloud.google.com/storage/docs/access-control/lists#predefined-acl) applied to uploaded objects. Accepted values: `authenticated-read`, `bucket-owner-full-control`, `bucket-owner-read`, `private`, `project-private`, and `public-read`. The camel case forms used by the Cloud Storage API, such as `publicRead`, are also accepted. | _none_ |
| `compression` | Compression applied to uploaded objects. Values aren't case-sensitive. When `format` is `json_lines`, accepted values are `none` and `gzip`. When `format` is `parquet`, this option selects the page-level codec inside the Parquet file and accepted values are `none`, `snappy`, `gzip`, and `zstd`. See [Parquet format](#parquet-format). | `none` |
| `content_type` | Value of the `Content-Type` metadata set on uploaded objects. | `application/json`, or `application/vnd.apache.parquet` when `format` is `parquet` |
| `format` | Output format for uploaded objects. Accepted values: `json_lines` and `parquet`. See [Parquet format](#parquet-format). Setting `json` logs a warning and is treated as `json_lines`. | `json_lines` |
| `gcs_key_format` | Format string for object names in the bucket. See [Object key format](#object-key-format). | `fluent-bit-logs/$TAG/%Y/%m/%d/%H/%M/%S` |
| `gcs_key_format_tag_delimiters` | Characters used to split the tag into the parts referenced by `$TAG[n]` in `gcs_key_format`. | `.` |
| `google_service_credentials` | Absolute path to a Google Cloud service account credentials JSON file. See [Authentication](#authentication). | _none_ |
| `metadata_server` | Address of the Compute Engine or Google Kubernetes Engine metadata server used to request an access token when no credentials file is configured. See [Authentication](#authentication). | `http://metadata.google.internal` |
| `preserve_data_ordering` | When an upload request fails, the last received chunk might swap with a later chunk, resulting in data shuffling. This option prevents shuffling by using queue logic for uploads. | `false` |
| `send_content_md5` | Send the `Content-MD5` header with uploads so that Cloud Storage verifies object integrity. | `false` |
| `static_file_path` | Disables the behavior where a random suffix appends to the object name when `$UUID` isn't provided in `gcs_key_format`. | `false` |
| `store_chunk_limit` | Maximum number of buffered chunks kept in `store_dir`. Set to `0` for unlimited. | `0` |
| `store_dir` | Directory used to locally buffer data before uploading it. | `/tmp/fluent-bit/gcs` |
| `store_dir_limit_size` | Limits the amount of data buffered in `store_dir` to limit disk usage. When the limit is reached, data is discarded. Set to `0` for unlimited. | `0` |
| `unify_tag` | Whether to buffer records from every tag into a single file instead of one file per tag. See [Unified tag buffering](#unified-tag-buffering). | `false` |
| `unify_tag_name` | Logical tag that replaces the record tag when `unify_tag` is enabled. It's stored as the buffer chunk metadata and used for `$TAG` in `gcs_key_format`. It doesn't set the name of the local buffer file. See [Unified tag buffering](#unified-tag-buffering). | `fluent-bit-buffer-file-unify-tag.log` |
| `upload_timeout` | When this amount of time elapses, Fluent Bit uploads the buffered data and starts a new object. Set to `60m` to upload a new object every hour. | `10m` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

## Object key format

The `gcs_key_format` option supports the same formatters as the [Amazon S3](s3.md#s3-key-format-and-tag-delimiters) output plugin:

- `$TAG`: The full tag.
- `$TAG[n]`: The nth part of the tag, with the index starting at zero. Tag parts are separated using the characters set in `gcs_key_format_tag_delimiters`.
- `$UUID`: A random string.
- `$INDEX`: An integer that increments with each upload. The value is stored in `store_dir` so it survives a restart.
- [strftime](https://man7.org/linux/man-pages/man3/strftime.3.html) formatters such as `%Y`, `%m`, and `%d`. The time used is the timestamp of the first record in the object.

When `gcs_key_format` doesn't contain `$UUID` and `static_file_path` is `false`, Fluent Bit appends a random suffix to each object name so that concurrent uploads don't overwrite each other. Set `static_file_path` to `true` to keep the object name exactly as the format string produces it.

## Parquet format

Setting `format` to `parquet` converts log records to Apache Parquet columnar format before uploading them. Parquet objects are directly queryable by BigQuery, Spark, and Presto without additional transformation.

The `compression` option controls the page-level `codec` applied inside the Parquet file:

| `compression` value | Parquet page `codec` | Notes |
| :--- | :--- | :--- |
| `snappy` | Snappy | Fast, moderate compression ratio. Commonly used with Parquet, but Fluent Bit defaults `compression` to `none`. |
| `zstd` | Zstandard | Better ratio, slightly slower. |
| `gzip` | Gzip | Best ratio, slowest. |
| `none` | Uncompressed | No page-level compression. |

Unless you set `content_type` explicitly, Parquet objects are uploaded with the `Content-Type` metadata `application/vnd.apache.parquet`.

{% hint style="info" %}

Parquet format requires Apache Arrow Parquet support at compile time. If Fluent Bit was built without it, setting `format` to `parquet` fails at startup with `parquet format requires parquet-glib at compile time`. See [Enable Parquet support](s3.md#enable-parquet-support) for build requirements.

{% endhint %}

### Example: Parquet with Snappy compression

```yaml
pipeline:
  outputs:
    - name: gcs
      match: '*'
      bucket: my-logs
      format: parquet
      compression: snappy
      gcs_key_format: /logs/dt=%Y-%m-%d/h=%H/$UUID.parquet
```

## Buffering

This plugin buffers records as files in `store_dir` and uploads them when `upload_timeout` elapses, so it requires a writeable filesystem. Because the plugin has its own buffering system, the `storage.total_limit_size` parameter isn't meaningful. Use `store_dir_limit_size` and `store_chunk_limit` to limit disk usage instead.

### Unified tag buffering

By default, each tag buffers into its own file, which is inefficient when a pipeline produces many small chunks under many tags, such as one tag per container. Set `unify_tag` to `true` to buffer records from every tag together under the single logical tag set by `unify_tag_name`. Fluent Bit generates local buffer file names internally, so `unify_tag_name` doesn't appear on disk.

When `unify_tag` is enabled, the value of `unify_tag_name` replaces the record tag for the rest of the upload path. As a result, `$TAG` and `$TAG[n]` in `gcs_key_format` resolve to `unify_tag_name` instead of the original tag. If your object names depend on the tag, remove those formatters from `gcs_key_format` before enabling this option.

## Get started

The following configuration buffers CPU metrics and uploads a gzip-compressed object to the `my-logs` bucket every five minutes:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: gcs
      match: '*'
      bucket: my-logs
      google_service_credentials: /path/to/credentials.json
      gcs_key_format: /fluent-bit/$TAG/%Y/%m/%d/%H_%M_%S/$UUID.gz
      compression: gzip
      upload_timeout: 5m
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu
  Tag   cpu

[OUTPUT]
  Name                        gcs
  Match                       *
  Bucket                      my-logs
  Google_Service_Credentials  /path/to/credentials.json
  Gcs_Key_Format              /fluent-bit/$TAG/%Y/%m/%d/%H_%M_%S/$UUID.gz
  Compression                 gzip
  Upload_Timeout              5m
```

{% endtab %}
{% endtabs %}
