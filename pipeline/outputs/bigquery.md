# Google Cloud BigQuery

The _Google Cloud BigQuery_ output plugin is an experimental plugin that lets you stream records into the [Google Cloud BigQuery](https://cloud.google.com/bigquery) service.

The implementation doesn't support the following, which would be expected in a full production version:

- [Application Default Credentials](https://docs.cloud.google.com/docs/authentication).
- [Data deduplication](https://docs.cloud.google.com/bigquery/docs/streaming-data-into-bigquery) using `insertId`.
- [Template tables](https://docs.cloud.google.com/bigquery/docs/streaming-data-into-bigquery) using `templateSuffix`.

## Google Cloud configuration

Fluent Bit streams data into an existing BigQuery table using a service account that you specify. Before using the BigQuery output plugin, you must:

1. To stream data into BigQuery, you must create a [Google Cloud service account](https://docs.cloud.google.com/iam/docs/service-accounts-create) for Fluent Bit.
1. Create a BigQuery dataset.
   Fluent Bit doesn't create datasets for your data, so you must [create the dataset](https://docs.cloud.google.com/bigquery/docs/datasets) ahead of time. You must also grant the service account `WRITER` permission on the dataset.

   Within the dataset you must create a table for the data to reside in. Use the following instructions for creating your table. Pay close attention to the schema, as it must match the schema of your output JSON. Unfortunately, because BigQuery doesn't allow dots in field names, you must use a filter to change the fields for many of the standard inputs (for example, `mem` or `cpu`).
1. [Create a BigQuery table](https://docs.cloud.google.com/bigquery/docs/tables).
1. Fluent Bit BigQuery output plugin uses a JSON credentials file for authentication credentials. [Authorize the service account](https://docs.cloud.google.com/iam/docs/keys-create-delete) to write to the table.
1. Provide the service account credentials to Fluent Bit.
   With [workload identity federation](https://docs.cloud.google.com/iam/docs/workload-identity-federation), you can grant on-premises or multi-cloud workloads access to Google Cloud resources, without using a service account key. It can be used as a more secure alternative to service account credentials. Google Cloud's workload identity federation supports several identity providers (see documentation) but Fluent Bit BigQuery plugin currently supports Amazon Web Services (AWS) only.

   You must configure workload identity federation in GCP before using it with Fluent Bit.

   - [Configuring workload identity federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation#aws)
   - [Obtaining short-lived credentials with identity federation](https://cloud.google.com/iam/docs/using-workload-identity-federation)

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `aws_region` | Used to construct a regional endpoint for AWS STS to verify AWS credentials obtained by Fluent Bit. Regional endpoints are recommended by AWS. | _none_ |
| `dataset_id` | The dataset ID of the BigQuery dataset to write into. This dataset must exist in your project. | _none_ |
| `enable_identity_federation` | Enables workload identity federation as an alternative authentication method. Can't be used with a service account credentials file or environment variable. AWS is the only identity provider currently supported. | `Off` |
| `google_service_account` | The email address of the Google service account to impersonate. The workload identity provider must have permissions to impersonate this service account, and the service account must have permissions to access Google BigQuery resources (`write` access to tables). | _none_ |
| `google_service_credentials` | Absolute path to a Google Cloud credentials JSON file. | Value of the environment variable `$GOOGLE_SERVICE_CREDENTIALS`. |
| `ignore_unknown_values` | Accept rows that contain values that don't match the schema. The unknown values are ignored. Default is `Off`, which treats unknown values as errors. | `Off` |
| `pool_id` | GCP workload identity pool where the identity provider was created. Used to construct the full resource name of the identity provider. | _none_ |
| `project_id` | The project ID containing the BigQuery dataset to stream into. | Value of the `project_id` in the credentials file. |
| `project_number` | GCP project number where the identity provider was created. Used to construct the full resource name of the identity provider. | _none_ |
| `provider_id` | GCP workload identity provider. Used to construct the full resource name of the identity provider. Currently only AWS accounts are supported. | _none_ |
| `service_account_email` | The service account email address. Used as an alternative to a credentials file. | _none_ |
| `service_account_secret` | The service account private key. Used as an alternative to a credentials file. | _none_ |
| `skip_invalid_rows` | Insert all valid rows of a request, even if invalid rows exist. When `Off`, the entire request fails if any invalid rows exist. | `Off` |
| `table_id` | The table ID of the BigQuery table to write into. This table must exist in the specified dataset and the schema must match the output. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

See Google's [official documentation](https://docs.cloud.google.com/bigquery/docs/reference/rest/v2/tabledata/insertAll) for further details.

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
    - name: bigquery
      match: '*'
      dataset_id: my_dataset
      table_id: dummy_table
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  dummy
  Tag   dummy

[OUTPUT]
  Name         bigquery
  Match        *
  Dataset_id   my_dataset
  Table_id     dummy_table
```

{% endtab %}
{% endtabs %}
