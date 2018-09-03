# Splunk

Splunk output plugin allows to ingest your records into a [Splunk Enterprise](https://www.splunk.com/en_us/products/splunk-enterprise.html) service through the HTTP Event Collector \(HEC\) interface.

To get more details about how to setup the HEC in Splunk please refer to the following documentation: [Splunk / Use the HTTP Event Collector](http://docs.splunk.com/Documentation/Splunk/7.0.3/Data/UsetheHTTPEventCollector)

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target Splunk service. | 127.0.0.1 |
| Port | TCP port of the target Splunk service. | 8088 |
| Splunk\_Token | Specify the Authentication [Token](http://dev.splunk.com/view/event-collector/SP-CAAAE7C) for the HTTP Event Collector interface. |  |
| Splunk\_Send\_Raw | When enabled, the record keys and values are set in the top level of the map instead of under the _event_ key. | Off |
| HTTP\_User | Optional username for Basic Authentication on HEC |  |
| HTTP\_Passwd | Password for user defined in HTTP\_User |  |

### TLS / SSL

Splunk output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](https://github.com/fluent/fluent-bit-docs/tree/ad9d80e5490bd5d79c86955c5689db1cb4cf89db/getting_started/tls_ssl.md) section.

## Getting Started

In order to insert records into a Splunk service, you can run the plugin from the command line or through the configuration file:

### Command Line

The **splunk** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -t cpu -o splunk -p host=127.0.0.1 -p port=8088 \
  -p tls=on -p tls.verify=off -m '*'
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```text
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name        splunk
    Match       *
    Host        127.0.0.1
    Port        8088
    TLS         On
    TLS.Verify  Off
    Message_Key my_key
```

### Data format

By default, the Splunk output plugin nests the record under the `event` key in the payload sent to the HEC. It will also append the time of the record to a top level `time` key.

If you would like to customize any of the Splunk event metadata, such as the host or target index, you can set `Splunk_Send_Raw On` in the plugin configuraiton, and add the metadata as keys/values in the record. *Note*: with `Splunk_Send_Raw` enabled, you are responsible for creating and populating the `event` section of the payload.

For example, to add a custom index and hostname:

```text
[INPUT]
    Name  cpu
    Tag   cpu

# nest the record under the 'event' key
[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard *
    Nest_under event

# add event metadata
[FILTER]
    Name      modify
    Match     *
    Add index my-splunk-index
    Add host  my-host

[OUTPUT]
    Name        splunk
    Match       *
    Host        127.0.0.1
    Splunk_Token xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
    Splunk_Send_Raw On
```

This will create a payload that looks like:

```json
{
    "time": "1535995058.003385189",
    "index": "my-splunk-index",
    "host": "my-host",
    "event": {
        "cpu_p":0.000000,
        "user_p":0.000000,
        "system_p":0.000000
    }
}
```

For more information on the Splunk HEC payload format and all event meatadata Splunk accepts, see here: http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC
