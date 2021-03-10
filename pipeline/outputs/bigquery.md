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

## Configurations Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| google\_service\_credentials | Absolute path to a Google Cloud credentials JSON file | Value of the environment variable _$GOOGLE\_SERVICE\_CREDENTIALS_ |
| project\_id | The project id containing the BigQuery dataset to stream into. | The value of the `project_id` in the credentials file |
| dataset\_id | The dataset id of the BigQuery dataset to write into. This dataset must exist in your project. |  |
| table\_id | The table id of the BigQuery table to write into. This table must exist in the specified dataset and the schema must match the output. |  |

## Configuration File

If you are using a _Google Cloud Credentials File_, the following configuration is enough to get you started:

```text
[INPUT]
    Name  dummy
    Tag   dummy

[OUTPUT]
    Name       bigquery
    Match      *
    dataset_id my_dataset
    table_id   dummy_table
```

