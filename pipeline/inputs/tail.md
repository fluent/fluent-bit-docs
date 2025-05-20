# Tail

The **tail** input plugin allows to monitor one or several text files. It has a similar behavior like `tail -f` shell command.

The plugin reads every matched file in the `Path` pattern and for every new line found \(separated by a newline character (\n) \), it generates a new record. Optionally a database file can be used so the plugin can have a history of tracked files and a state of offsets, this is very useful to resume a state if the service is restarted.

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Default |
| :--- |:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| :--- |
| Buffer\_Chunk\_Size | Set the initial buffer size to read files data. This value is used to increase buffer size. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification.                                                                                                                                                                                                                                                                                     | 32k |
| Buffer\_Max\_Size | Set the limit of the buffer size per monitored file. When a buffer needs to be increased \(e.g: very long lines\), this value is used to restrict how much the memory buffer can grow. If reading a file exceeds this limit, the file is removed from the monitored file list. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification.                                                                                                  | 32k |
| Path | Pattern specifying a specific log file or multiple ones through the use of common wildcards. Multiple patterns separated by commas are also allowed.                                                                                                                                                                                                                                                                                                                                                     |  |
| Path\_Key | If enabled, it appends the name of the monitored file as part of the record. The value assigned becomes the key in the map.                                                                                                                                                                                                                                                                                                                                                                              |  |
| Exclude\_Path | Set one or multiple shell patterns separated by commas to exclude files matching certain criteria, e.g: `Exclude_Path *.gz,*.zip`                                                                                                                                                                                                                                                                                                                                                                        |  |
| Offset\_Key | If enabled, Fluent Bit appends the offset of the current monitored file as part of the record. The value assigned becomes the key in the map                                                                                                                                                                                                                                                                                                                                                             |  |
| Read\_from\_Head | For new discovered files on start \(without a database offset/position\), read the content from the head of the file, not tail.                                                                                                                                                                                                                                                                                                                                                                          | False |
| Refresh\_Interval | The interval of refreshing the list of watched files in seconds.                                                                                                                                                                                                                                                                                                                                                                                                                                         | 60 |
| Rotate\_Wait | Specify the number of extra time in seconds to monitor a file once is rotated in case some pending data is flushed.                                                                                                                                                                                                                                                                                                                                                                                      | 5 |
| Ignore\_Older | Ignores files older than `ignore_older`. Supports m, h, d (minutes, hours, days) syntax. Default behavior is to read all.                                                                                                                                                                                                                                                                               |  |
| Skip\_Long\_Lines | When a monitored file reaches its buffer capacity due to a very long line \(Buffer\_Max\_Size\), the default behavior is to stop monitoring that file. Skip\_Long\_Lines alter that behavior and instruct Fluent Bit to skip long lines and continue processing other lines that fits into the buffer size.                                                                                                                                                                                              | Off |
| Skip\_Empty\_Lines | Skips empty lines in the log file from any further processing or output.                                                                                                                                                                                                                                                                                                                                                                                                                                 | Off |
| DB | Specify the database file to keep track of monitored files and offsets.                                                                                                                                                                                                                                                                                                                                                                                                                                  |  |
| DB.sync | Set a default synchronization \(I/O\) method. Values: Extra, Full, Normal, Off. This flag affects how the internal SQLite engine do synchronization to disk, for more details about each option please refer to [this section](https://www.sqlite.org/pragma.html#pragma_synchronous). Most of workload scenarios will be fine with `normal` mode, but if you really need full synchronization after every write operation you should set `full` mode. Note that `full` has a high I/O performance cost. | normal |
| DB.locking | Specify that the database will be accessed only by Fluent Bit. Enabling this feature helps to increase performance when accessing the database but it restrict any external tool to query the content.                                                                                                                                                                                                                                                                                                   | false |
| DB.journal\_mode | sets the journal mode for databases \(WAL\). Enabling WAL provides higher performance. Note that WAL is not compatible with shared network file systems.                                                                                                                                                                                                                                                                                                                                                 | WAL |
| DB.compare_filename | This option determines whether to check both the `inode` and the `filename` when retrieving stored file information from the database. 'true' verifies both the `inode` and `filename`, while 'false' checks only the `inode` (default). To check the inode and filename in the database, refer [here](#keep_state).                                                                                                                     | false |
| Mem\_Buf\_Limit | Set a limit of memory that Tail plugin can use when appending data to the Engine. If the limit is reach, it will be paused; when the data is flushed it resumes.                                                                                                                                                                                                                                                                                                                                         |  |
| Exit\_On\_Eof | When reading a file will exit as soon as it reach the end of the file. Useful for bulk load and tests                                                                                                                                                                                                                                                                                                                                                                                                    | false |
| Parser | Specify the name of a parser to interpret the entry as a structured message.                                                                                                                                                                                                                                                                                                                                                                                                                             |  |
| Key | When a message is unstructured \(no parser applied\), it's appended as a string under the key name _log_. This option allows to define an alternative name for that key.                                                                                                                                                                                                                                                                                                                                 | log |
| Inotify_Watcher | Set to false to use file stat watcher instead of inotify.                                                                                                                                                                                                                                                                                                                                                                                                                                                | true |
| Tag | Set a tag \(with regex-extract fields\) that will be placed on lines read. E.g. `kube.<namespace_name>.<pod_name>.<container_name>.<container_id>`. Note that "tag expansion" is supported: if the tag includes an asterisk \(\*\), that asterisk will be replaced with the absolute path of the monitored file, with slashes replaced by dots \(also see [Workflow of Tail + Kubernetes Filter](../filters/kubernetes.md#workflow-of-tail--kubernetes-filter)\).                                                                                       |  |
| Tag\_Regex | Set a regex to extract fields from the file name. E.g. `(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<container_id>[a-z0-9]{64})\.log$`                                                                                                                                                                                                                                                                                                                    |  |
| Static\_Batch\_Size | Set the maximum number of bytes to process per iteration for the monitored static files (files that already exists upon Fluent Bit start).                                                                                                                                                                                                                                                                                                                                                               | 50M     |
| File\_Cache\_Advise | Set the posix_fadvise in POSIX_FADV_DONTNEED mode. This will reduce the usage of the kernel file cache. This option is ignored if not running on Linux.                                                                                                                                                                                                                                                                                                                                                              | On     |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

{% hint style="info" %}
If the database parameter `DB` is **not** specified, by default the plugin will start reading each target file from the beginning. This also might cause some unwanted behavior, for example when a line is bigger that `Buffer_Chunk_Size` and `Skip_Long_Lines` is not turned on, the file will be read from the beginning of each `Refresh_Interval` until the file is rotated.
{% endhint %}

## Monitor a large number of files

If you need to monitor a large number of files, you can increase the inotify settings in your Linux environment. To do so, modify the following sysctl parameters:

```text
sysctl fs.inotify.max_user_watches=LIMIT1
sysctl fs.inotify.max_user_instances=LIMIT2
```

Replace _`LIMIT1`_ and _`LIMIT2`_ with the integer values of your choosing. Higher values raise your inotify limit accordingly.

However, these changes revert upon reboot unless you write them to the appropriate `inotify.conf` file, in which case they will persist across reboots. The specific name of this file might vary depending on how you built and installed Fluent Bit. For example, to write changes to a file named `fluent-bit_fs_inotify.conf`, run the following commands:

```shell
mkdir -p /etc/sysctl.d
echo fs.inotify.max_user_watches = LIMIT1 >> /etc/sysctl.d/fluent-bit_fs_inotify.conf
echo fs.inotify.max_user_instances = LIMIT2 >> /etc/sysctl.d/fluent-bit_fs_inotify.conf
```

Replace _`LIMIT1`_ and _`LIMIT2`_ with the integer values of your choosing.

You can also provide a custom systemd file that overrides the default systemd settings for Fluent Bit. This override file must be located at `/etc/systemd/system/fluent-bit.service.d/override.conf`. For example, you can add this snippet to your override file to raise the number of files that the Tail plugin can monitor:

```text
[Service]
LimitNOFILE=LIMIT
```

Replace _`LIMIT`_ with the integer value of your choosing.

If you don't already have an override file, you can use the following command to create one in the correct directory:

```shell copy
systemctl edit fluent-bit.service
```

## Multiline Support

Starting from Fluent Bit v1.8 we have introduced a new Multiline core functionality. For Tail input plugin, it means that now it supports the **old** configuration mechanism but also the **new** one. In order to avoid breaking changes, we will keep both but encourage our users to use the latest one. We will call the two mechanisms as:

* Multiline Core
* Old Multiline

### Multiline Core \(v1.8\)

The new multiline core is exposed by the following configuration:

| Key | Description |
| :--- | :--- |
| multiline.parser | Specify one or multiple [Multiline Parser definitions](../../administration/configuring-fluent-bit/multiline-parsing.md) to apply to the content. |

As stated in the [Multiline Parser documentation](../../administration/configuring-fluent-bit/multiline-parsing.md), now we provide built-in configuration modes. Note that when using a new `multiline.parser` definition, you must **disable** the old configuration from your tail section like:

* parser
* parser\_firstline
* parser\_N
* multiline
* multiline\_flush
* docker\_mode

### Multiline and Containers \(v1.8\)

If you are running Fluent Bit to process logs coming from containers like Docker or CRI, you can use the new built-in modes for such purposes. This will help to reassembly multiline messages originally split by Docker or CRI:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[INPUT]
    name              tail
    path              /var/log/containers/*.log
    multiline.parser  docker, cri
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
  inputs:
    - name: tail
      path: /var/log/containers/*.log
      multiline.parser: docker, cri
```
{% endtab %}
{% endtabs %}

The two options separated by a comma mean Fluent Bit will try each parser in the list in order, applying the first one that matches the log.

It will use the first parser which has a `start_state` that matches the log.

For example, it will first try `docker`, and if `docker` does not match, it will then try `cri`.

We are **still working** on extending support to do multiline for nested stack traces and such. Over the Fluent Bit v1.8.x release cycle we will be updating the documentation.

### Old Multiline Configuration Parameters <a id="multiline"></a>

For the old multiline configuration, the following options exist to configure the handling of multilines logs:

| Key | Description | Default |
| :--- | :--- | :--- |
| Multiline | If enabled, the plugin will try to discover multiline messages and use the proper parsers to compose the outgoing messages. Note that when this option is enabled the Parser option is not used. | Off |
| Multiline\_Flush | Wait period time in seconds to process queued multiline messages | 4 |
| Parser\_Firstline | Name of the parser that matches the beginning of a multiline message. Note that the regular expression defined in the parser must include a group name \(named capture\), and the value of the last match group must be a string |  |
| Parser\_N | Optional-extra parser to interpret and structure multiline entries. This option can be used to define multiple parsers, e.g: Parser\_1 ab1,  Parser\_2 ab2, Parser\_N abN. |  |

### Old Docker Mode Configuration Parameters <a id="docker_mode"></a>

Docker mode exists to recombine JSON log lines split by the Docker daemon due to its line length limit. To use this feature, configure the tail plugin with the corresponding parser and then enable Docker mode:

| Key | Description | Default |
| :--- | :--- | :--- |
| Docker\_Mode | If enabled, the plugin will recombine split Docker log lines before passing them to any parser as configured above. This mode cannot be used at the same time as Multiline. | Off |
| Docker\_Mode\_Flush | Wait period time in seconds to flush queued unfinished split lines. | 4 |
| Docker\_Mode\_Parser | Specify an optional parser for the first line of the docker multiline mode. The parser name to be specified must be registered in the `parsers.conf` file. |  |

## Getting Started <a id="getting_started"></a>

In order to tail text or log files, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit parse text files with the following options:

```bash
$ fluent-bit -i tail -p path=/var/log/syslog -o stdout
```

### Configuration File

In your main configuration file, append the following `Input` and `Output` sections:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[INPUT]
    Name    tail
    Path    /var/log/syslog

[OUTPUT]
    Name   stdout
    Match  *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
  inputs:
    - name: tail
      path: /var/log/syslog

  outputs:
    - stdout:
      match: *
```
{% endtab %}
{% endtabs %}

![](../../.gitbook/assets/image%20%286%29.png)

### Old Multi-line example

When using multi-line configuration you need to first specify `Multiline On` in the configuration and use the `Parser_Firstline` and additional parser parameters `Parser_N` if needed. If we are trying to read the following Java Stacktrace as a single event

```text
Dec 14 06:41:08 Exception in thread "main" java.lang.RuntimeException: Something has gone wrong, aborting!
    at com.myproject.module.MyProject.badMethod(MyProject.java:22)
    at com.myproject.module.MyProject.oneMoreMethod(MyProject.java:18)
    at com.myproject.module.MyProject.anotherMethod(MyProject.java:14)
    at com.myproject.module.MyProject.someMethod(MyProject.java:10)
    at com.myproject.module.MyProject.main(MyProject.java:6)
```

We need to specify a `Parser_Firstline` parameter that matches the first line of a multi-line event. Once a match is made Fluent Bit will read all future lines until another match with `Parser_Firstline` is made .

In the case above we can use the following parser, that extracts the Time as `time` and the remaining portion of the multiline as `log`


{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[PARSER]
    Name multiline
    Format regex
    Regex /(?<time>[A-Za-z]+ \d+ \d+\:\d+\:\d+)(?<message>.*)/
    Time_Key  time
    Time_Format %b %d %H:%M:%S
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
parsers:
  - name: multiline
    format: regex
    regex: '/(?<time>[A-Za-z]+ \d+ \d+\:\d+\:\d+)(?<message>.*)/'
    time_key: time
    time_format: '%b %d %H:%M:%S'
```
{% endtab %}
{% endtabs %}

If we want to further parse the entire event we can add additional parsers with `Parser_N` where N is an integer. The final Fluent Bit configuration looks like the following:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
# Note this is generally added to parsers.conf and referenced in [SERVICE]
[PARSER]
    Name multiline
    Format regex
    Regex /(?<time>[A-Za-z]+ \d+ \d+\:\d+\:\d+)(?<message>.*)/
    Time_Key  time
    Time_Format %b %d %H:%M:%S

[INPUT]
    Name             tail
    Multiline        On
    Parser_Firstline multiline
    Path             /var/log/java.log

[OUTPUT]
    Name             stdout
    Match            *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
parsers:
  - name: multiline
    format: regex
    regex: '/(?<time>[A-Za-z]+ \d+ \d+\:\d+\:\d+)(?<message>.*)/'
    time_key: time
    time_format: '%b %d %H:%M:%S'

pipeline:
  inputs:
    - name:  tail
      multiline: on
      read_from_head: true
      parser_firstline: multiline
      path: /var/log/java.log

  outputs:
    - name: stdout
      match: '*'
```
{% endtab %}
{% endtabs %}

Our output will be as follows.

```text
[0] tail.0: [1607928428.466041977, {"message"=>"Exception in thread "main" java.lang.RuntimeException: Something has gone wrong, aborting!
    at com.myproject.module.MyProject.badMethod(MyProject.java:22)
    at com.myproject.module.MyProject.oneMoreMethod(MyProject.java:18)
    at com.myproject.module.MyProject.anotherMethod(MyProject.java:14)
    at com.myproject.module.MyProject.someMethod(MyProject.java:10)", "message"=>"at com.myproject.module.MyProject.main(MyProject.java:6)"}]
```

## Tailing files keeping state <a id="keep_state"></a>

The _tail_ input plugin a feature to save the state of the tracked files, is strongly suggested you enabled this. For this purpose the **db** property is available, e.g:

```bash
$ fluent-bit -i tail -p path=/var/log/syslog -p db=/path/to/logs.db -o stdout
```

When running, the database file _/path/to/logs.db_ will be created, this database is backed by SQLite3 so if you are interested into explore the content, you can open it with the SQLite client tool, e.g:

```text
$ sqlite3 tail.db
-- Loading resources from /home/edsiper/.sqliterc

SQLite version 3.14.1 2016-08-11 18:53:32
Enter ".help" for usage hints.
sqlite> SELECT * FROM in_tail_files;
id     name                              offset        inode         created
-----  --------------------------------  ------------  ------------  ----------
1      /var/log/syslog                   73453145      23462108      1480371857
sqlite>
```

> Make sure to explore when Fluent Bit is not hard working on the database file, otherwise you will see some _Error: database is locked_ messages.

#### Formatting SQLite

By default SQLite client tool do not format the columns in a human read-way, so to explore _in\_tail\_files_ table you can create a config file in **~/.sqliterc** with the following content:

```text
.headers on
.mode column
.width 5 32 12 12 10
```

## SQLite and Write Ahead Logging

Fluent Bit keep the state or checkpoint of each file through using a SQLite database file, so if the service is restarted, it can continue consuming files from it last checkpoint position \(offset\). The default options set are enabled for high performance and corruption-safe.

The SQLite journaling mode enabled is `Write Ahead Log` or `WAL`. This allows to improve performance of read and write operations to disk. When enabled, you will see in your file system additional files being created, consider the following configuration statement:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[INPUT]
    name    tail
    path    /var/log/containers/*.log
    db      test.db
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
  inputs:
    - name:  tail
      path: /var/log/containers/*.log
      db: test.db
```
{% endtab %}
{% endtabs %}

The above configuration enables a database file called `test.db` and in the same path for that file SQLite will create two additional files:

* test.db-shm
* test.db-wal

Those two files aims to support the `WAL` mechanism that helps to improve performance and reduce the number system calls required. The `-wal` file refers to the file that stores the new changes to be committed, at some point the `WAL` file transactions are moved back to the real database file. The `-shm` file is a shared-memory type to allow concurrent-users to the `WAL` file.

### WAL and Memory Usage

The `WAL` mechanism give us higher performance but also might increase the memory usage by Fluent Bit. Most of this usage comes from the memory mapped and cached pages. In some cases you might see that memory usage keeps a bit high giving the impression of a memory leak, but actually is not relevant unless you want your memory metrics back to normal. Starting from Fluent Bit v1.7.3 we introduced the new option `db.journal_mode` mode that sets the journal mode for databases, by default it will be `WAL (Write-Ahead Logging)`, currently allowed configurations for `db.journal_mode` are `DELETE | TRUNCATE | PERSIST | MEMORY | WAL | OFF` .

## File Rotation

File rotation is properly handled, including logrotate's _copytruncate_ mode.

Note that the `Path` patterns **cannot** match the rotated files. Otherwise, the rotated file would be read again and lead to duplicate records.
