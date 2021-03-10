# Upgrade Notes

The following article cover the relevant notes for users upgrading from previous Fluent Bit versions. We aim to cover compatibility changes that you must be aware of.

For more details about changes on each release please refer to the [Official Release Notes](https://fluentbit.io/announcements/).

## Fluent Bit v1.6

If you are migrating from previous version of Fluent Bit please review the following important changes:

#### Tail Input Plugin

Now by default the plugin follows a file from the end once the service starts \(old behavior was always read from the beginning\). For every file found at start, its followed from it last position, for new files discovered at runtime or rotated, they are read from the beginning.

If you desire to keep the old behavior you can set the option `read_from_head` to true.

### Stackdriver Output Plugin

The project\_id of [resource](https://cloud.google.com/logging/docs/reference/v2/rest/v2/MonitoredResource) in [LogEntry](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) sent to Google Cloud Logging would be set to the project ID rather than the project number. To learn the difference between Project ID and project number, see [this](https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin) for more details.

If you have any existing queries based on the resource's project\_id, please update your query accordingly.

## Fluent Bit v1.5

The migration from v1.4 to v1.5 is pretty straightforward.

* If you enabled `keepalive` mode in your configuration, note that this configuration property has been renamed to `net.keepalive`. Now all Network I/O keepalive is enabled by default, to learn more about this and other associated configuration properties read the [Networking Administration](https://docs.fluentbit.io/manual/administration/networking#tcp-keepalive) section.
* If you use the Elasticsearch output plugin, note the default value of `type` [changed from `flb_type` to `_doc`](https://github.com/fluent/fluent-bit/commit/04ed3d8104ca8a2f491453777ae6e38e5377817e#diff-c9ae115d3acaceac5efb949edbb21196). Many versions of Elasticsearch will tolerate this, but ES v5.6 through v6.1 require a type _without_ a leading underscore. See the [Elasticsearch output plugin documentation FAQ entry](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch#faq-underscore) for more.

## Fluent Bit v1.4

If you are migrating from Fluent Bit v1.3, there are no breaking changes. Just new exciting features to enjoy :\)

## Fluent Bit v1.3

If you are migrating from Fluent Bit v1.2 to v1.3, there are no breaking changes. If you are upgrading from an older version please review the incremental changes below.

## Fluent Bit v1.2

### Docker, JSON, Parsers and Decoders

On Fluent Bit v1.2 we have fixed many issues associated with JSON encoding and decoding, for hence when parsing Docker logs **is no longer necessary** to use decoders. The new Docker parser looks like this:

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

During 1.0.x release cycle, a commit in Tail input plugin changed the default behavior on how the Tag was composed when using the wildcard for expansion generating breaking compatibility with other services. Consider the following configuration example:

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

