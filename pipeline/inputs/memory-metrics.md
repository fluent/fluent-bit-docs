# Memory metrics

The  _Memory_ (`mem`) input plugin gathers information about the memory and swap usage of the running system every certain interval of time and reports the total amount of memory and the amount of free available.

## Get started

To get memory and swap usage from your system, you can run the plugin from the command line or through the configuration file:

### Command line

Run the following command from the command line:

```bash
fluent-bit -i mem -t memory -o stdout -m '*'
```

Which outputs information similar to:

```text
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/03/03 21:12:35] [ info] [engine] started
[0] memory: [1488543156, {"Mem.total"=>1016044, "Mem.used"=>841388, "Mem.free"=>174656, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[1] memory: [1488543157, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[2] memory: [1488543158, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[3] memory: [1488543159, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
```

## Threading

You can enable the `threaded` setting to run this input in its own
[thread](../../administration/multithreading.md#inputs).

### Configuration file

In your main configuration file append the following `Input` and `Output` sections:

{% tabs %}
{% tab title="fluent-bit.conf" %}

```python
[INPUT]
    Name   mem
    Tag    memory

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: mem
          tag: memory
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% endtabs %}
