# Scheduling and Retries

[Fluent Bit](https://fluentbit.io) has an Engine that helps to coordinate the data ingestion from input plugins and calls the _Scheduler_ to decide when it is time to flush the data through one or multiple output plugins. The Scheduler flushes new data at a fixed time of seconds and the _Scheduler_ retries when asked.

Once an output plugin gets called to flush some data, after processing that data it can notify the Engine three possible return statuses:

* OK
* Retry
* Error

If the return status was **OK**, it means it was successfully able to process and flush the data. If it returned an **Error** status, it means that an unrecoverable error happened and the engine should not try to flush that data again. If a **Retry** was requested, the _Engine_ will ask the _Scheduler_ to retry to flush that data, the Scheduler will decide how many seconds to wait before that happens.

## Configuring Wait Time for Retry

The Scheduler provides two configuration options called **scheduler.cap** and **scheduler.base** which can be set in the Service section.

| Key | Description | Default Value | 
| -- | ------------| --------------| 
| scheduler.cap | Set a maximum retry time in seconds. The property is supported from v1.8.7. | 2000 | 
| scheduler.base | Set a base of exponential backoff. The property is supported from v1.8.7. | 5 |

These two configuration options determine the waiting time before a retry will happen. 

Fluent Bit uses an exponential backoff and jitter algorithm to determine the waiting time before a retry.

The waiting time is a random number between a configurable upper and lower bound.

For the Nth retry, the lower bound of the random number will be:

`base`

The upper bound will be:

`min(base * (Nth power of 2), cap)`

Given an example where `base` is set to 3 and `cap` is set to 30. 

1st retry: The lower bound will be 3, the upper bound will be 3 * 2 = 6. So the waiting time will be a random number between (3, 6).

2nd retry: the lower bound will be 3, the upper bound will be 3 * (2 * 2) = 12. So the waiting time will be a random number between (3, 12).

3rd retry: the lower bound will be 3, the upper bound will be 3 * (2 * 2 * 2) = 24. So the waiting time will be a random number between (3, 24).

4th retry: the lower bound will be 3, since 3 * (2 * 2 * 2 * 2) = 48 > 30, the upper bound will be 30. So the waiting time will be a random number between (3, 30).

Basically, the **scheduler.base** determines the lower bound of time between each retry and the **scheduler.cap** determines the upper bound.

For a detailed explanation of the exponential backoff and jitter algorithm, please check this [blog](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/).

### Example

The following example configures the **scheduler.base** as 3 seconds and **scheduler.cap** as 30 seconds. 

```text
[SERVICE]
    Flush            5
    Daemon           off
    Log_Level        debug
    scheduler.base   3
    scheduler.cap    30
```

The waiting time will be:

| Nth retry | waiting time range (seconds) |
| --- | --- | 
| 1 | (3, 6)  |
| 2 | (3, 12) |
| 3 | (3, 24) |
| 4 | (3, 30) |

## Configuring Retries

The Scheduler provides a simple configuration option called **Retry\_Limit**, which can be set independently on each output section. This option allows us to disable retries or impose a limit to try N times and then discard the data after reaching that limit:

|  | Value | Description |
| :--- | :--- | :--- |
| Retry\_Limit | N | Integer value to set the maximum number of retries allowed. N must be &gt;= 1 \(default: 1\) |
| Retry\_Limit | `no_limits` or `False` | When Retry\_Limit is set to `no_limits` or`False`, means that there is not limit for the number of retries that the Scheduler can do. |
| Retry\_Limit | no\_retries | When Retry\_Limit is set to no\_retries, means that retries are disabled and Scheduler would not try to send data to the destination if it failed the first time. |

### Example

The following example configures two outputs where the HTTP plugin has an unlimited number of while the Elasticsearch plugin have a limit of 5 retries:

```text
[OUTPUT]
    Name        http
    Host        192.168.5.6
    Port        8080
    Retry_Limit False

[OUTPUT]
    Name            es
    Host            192.168.5.20
    Port            9200
    Logstash_Format On
    Retry_Limit     5
```

