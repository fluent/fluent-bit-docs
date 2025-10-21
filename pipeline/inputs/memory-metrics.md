# Memory metrics

The  _Memory_ (`mem`) input plugin gathers information about the memory and swap usage of the running system every certain interval of time and reports the total amount of memory and the amount of free available.

## Get started

To get memory and swap usage from your system, you can run the plugin from the command line or through the configuration file:

### Command line

Run the following command from the command line, noting this is for a Linux machine:

```shell
fluent-bit -i mem -t memory -o stdout -m '*'
```

Which outputs information similar to:

```text
...
[0] memory: [[1751381087.225589224, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381088.228411537, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381089.225600084, {}], {"Mem.total"=>3986708, "Mem.used"=>561480, "Mem.free"=>3425228, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381090.228345064, {}], {"Mem.total"=>3986708, "Mem.used"=>561480, "Mem.free"=>3425228, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
...
```

## Threading

You can enable the `threaded` setting to run this input in its own
[thread](../../administration/multithreading.md#inputs).

### Configuration file

In your main configuration file append the following:

{% tabs %}
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
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name   mem
  Tag    memory

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}