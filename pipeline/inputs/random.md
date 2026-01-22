# Random

The _Random_ input plugin generates random value samples using the device interface `/dev/urandom`. If that interface is unavailable, it uses a Unix timestamp as a value.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
|:----|:------------|:--------|
| `interval_nsec` | Set the interval between generated samples, in nanoseconds. This works in conjunction with `interval_sec`. | `0` |
| `interval_sec` | Set the interval between generated samples, in seconds. | `1` |
| `samples` | Set the number of samples to generate. `-1` generates unlimited samples. | `-1` |
| `threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To start generating random samples, you can either run the plugin from the command line or through a configuration file.

### Command line

Use the following command line options to generate samples.

```shell
fluent-bit -i random -o stdout
```

### Configuration file

The following examples are sample configuration files for this input plugin:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: random
      samples: -1
      interval_sec: 1
      interval_nsec: 0

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name          random
  Samples      -1
  Interval_Sec  1
  Interval_Nsec 0

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

## Testing

After Fluent Bit starts running, it generates reports in the output interface:

```shell
$ fluent-bit -i random -o stdout

...
[0] random.0: [1475893654, {"rand_value"=>1863375102915681408}]
[1] random.0: [1475893655, {"rand_value"=>425675645790600970}]
[2] random.0: [1475893656, {"rand_value"=>7580417447354808203}]
[3] random.0: [1475893657, {"rand_value"=>1501010137543905482}]
[4] random.0: [1475893658, {"rand_value"=>16238242822364375212}]
...
```