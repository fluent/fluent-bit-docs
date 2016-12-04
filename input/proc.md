# Process

_Process_ input plugin allows you to check how _health_ a process is. It does the check by issuing a process every a certain interval of time.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description       |
| -------------|-------------------|
| Proc_Name    | Name of the target Process to check. |
| Interval\_Sec| Interval in seconds between the service checks. Default value is _1_. |
| Internal\_Nsec| Specify a nanoseconds interval for service checks, it works in conjuntion with the Interval\_Sec configuration key. Default value is _0_.|
| Alert        | If enabled, it will only generate messages if the target TCP service is down. By default this option is disabled.|

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

The following example will check the health of _crond_ process.

```bash
$ fluent-bit -i proc -p proc_name=crond -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          proc
    Proc_Name     crond
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

Once Fluent Bit is running, you will see the health of process:

```bash
$ fluent-bit -i proc -p proc_name=crond -o stdout
Fluent-Bit v0.10.0
Copyright (C) Treasure Data

[2016/12/04 19:14:52] [ info] [engine] started
[0] proc.0: [1480846493, {"alive"=>true, "proc_name"=>"crond", "pid"=>2425}]
[1] proc.0: [1480846494, {"alive"=>true, "proc_name"=>"crond", "pid"=>2425}]
[2] proc.0: [1480846495, {"alive"=>true, "proc_name"=>"crond", "pid"=>2425}]
[3] proc.0: [1480846496, {"alive"=>true, "proc_name"=>"crond", "pid"=>2425}]
```