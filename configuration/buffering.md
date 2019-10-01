# Buffering / Storage

The end-goal of [Fluent Bit](https://fluentbit.io) is to collect, parse, filter and ship logs to a central place. In this workflow there are many phases and one of the critical pieces is the ability to do _buffering_ : a mechanism to place processed data into a temporal location until is ready to be shipped.

By default when Fluent Bit process data, it uses Memory as a primary and temporal place to store the record logs, but there are certain scenarios where would be ideal to have a persistent buffering mechanism based in the filesystem to provide aggregation and data safety capabilities.

Starting with Fluent Bit v1.0, we introduced a new _storage layer_ that can either work in memory or in the file system. Input plugins can be configured to use one or the other upon demand at start time.

## Configuration

The storage layer configuration takes place in two areas:

* Service Section
* Input Section

The known Service section configure a global environment for the storage layer, and then in the Input sections defines which mechanism to use.

### Service Section Configuration

| Key | Description | Default |
| :--- | :--- | :--- |
| storage.path | Set an optional location in the file system to store streams and chunks of data. If this parameter is not set, Input plugins can only use in-memory buffering. |  |
| storage.sync | Configure the synchronization mode used to store the data into the file system. It can take the values _normal_ or _full_. | normal |
| storage.checksum | Enable the data integrity check when writing and reading data from the filesystem. The storage layer uses the CRC32 algorithm. | Off |
| storage.backlog.mem\_limit | If _storage.path_ is set, Fluent Bit will look for data chunks that were not delivered and are still in the storage layer, these are called _backlog_ data. This option configure a hint of maximum value of memory to use when processing these records. | 5M |

a Service section will look like this:

```text
[SERVICE]
    flush                     1
    log_Level                 info
    storage.path              /var/log/flb-storage/
    storage.sync              normal
    storage.checksum          off
    storage.backlog.mem_limit 5M
```

that configuration configure an optional buffering mechanism where it root for data is _/var/log/flb-storage/_, it will use _normal_ synchronization mode, without checksum and up to a maximum of 5MB of memory when processing backlog data.

### Input Section Configuration

Optionally, any Input plugin can configure their storage preference, the following table describe the options available:

| Key | Description | Default |
| :--- | :--- | :--- |
| storage.type | Specify the buffering mechanism to use. It can be _memory_ or _filesystem_. | memory |

The following example configure a service that offers filesystem buffering capabilities and two Input plugins being the first based in memory and the second with the filesystem:

```text
[SERVICE]
    flush                     1
    log_Level                 info
    storage.path              /var/log/flb-storage/
    storage.sync              normal
    storage.checksum          off
    storage.backlog.mem_limit 5M

[INPUT]
    name          cpu
    storage.type  filesystem

[INPUT]
    name          mem
    storage.type  memory
```

