# Kernel logs

The _Kernel logs_ (`kmsg`) input plugin reads the Linux Kernel log buffer from the beginning. It gets every record and parses fields as `priority`, `sequence`, `seconds`, `useconds`, and `message`.

## Configuration parameters

| Key          | Description                                                                                                                                             | Default |
|:-------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| `Prio_Level` | The log level to filter. The kernel log is dropped if its priority is more than `prio_level`. Allowed values are `0`-`8`. `8` means all logs are saved. | `8`     |
| `Threaded`   | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                 | `false` |

## Get started

To start getting the Linux Kernel messages, you can run the plugin from the command line or through the configuration file:

### Command line

```shell
fluent-bit -i kmsg -t kernel -o stdout -m '*'
```

Which returns output similar to:

```text
...
[0] kernel: [1463421823, {"priority"=>3, "sequence"=>1814, "sec"=>11706, "usec"=>732233, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec profile =20:3a:07:9e:4a:ac"}]
[1] kernel: [1463421823, {"priority"=>3, "sequence"=>1815, "sec"=>11706, "usec"=>732300, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec profile =20:3a:07:9e:4a:ac"}]
[2] kernel: [1463421829, {"priority"=>3, "sequence"=>1816, "sec"=>11712, "usec"=>729728, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec profile =20:3a:07:9e:4a:ac"}]
[3] kernel: [1463421829, {"priority"=>3, "sequence"=>1817, "sec"=>11712, "usec"=>729802, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec
...
```

As described previously, the plugin processed all messages that the Linux Kernel reported. The output has been truncated for clarification.

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: kmsg
      tag: kernel

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name   kmsg
  Tag    kernel

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}
