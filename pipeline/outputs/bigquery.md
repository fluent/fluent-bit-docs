# Google Cloud BigQuery

BigQuery output plugin is an _experimental_ plugin that allows you to stream records into [Google Cloud BigQuery](https://cloud.google.com/bigquery/) service. The implementation does not support the following, which would be expected in a full production version:

* [Application Default Credentials](https://cloud.google.com/docs/authentication/production).
* [Data deduplication](https://cloud.google.com/bigquery/streaming-data-into-bigquery) using `insertId`.
* [Template tables](https://cloud.google.com/bigquery/streaming-data-into-bigquery) using `templateSuffix`.

## Google Cloud Configuration

Fluent Bit streams data into an existing BigQuery table using a service account that you specify. Therefore, before using the BigQuery output plugin, you must create a service account, create a BigQuery dataset and table, authorize the service account to write to the table, and provide the service account credentials to Fluent Bit.

### Creating a Service Account

To stream data into BigQuery, the first step is to create a Google Cloud service account for Fluent Bit:

* [Creating a Google Cloud Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

### Creating a BigQuery Dataset and Table

Fluent Bit does not create datasets or tables for your data, so you must create these ahead of time. You must also grant the service account `WRITER` permission on the dataset:

* [Creating and using datasets](https://cloud.google.com/bigquery/docs/datasets)

Within the dataset you will need to create a table for the data to reside in. You can follow the following instructions for creating your table. Pay close attention to the schema. It must match the schema of your output JSON. Unfortunately, since BigQuery does not allow dots in field names, you will need to use a filter to change the fields for many of the standard inputs \(e.g, mem or cpu\).

* [Creating and using tables](https://cloud.google.com/bigquery/docs/tables)

### Retrieving Service Account Credentials

Fluent Bit BigQuery output plugin uses a JSON credentials file for authentication credentials. Download the credentials file by following these instructions:

* [Creating and Managing Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

### Workload Identity Federation

Using identity federation, you can grant on-premises or multi-cloud workloads access to Google Cloud resources, without using a service account key. It can be used as a more secure alternative to service account credentials. Google Cloud's workload identity federation supports several identity providers (see documentation) but Fluent Bit BigQuery plugin currently supports Amazon Web Services (AWS) only.

* [Workload Identity Federation overview](https://cloud.google.com/iam/docs/workload-identity-federation)

You must configure workload identity federation in GCP before using it with Fluent Bit.

* [Configuring workload identity federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation#aws)
* [Obtaining short-lived credentials with identity federation](https://cloud.google.com/iam/docs/using-workload-identity-federation)

## Configurations Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| google\_service\_credentials | Absolute path to a Google Cloud credentials JSON file. | Value of the environment variable _$GOOGLE\_SERVICE\_CREDENTIALS_ |
| project\_id | The project id containing the BigQuery dataset to stream into. | The value of the `project_id` in the credentials file |
| dataset\_id | The dataset id of the BigQuery dataset to write into. This dataset must exist in your project. |  |
| table\_id | The table id of the BigQuery table to write into. This table must exist in the specified dataset and the schema must match the output. |  |
| skip\_invalid\_rows | Insert all valid rows of a request, even if invalid rows exist. The default value is false, which causes the entire request to fail if any invalid rows exist. | Off |
| ignore\_unknown\_values | Accept rows that contain values that do not match the schema. The unknown values are ignored. Default is false, which treats unknown values as errors. | Off |
| enable\_workload\_identity\_federation | Enables workload identity federation as an alternative authentication method. Cannot be used with service account credentials file or environment variable. AWS is the only identity provider currently supported. | Off |
| aws\_region | Used to construct a regional endpoint for AWS STS to verify AWS credentials obtained by Fluent Bit. Regional endpoints are recommended by AWS. |  |
| project\_number | GCP project number where the identity provider was created. Used to construct the full resource name of the identity provider. |  |
| pool\_id | GCP workload identity pool where the identity provider was created. Used to construct the full resource name of the identity provider. |  |
| provider\_id | GCP workload identity provider. Used to construct the full resource name of the identity provider. Currently only AWS accounts are supported. |  |
| google\_service\_account | Email address of the Google service account to impersonate. The workload identity provider must have permissions to impersonate this service account, and the service account must have permissions to access Google BigQuery resources (e.g. `write` access to tables) |  |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

See Google's [official documentation](https://cloud.google.com/bigquery/docs/reference/rest/v2/tabledata/insertAll) for further details.

## Configuration File

If you are using a _Google Cloud Credentials File_, the following configuration is enough to get you started:

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
  Name dummy
  Tag  dummy

[OUTPUT]
  Name         bigquery
  Match        *
  dataset_id   my_dataset
  table_id     dummy_table
```

{% endtab %}
{% endtabs %}