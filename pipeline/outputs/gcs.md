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

1. Create a [Google Cloud service account](https://docs.cloud.google.com/iam/docs/service-accounts-create) for Fluent Bit and [create a JSON key](https://docs.cloud.google.com/iam/docs/keys-create-delete) for it.
1. [Create the bucket](https://docs.cloud.google.com/storage/docs/creating-buckets) that receives your data. Fluent Bit doesn't create buckets.
1. Grant the service account permission to write objects to that bucket. The plugin requests the `https://www.googleapis.com/auth/devstorage.read_write` `OAuth 2.0` scope.
1. Make the credentials available to Fluent Bit, either by setting the `google_service_credentials` option to the absolute path of the JSON key file, or by setting the `GOOGLE_SERVICE_CREDENTIALS` environment variable to that path.

The plugin uploads objects to `storage.googleapis.com` over TLS using the Cloud Storage JSON API.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `bucket` | Name of the Cloud Storage bucket that receives the objects. | _none_ |
| `canned_acl` | [Predefined ACL](https://docs.cloud.google.com/storage/docs/access-control/lists#predefined-acl) applied to uploaded objects. Accepted values: `authenticated-read`, `bucket-owner-full-control`, `bucket-owner-read`, `private`, `project-private`, and `public-read`. The camel case forms used by the Cloud Storage API, such as `publicRead`, are also accepted. | _none_ |
| `compression` | Compression applied to uploaded objects. Accepted values: `none`, `gzip`. | `none` |
| `content_type` | Value of the `Content-Type` metadata set on uploaded objects. | `application/json` |
| `gcs_key_format` | Format string for object names in the bucket. See [Object key format](#object-key-format). | `fluent-bit-logs/$TAG/%Y/%m/%d/%H/%M/%S` |
| `gcs_key_format_tag_delimiters` | Characters used to split the tag into the parts referenced by `$TAG[n]` in `gcs_key_format`. | `.` |
| `google_service_credentials` | Absolute path to a Google Cloud service account credentials JSON file. | Value of the environment variable `$GOOGLE_SERVICE_CREDENTIALS`. |
| `preserve_data_ordering` | When an upload request fails, the last received chunk might swap with a later chunk, resulting in data shuffling. This option prevents shuffling by using queue logic for uploads. | `false` |
| `send_content_md5` | Send the `Content-MD5` header with uploads so that Cloud Storage verifies object integrity. | `false` |
| `static_file_path` | Disables the behavior where a random suffix appends to the object name when `$UUID` isn't provided in `gcs_key_format`. | `false` |
| `store_chunk_limit` | Maximum number of buffered chunks kept in `store_dir`. Set to `0` for unlimited. | `0` |
| `store_dir` | Directory used to locally buffer data before uploading it. | `/tmp/fluent-bit/gcs` |
| `store_dir_limit_size` | Limits the amount of data buffered in `store_dir` to limit disk usage. When the limit is reached, data is discarded. Set to `0` for unlimited. | `0` |
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

## Buffering

This plugin buffers records as files in `store_dir` and uploads them when `upload_timeout` elapses, so it requires a writeable filesystem. Because the plugin has its own buffering system, the `storage.total_limit_size` parameter isn't meaningful. Use `store_dir_limit_size` and `store_chunk_limit` to limit disk usage instead.

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
