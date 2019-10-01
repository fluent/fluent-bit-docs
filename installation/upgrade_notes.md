# Upgrade Notes

The following article cover the relevant notes for users upgrading from previous Fluent Bit versions. We aim to cover compatibility changes that you must be aware of.

For more details about changes on each release please refer to the [Official Release Notes](https://fluentbit.io/announcements/).

## Fluent Bit v1.2

### Docker, JSON, Parsers and Decoders

On Fluent Bit v1.2 we have fixed many issues associated with JSON encoding and decoding, for hence when parsing Docker logs **is not longer necessary** to use decoders. The new Docker parser looks like this:

```text
[PARSER]
    Name         docker
    Format       json
    Time_Key     time
    Time_Format  %Y-%m-%dT%H:%M:%S.%L
    Time_Keep    On
```

> Note: again, do not use decoders.

### Kubernetes Filter

We have done improvements also on how Kubernetes Filter handle the stringified _log_ message. If the option _Merge\_Log_ is enabled, it will try to handle the log content as a JSON map, if so, it will add the keys to the root map.

In addition, we have fixed and improved the option called _Merge\_Log\_Key_. If a merge log succeed, all new keys will be packaged under the key specified by this option, a suggested configuration is as follows:

```text
[FILTER]
    Name             Kubernetes
    Match            kube.*
    Kube_Tag_Prefix  kube.var.log.containers.
    Merge_Log        On
    Merge_Log_Key    log_processed
```

As an example, if the original log content is the following map:

```javascript
{"key1": "val1", "key2": "val2"}
```

the final record will be composed as follows:

```javascript
{
    "log": "{\"key1\": \"val1\", \"key2\": \"val2\"}",
    "log_processed": {
        "key1": "val1",
        "key2": "val2"
    }
}
```

## Fluent Bit v1.1

If you are upgrading from **Fluent Bit &lt;= 1.0.x** you should take in consideration the following relevant changes when switching to **Fluent Bit v1.1** series:

### Kubernetes Filter

We introduced a new configuration property called _Kube\_Tag\_Prefix_ to help Tag prefix resolution and address an unexpected behavior that landed in previous versions.

Duing 1.0.x release cycle, a commit in Tail input plugin changed the default behavior on how the Tag was composed when using the wildcard for expansion generating breaking compatibility with other services. Consider the following configuration example:

```text
[INPUT]
    Name  tail
    Path  /var/log/containers/*.log
    Tag   kube.*
```

The expected behavior is that Tag will be expanded to:

```text
kube.var.log.containers.apache.log
```

but the change introduced in 1.0 series switched from absolute path to the base file name only:

```text
kube.apache.log
```

On Fluent Bit v1.1 release we restored to our default behavior and now the Tag is composed using the absolute path of the monitored file.

> Having absolute path in the Tag is relevant for routing and flexible configuration where it also helps to keep compatibility with Fluentd behavior.

This behavior switch in Tail input plugin affects how Filter Kubernetes operates. As you know when the filter is used it needs to perform local metadata lookup that comes from the file names when using Tail as a source. Now with the new _Kube\_Tag\_Prefix_ option you can specify what's the prefix used in Tail input plugin, for the configuration example above the new configuration will look as follows:

```text
[INPUT]
    Name  tail
    Path  /var/log/containers/*.log
    Tag   kube.*

[FILTER]
    Name             kubernetes
    Match            *
    Kube_Tag_Prefix  kube.var.log.containers.
```

So the proper for _Kube\_Tag\_Prefix_ value must be composed by Tag prefix set in Tail input plugin plus the converted monitored directory replacing slashes with dots.

