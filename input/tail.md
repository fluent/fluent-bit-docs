# Tail

The **tail** input plugin allows to monitor one or several text files. It have a similar behavior to _tail -f_ shell command.

The plugin reads every matched file in the _Path_ pattern and for every new line found \(separated by a \n\), it generate a new record. Optionally a database file can be used so the plugin can have a history of tracked files and a state of offsets, this is very useful to resume a state if the service is restarted.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Path | Pattern specifying a specific log files or multiple ones through the use of common wildcards. |
| Exclude\_Path | Set one or multiple shell patterns separated by commas to exclude files matching a certain criteria, e.g: exclude\_path=\*.gz,\*.zip |
| Refresh\_Interval | The interval of refreshing the list of watched files. Default is 60 seconds. |
| Rotate\_Wait | Specify the number of extra seconds to monitor a file once is rotated in case some pending data is flushed. Default is 5 seconds. |
| DB | Specify the database file to keep track of monitored files and offsets. |

Note that if the database parameter _db_ is **not** specified, by default the plugin will start reading each target file from the beginning.

## Getting Started

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

### Tailing files keeping state

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

