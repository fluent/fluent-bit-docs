# Memory metrics

The _Memory_ (`mem`) input plugin gathers memory and swap usage on Linux at a fixed interval and reports totals and free space. The plugin emits log-based metrics (for Prometheus-format metrics see the Node Exporter metrics input plugin).

## Metrics reported

| Key          | Description                                                            | Units       |
|:-------------|:-----------------------------------------------------------------------|:------------|
| `Mem.free`   | Free or available memory reported by the kernel.                       | Kilobytes   |
| `Mem.total`  | Total system memory.                                                   | Kilobytes   |
| `Mem.used`   | Memory in use (`Mem.total` - `Mem.free`).                              | Kilobytes   |
| `Swap.free`  | Free swap space.                                                       | Kilobytes   |
| `Swap.total` | Total system swap.                                                     | Kilobytes   |
| `Swap.used`  | Swap space in use (`Swap.total` - `Swap.free`).                        | Kilobytes   |
| `proc_bytes` | Optional. Resident set size for the configured process (`pid`).        | Bytes       |
| `proc_hr`    | Optional. Human-readable value of `proc_bytes` (for example, `12.00M`). | Formatted   |

## Configuration parameters

The plugin supports the following configuration parameters:

| Key             | Description                                                                                             | Default |
|:----------------|:--------------------------------------------------------------------------------------------------------|:--------|
| `interval_nsec` | Polling interval in nanoseconds.                                                                        | `0`     |
| `interval_sec`  | Polling interval in seconds.                                                                            | `1`     |
| `pid`           | Process ID to measure. When set, the plugin also reports `proc_bytes` and `proc_hr`.                    | _none_  |
| `threaded`      | Run this input in its own [thread](../../administration/multithreading.md#inputs).                      | `false` |

## Get started

To collect memory and swap usage from your system, run the plugin from the command line or through the configuration file.

### Command line

Run the following command from the command line:

```shell
fluent-bit -i mem -t memory -o stdout -m '*'
```

The output is similar to:

```text
...
[0] memory: [[1751381087.225589224, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381088.228411537, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381089.225600084, {}], {"Mem.total"=>3986708, "Mem.used"=>561480, "Mem.free"=>3425228, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381090.228345064, {}], {"Mem.total"=>3986708, "Mem.used"=>561480, "Mem.free"=>3425228, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
...
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: mem
      tag: memory
      interval_sec: 5
      pid: 1234

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name          mem
  Tag           memory
  Interval_Sec  5
  Interval_NSec 0
  PID           1234

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

Example output when `pid` is set:

```text
...
[0] memory: [[1751381087.225589224, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0, "proc_bytes"=>12349440, "proc_hr"=>"11.78M"}]
...
```