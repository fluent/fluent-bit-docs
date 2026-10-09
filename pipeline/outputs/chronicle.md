# Google Chronicle

The _Google Chronicle_ output plugin lets you ingest security logs into the [Google Chronicle](https://cloud.google.com/security/products/security-operations) service. This connector is designed to send unstructured security logs.

The plugin can send logs through two Google Chronicle APIs. Use the `api` parameter to select one:

- `legacy`: The legacy [Ingestion API](https://docs.cloud.google.com/chronicle/docs/reference/ingestion-api). This is the default.
- `chronicle`: The [Chronicle API](https://docs.cloud.google.com/chronicle/docs/reference/rest). See [Chronicle API](#chronicle-api).

{% hint style="warning" %}
Google is deprecating the legacy Ingestion API. Instances provisioned on or after October 26, 2026 can't use it, and it shuts down on July 20, 2027. To keep sending logs, set `api` to `chronicle`. For more information, see [Migrate from legacy SIEM API to Chronicle API](https://docs.cloud.google.com/chronicle/docs/administration/migrate-from-legacy-api-to-chronicle-api).
{% endhint %}

## Google Cloud configuration

Fluent Bit streams data into an existing Google Chronicle tenant using a service account that you specify. Before using the Chronicle output plugin, you must:

1. Create a service account.

   To stream security logs into Google Chronicle, create a [Google Cloud service account](https://docs.cloud.google.com/iam/docs/service-accounts-create) for Fluent Bit:

1. Create a tenant of Google Chronicle.

   Fluent Bit doesn't create a tenant of Google Chronicle for your security logs, so you must create this ahead of time.

1. Retrieve service account credentials.

   The Fluent Bit Chronicle output plugin uses a JSON credentials file for authentication credentials. Download the credentials file by following the instructions for [Creating and Managing Service Account Keys](https://docs.cloud.google.com/iam/docs/keys-create-delete).

1. Grant permissions for the Chronicle API.

   If you set `api` to `chronicle`, grant the service account a role that includes the `chronicle.logs.import` permission in the Google Cloud project linked to your Google Chronicle tenant.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `api` | The Google Chronicle API to send logs to. Supported values: `legacy` for the deprecated Ingestion API, and `chronicle` for the [Chronicle API](#chronicle-api). | `legacy` |
| `customer_id` | The customer ID identifying the Google Chronicle tenant to stream into. With the Chronicle API, this is the instance ID of the tenant. | _none_ |
| `google_service_credentials` | Absolute path to a Google Cloud credentials JSON file. | Value of the environment variable `$GOOGLE_SERVICE_CREDENTIALS` |
| `label` | Add a Chronicle label as a key and value pair. You can set this option multiple times. The label value can be a static string or a [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md). With the Chronicle API, each label key must be unique. | _none_ |
| `log_key` | By default, the whole log record is sent to Google Chronicle. If you specify a key name with this option, only the value of that key is sent. | _none_ |
| `log_type` | The log type to parse logs as. Google Chronicle supports parsing for [specific log types only](https://docs.cloud.google.com/chronicle/docs/ingestion/parser-list/supported-default-parsers). | _none_ |
| `namespace` | Set the Chronicle namespace for uploaded logs. If `namespace_key` is also set, this value is used when the record accessor doesn't resolve or resolves to an empty value. | _none_ |
| `namespace_key` | Record accessor that selects the Chronicle namespace from each record. When records in the same chunk resolve to different namespaces or labels, Fluent Bit sends them in separate Chronicle batches. | _none_ |
| `project_id` | The project ID containing the Google Chronicle tenant to stream into. With the Chronicle API, this is the Google Cloud project linked to the tenant. | Value of the `project_id` in the credentials file |
| `region` | The GCP region in which to store security logs. With the legacy API, supported regions are `US`, `EU`, `UK`, and `ASIA`, and blank is treated as `US`. With the Chronicle API, use the location of the tenant, such as `us`, `europe`, or `europe-west2`, and blank is treated as `us`. | _none_ |
| `service_account_email` | Account email associated with the service. Only available if no credentials file has been provided. | Value of the environment variable `$SERVICE_ACCOUNT_EMAIL` |
| `service_account_secret` | Private key content associated with the service account. Only available if no credentials file has been provided. | Value of the environment variable `$SERVICE_ACCOUNT_SECRET` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

See Google's [official documentation](https://docs.cloud.google.com/chronicle/docs/reference/ingestion-api) for further details.

## Chronicle API

When `api` is set to `chronicle`, Fluent Bit sends logs to the [`logs.import`](https://docs.cloud.google.com/chronicle/docs/reference/rest/v1/projects.locations.instances.logTypes.logs/import) method of the Chronicle API at the following URL:

```text
https://REGION-chronicle.googleapis.com/v1/projects/PROJECT_ID/locations/REGION/instances/CUSTOMER_ID/logTypes/LOG_TYPE/logs:import
```

The `region` parameter selects the [regional service endpoint](https://docs.cloud.google.com/chronicle/docs/reference/rest#service-endpoint) and must match the location of your Google Chronicle tenant.

Each record is sent as a log with the following fields:

- `data`: The record, or the value of `log_key`, encoded in base64.
- `logEntryTime`: The record timestamp.
- `collectionTime`: The time Fluent Bit sent the log. The Chronicle API requires this time to be later than `logEntryTime`, so if the record timestamp isn't in the past, Fluent Bit uses the record timestamp plus one millisecond.
- `environmentNamespace`: The value of `namespace` or `namespace_key`, if set.
- `labels`: The labels set with `label`, if any.

The Chronicle API also differs from the legacy API in the following ways:

- Fluent Bit requests access tokens with the `https://www.googleapis.com/auth/cloud-platform` scope.
- Fluent Bit doesn't check whether `log_type` is supported when it starts. The Chronicle API rejects logs with an unsupported log type when Fluent Bit sends them.
- Fluent Bit doesn't retry requests that the Chronicle API rejects with a `4xx` status code, such as an unsupported log type or missing permissions, because they fail again without a configuration change. Requests rejected with `401`, `408`, or `429`, and server errors, are retried.
- Each request can be up to 4 MB, instead of 1 MiB.

## Configuration file

If you are using a Google Cloud credentials file, the following configuration will get you started:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  outputs:
    - name: chronicle
      match: '*'
      customer_id: my_customer_id
      log_type: my_super_awesome_type
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag  dummy

[OUTPUT]
  Name         chronicle
  Match        *
  Customer_Id  my_customer_id
  Log_Type     my_super_awesome_type
```

{% endtab %}
{% endtabs %}

The following example sets a fallback namespace, resolves the namespace from the record when present, and sends static and record-derived labels with each Chronicle batch:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  outputs:
    - name: chronicle
      match: '*'
      customer_id: my_customer_id
      log_type: my_super_awesome_type
      namespace: fallback-namespace
      namespace_key: "$tenant_namespace"
      label: "env production"
      label: "cluster_name $cluster['name']"
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag  dummy

[OUTPUT]
  Name          chronicle
  Match         *
  Customer_Id   my_customer_id
  Log_Type      my_super_awesome_type
  Namespace     fallback-namespace
  Namespace_Key $tenant_namespace
  Label         env production
  Label         cluster_name $cluster['name']
```

{% endtab %}
{% endtabs %}

The following example sends logs to the Chronicle API of a Google Chronicle tenant in the `us` region:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  outputs:
    - name: chronicle
      match: '*'
      api: chronicle
      project_id: my-project
      customer_id: my_customer_id
      region: us
      log_type: my_super_awesome_type
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag  dummy

[OUTPUT]
  Name         chronicle
  Match        *
  Api          chronicle
  Project_Id   my-project
  Customer_Id  my_customer_id
  Region       us
  Log_Type     my_super_awesome_type
```

{% endtab %}
{% endtabs %}
