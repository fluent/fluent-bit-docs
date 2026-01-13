# Treasure Data

The _Treasure Data_ (TD) output plugin lets you flush your records into the [Treasure Data](https://treasuredata.com) cloud service.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
|:--- |:----------- |:--------|
| `API` | The Treasure Data API key. To obtain it, log into the [Console](https://console.treasuredata.com) and in the API keys box, copy the API key hash. | _none_ |
| `Database` | Specify the name of your target database. | _none_ |
| `Table` | Specify the name of your target table where the records will be stored. | _none_ |
| `Region` | Set the service region. Allowed values: `US`, `JP`. | `US` |
| `Workers`  | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Get started

To start inserting records into Treasure Data, run the plugin from the command line or through the configuration file.

### Command line

You can run the plugin from the command line, but it exposes your API key. Using a configuration file is recommended.

```shell
fluent-bit -i cpu -o td -p API="abc" -p Database="fluentbit" -p Table="cpu_samples"
```

### Configuration file

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
