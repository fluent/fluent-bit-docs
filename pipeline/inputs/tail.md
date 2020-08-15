# Tail

The **tail** input plugin allows to monitor one or several text files. It has a similar behavior like _tail -f_ shell command.

The plugin reads every matched file in the _Path_ pattern and for every new line found \(separated by a \n\), it generates a new record. Optionally a database file can be used so the plugin can have a history of tracked files and a state of offsets, this is very useful to resume a state if the service is restarted.

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Buffer\_Chunk\_Size | Set the initial buffer size to read files data. This value is used too to increase buffer size. The value must be according to the [Unit Size](https://github.com/fluent/fluent-bit-docs/tree/00bb8cbd96cc06988ff3e51b4933e16e49206c70/pipeline/configuration/unit_sizes.md) specification. | 32k |
| Buffer\_Max\_Size | Set the limit of the buffer size per monitored file. When a buffer needs to be increased \(e.g: very long lines\), this value is used to restrict how much the memory buffer can grow. If reading a file exceed this limit, the file is removed from the monitored file list. The value must be according to the [Unit Size](https://github.com/fluent/fluent-bit-docs/tree/00bb8cbd96cc06988ff3e51b4933e16e49206c70/pipeline/configuration/unit_sizes.md) specification. | Buffer\_Chunk\_Size |
| Path | Pattern specifying a specific log files or multiple ones through the use of common wildcards. |  |
| Path\_Key | If enabled, it appends the name of the monitored file as part of the record. The value assigned becomes the key in the map. |  |
| Exclude\_Path | Set one or multiple shell patterns separated by commas to exclude files matching a certain criteria, e.g: Exclude\_Path \*.gz,\*.zip |  |
| Refresh\_Interval | The interval of refreshing the list of watched files in seconds. | 60 |
| Rotate\_Wait | Specify the number of extra time in seconds to monitor a file once is rotated in case some pending data is flushed. | 5 |
| Ignore\_Older | Ignores records which are older than this time in seconds. Supports m,h,d \(minutes, hours, days\) syntax. Default behavior is to read all records from specified files. Only available when a Parser is specificied and it can parse the time of a record. |  |
| Skip\_Long\_Lines | When a monitored file reach it buffer capacity due to a very long line \(Buffer\_Max\_Size\), the default behavior is to stop monitoring that file. Skip\_Long\_Lines alter that behavior and instruct Fluent Bit to skip long lines and continue processing other lines that fits into the buffer size. | Off |
| DB | Specify the database file to keep track of monitored files and offsets. |  |
| DB.Sync | Set a default synchronization \(I/O\) method. Values: Extra, Full, Normal, Off. This flag affects how the internal SQLite engine do synchronization to disk, for more details about each option please refer to [this section](https://www.sqlite.org/pragma.html#pragma_synchronous). | Full |
| Mem\_Buf\_Limit | Set a limit of memory that Tail plugin can use when appending data to the Engine. If the limit is reach, it will be paused; when the data is flushed it resumes. |  |
| Parser | Specify the name of a parser to interpret the entry as a structured message. |  |
| Key | When a message is unstructured \(no parser applied\), it's appended as a string under the key name _log_. This option allows to define an alternative name for that key. | log |
| Tag | Set a tag \(with regex-extract fields\) that will be placed on lines read. E.g. `kube.<namespace_name>.<pod_name>.<container_name>`. Note that "tag expansion" is supported: if the tag includes an asterisk \(\*\), that asterisk will be replaced with the absolute path of the monitored file \(also see [Workflow of Tail + Kubernetes Filter](https://github.com/fluent/fluent-bit-docs/tree/00bb8cbd96cc06988ff3e51b4933e16e49206c70/pipeline/filter/kubernetes.md)\). |  |
| Tag\_Regex | Set a regex to exctract fields from the file. E.g. `(?<pod_name>[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-` |  |
| Exit\_On\_EOF | Exit Fluent Bit when reaching EOF on a monitored file. | Off |

Note that if the database parameter _db_ is **not** specified, by default the plugin will start reading each target file from the beginning.

### Multiline Configuration Parameters <a id="multiline"></a>

Additionally the following options exists to configure the handling of multi-lines files:

| Key | Description | Default |
| :--- | :--- | :--- |
| Multiline | If enabled, the plugin will try to discover multiline messages and use the proper parsers to compose the outgoing messages. Note that when this option is enabled the Parser option is not used. | Off |
| Multiline\_Flush | Wait period time in seconds to process queued multiline messages | 4 |
| Parser\_Firstline | Name of the parser that matchs the beginning of a multiline message. Note that the regular expression defined in the parser must include a group name \(named capture\) |  |
| Parser\_N | Optional-extra parser to interpret and structure multiline entries. This option can be used to define multiple parsers, e.g: Parser\_1 ab1,  Parser\_2 ab2, Parser\_N abN. |  |

### Docker Mode Configuration Parameters <a id="docker_mode"></a>

Docker mode exists to recombine JSON log lines split by the Docker daemon due to its line length limit. To use this feature, configure the tail plugin with the corresponding parser and then enable Docker mode:

| Key | Description | Default |
| :--- | :--- | :--- |
| Docker\_Mode | If enabled, the plugin will recombine split Docker log lines before passing them to any parser as configured above. This mode cannot be used at the same time as Multiline. | Off |
| Docker\_Mode\_Flush | Wait period time in seconds to flush queued unfinished split lines. | 4 |
| Docker\_Mode\_Parser | Specify the parser name to fetch log first line for muliline log. |  | 

## Getting Started <a id="getting_started"></a>

In order to tail text or log files, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit parse text files with the following options:

```bash
$ fluent-bit -i tail -p path=/var/log/syslog -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name        tail
    Path        /var/log/syslog

[OUTPUT]
    Name   stdout
    Match  *
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

## Files Rotation

Files rotation are properly handled, including logrotate _copytruncate_ mode.

