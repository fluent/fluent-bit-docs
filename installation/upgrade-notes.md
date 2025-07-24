# Upgrade notes

The following article covers the relevant compatibility changes for users upgrading from previous Fluent Bit versions.

For more details about changes on each release, refer to the [Official Release Notes](https://fluentbit.io/announcements/).

Release notes will be prepared in advance of a Git tag for a release. An official release should provide both a tag and a release note together to allow users to verify and understand the release contents.

The tag drives the binary release process. Release binaries (containers and packages) will appear after a tag and its associated release note. This lets users to expect the new release binary to appear and allow/deny/update it as appropriate in their infrastructure.

## Fluent Bit v1.9.9

The `td-agent-bit` package is no longer provided after this release. Users should switch to the `fluent-bit` package.

## Fluent Bit v1.6

If you are migrating from previous version of Fluent Bit, review the following important changes:

### Tail Input Plugin

By default, the tail input plugin follows a file from the end after the service starts, instead of reading it from the beginning. Every file found when the plugin starts is followed from it last position. New files discovered at runtime or when files rotate are read from the beginning.

To keep the old behavior, set the option `read_from_head` to `true`.

### Stackdriver Output Plugin

The `project_id` of [resource](https://cloud.google.com/logging/docs/reference/v2/rest/v2/MonitoredResource) in [LogEntry](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) sent to Google Cloud Logging would be set to the `project_id` rather than the project number. To learn the difference between Project ID and project number, see [Creating and managing projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin).

If you have existing queries based on the resource's `project_id,` update your query accordingly.

## Fluent Bit v1.5

The migration from v1.4 to v1.5 is pretty straightforward.

- The `keepalive` configuration mode has been renamed to `net.keepalive`. Now, all Network I/O keepalive is enabled by default. To learn more about this and other associated configuration properties read the [Networking Administration](https://docs.fluentbit.io/manual/administration/networking#tcp-keepalive) section. - If you use the Elasticsearch output plugin, the default value of `type` [changed from `flb_type` to `_doc`](https://github.com/fluent/fluent-bit/commit/04ed3d8104ca8a2f491453777ae6e38e5377817e#diff-c9ae115d3acaceac5efb949edbb21196). Many versions of Elasticsearch tolerate this, but Elasticsearch v5.6 through v6.1 require a `type` without a leading underscore. See the [Elasticsearch output plugin documentation FAQ entry](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch#faq-underscore) for more.

## Fluent Bit v1.4

If you are migrating from Fluent Bit v1.3, there are no breaking changes.

## Fluent Bit v1.3

If you are migrating from Fluent Bit v1.2 to v1.3, there are no breaking changes. If you are upgrading from an older version, review the following incremental changes:

## Fluent Bit v1.2

### Docker, JSON, Parsers and Decoders

Fluent Bit v1.2 fixed many issues associated with JSON encoding and decoding.

For example, when parsing Docker logs, it's no longer necessary to use decoders. The new Docker parser looks like this:

```python [PARSER] Name docker Format json Time_Key time Time_Format %Y-%m-%dT%H:%M:%S.%L Time_Keep On ```

### Kubernetes Filter

Fluent Bit made improvements to Kubernetes Filter handling of stringified `log` messages. If the `Merge_Log` option is enabled, it will try to handle the log content as a JSON map, if so, it will add the keys to the root map.

In addition, fixes and improvements were made to the `Merge_Log_Key` option. If a merge log succeed, all new keys will be packaged under the key specified by this option. A suggested configuration is as follows:

```python [FILTER] Name Kubernetes Match kube.* Kube_Tag_Prefix kube.var.log.containers. Merge_Log On Merge_Log_Key log_processed ```

As an example, if the original log content is the following map:

```javascript {"key1": "val1", "key2": "val2"} ```

the final record will be composed as follows:

```javascript { "log": "{\"key1\": \"val1\", \"key2\": \"val2\"}", "log_processed": { "key1": "val1", "key2": "val2" } } ```

## Fluent Bit v1.1

If you are upgrading from Fluent Bit 1.0.x or earlier, review the following relevant changes when switching to Fluent Bit v1.1 or later series:

### Kubernetes filter

Fluent Bit introduced a new configuration property called `Kube_Tag_Prefix` to help Tag prefix resolution and address an unexpected behavior in previous versions.

During the `1.0.x` release cycle, a commit in the Tail input plugin changed the default behavior on how the Tag was composed when using the wildcard for expansion generating breaking compatibility with other services. Consider the following configuration example:

```python [INPUT] Name tail Path /var/log/containers/*.log Tag kube.* ```

The expected behavior is that Tag will be expanded to:

```text kube.var.log.containers.apache.log ```

The change introduced in the 1.0 series switched from absolute path to the base filename only:

```text kube.apache.log ```

THe Fluent Bit v1.1 release restored the default behavior and now the Tag is composed using the absolute path of the monitored file.

Having absolute path in the Tag is relevant for routing and flexible configuration where it also helps to keep compatibility with Fluentd behavior.

This behavior switch in Tail input plugin affects how Filter Kubernetes operates. When the filter is used it needs to perform local metadata lookup that comes from the file names when using Tail as a source. With the new `Kube_Tag_Prefix` option you can specify the prefix used in the Tail input plugin. For the previous configuration example the new configuration will look like:

```python [INPUT] Name tail Path /var/log/containers/*.log Tag kube.*

[FILTER] Name kubernetes Match * Kube_Tag_Prefix kube.var.log.containers. ```

The proper value for `Kube_Tag_Prefix` must be composed by Tag prefix set in Tail input plugin plus the converted monitored directory replacing slashes with dots.
