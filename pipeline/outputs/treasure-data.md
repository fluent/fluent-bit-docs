# Treasure Data

The **td** output plugin, allows to flush your records into the [Treasure Data](http://treasuredata.com) cloud service.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key      | Description                                                                                                                                                                        | Default |
|:---------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| API      | The [Treasure Data](http://treasuredata.com) API key. To obtain it please log into the [Console](https://console.treasuredata.com) and in the API keys box, copy the API key hash. |         |
| Database | Specify the name of your target database.                                                                                                                                          |         |
| Table    | Specify the name of your target table where the records will be stored.                                                                                                            |         |
| Region   | Set the service region, available values: US and JP                                                                                                                                | US      |
| Workers  | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output.                                                               | `0`     |

## Getting Started

In order to start inserting records into [Treasure Data](https://www.treasuredata.com), you can run the plugin from the command line or through the configuration file:

### Command Line:

```shell
fluent-bit -i cpu -o td -p API="abc" -p Database="fluentbit" -p Table="cpu_samples"
```

Ideally you don't want to expose your API key from the command line, using a configuration file is highly desired.

### Configuration File

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: my_cpu
      
  outputs:
    - name: td
      match: '*'
      api: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      database: fluentbit
      table: cpu_samples
```

{% endtab %}
{% tab title="fluent-bit.conf" %}


```text
[INPUT]
  Name cpu
  Tag  my_cpu

[OUTPUT]
  Name     td
  Match    *
  API      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  Database fluentbit
  Table    cpu_samples
```

{% endtab %}
{% endtabs %}