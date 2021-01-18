# Splunk

Splunk output plugin allows to ingest your records into a [Splunk Enterprise](https://www.splunk.com/en_us/products/splunk-enterprise.html) service through the HTTP Event Collector \(HEC\) interface.

To get more details about how to setup the HEC in Splunk please refer to the following documentation: [Splunk / Use the HTTP Event Collector](http://docs.splunk.com/Documentation/Splunk/7.0.3/Data/UsetheHTTPEventCollector)

## Configuration Parameters

<table>
  <thead>
    <tr>
      <th style="text-align:left">Key</th>
      <th style="text-align:left">Description</th>
      <th style="text-align:left">default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Host</td>
      <td style="text-align:left">IP address or hostname of the target Splunk service.</td>
      <td style="text-align:left">127.0.0.1</td>
    </tr>
    <tr>
      <td style="text-align:left">Port</td>
      <td style="text-align:left">TCP port of the target Splunk service.</td>
      <td style="text-align:left">8088</td>
    </tr>
    <tr>
      <td style="text-align:left">Compress</td>
      <td style="text-align:left">Set payload compression mechanism. Option available is 'gzip'.</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">Splunk_Token</td>
      <td style="text-align:left">Specify the Authentication <a href="http://dev.splunk.com/view/event-collector/SP-CAAAE7C">Token</a> for
        the HTTP Event Collector interface.</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">Splunk_Send_Raw</td>
      <td style="text-align:left">
        <p>When enabled, the record keys and values are set in the top level of the
          map instead of under the <em>event</em> key.</p>
        <p><b>note:</b> refer to the Sending Raw Events section below for more details
          to make this option work properly.</p>
      </td>
      <td style="text-align:left">Off</td>
    </tr>
    <tr>
      <td style="text-align:left">HTTP_User</td>
      <td style="text-align:left">Optional username for Basic Authentication on HEC</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">HTTP_Passwd</td>
      <td style="text-align:left">Password for user defined in HTTP_User</td>
      <td style="text-align:left"></td>
    </tr>
  </tbody>
</table>

### TLS / SSL

Splunk output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](../../administration/security.md) section.

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

If you would like to customize any of the Splunk event metadata, such as the host or target index, you can set `Splunk_Send_Raw On` in the plugin configuration, and add the metadata as keys/values in the record. _Note_: with `Splunk_Send_Raw` enabled, you are responsible for creating and populating the `event` section of the payload.

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

```javascript
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

For more information on the Splunk HEC payload format and all event metadata Splunk accepts, see here: [http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC](http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC)

### Sending Raw Events

If the option `splunk_send_raw` has been enabled, the user must take care to put all log details in the event field, and only specify fields known to Splunk in the top level event, if there is a mismatch, Splunk will return a HTTP error 400.

Consider the following example:

**splunk\_send\_raw off**

```javascript
{"time": ..., "event": {"k1": "foo", "k2": "bar", "index": "applogs"}}
```

**splunk\_send\_raw on**

```text
{"time": .., "k1": "foo", "k2": "bar", "index": "applogs"}
```

For up to date information about the valid keys in the top level object, refer to the Splunk documentation:

[http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC](http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC)

