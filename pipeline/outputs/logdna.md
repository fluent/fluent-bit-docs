# LogDNA

[LogDNA](https://logdna.com/) is an intuitive cloud based log management system that provides you an easy interface to query your logs once they are stored.

The Fluent Bit `logdna` output plugin allows you to send your log or events to a [LogDNA](https://logdna.com/) compliant service like:

* [LogDNA](https://logdna.com/)
* [IBM Log Analysis](https://www.ibm.com/cloud/log-analysis)

Before to get started with the plugin configuration, make sure to obtain the proper account to get access to the service. You can start with a free trial in the following link:

* [LogDNA Sign Up ](https://logdna.com/sign-up/)

## Configuration Parameters

<table>
  <thead>
    <tr>
      <th style="text-align:left">Key</th>
      <th style="text-align:left">Description</th>
      <th style="text-align:left">Default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">logdna_host</td>
      <td style="text-align:left">LogDNA API host address</td>
      <td style="text-align:left">logs.logdna.com</td>
    </tr>
    <tr>
      <td style="text-align:left">logdna_port</td>
      <td style="text-align:left">LogDNA TCP Port</td>
      <td style="text-align:left">443</td>
    </tr>
    <tr>
      <td style="text-align:left">api_key</td>
      <td style="text-align:left">API key to get access to the service. This property is <b>mandatory</b>.</td>
      <td
      style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">hostname</td>
      <td style="text-align:left">
        <p>Name of the local machine or device where Fluent Bit is running.
          <br />
        </p>
        <p>When this value is not set, Fluent Bit lookup the hostname and auto populate
          the value. If it cannot be found, an <code>unknown</code> value will be set
          instead.</p>
      </td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">mac</td>
      <td style="text-align:left">Mac address. This value is optional.</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">ip</td>
      <td style="text-align:left">IP address of the local hostname. This value is optional.</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">tags</td>
      <td style="text-align:left">A list of comma separated strings to group records in LogDNA and simplify
        the query with filters.</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">file</td>
      <td style="text-align:left">Optional name of a file being monitored. Note that this value is only
        set if the record do not contain a reference to it.</td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left">app</td>
      <td style="text-align:left">Name of the application. This value is auto discovered on each record,
        if not found, the default value is used.</td>
      <td style="text-align:left">Fluent Bit</td>
    </tr>
  </tbody>
</table>

## Auto Enrichment & Data Discovery

One of the features of Fluent Bit + LogDNA integration is the ability to auto enrich each record with further context.

When the plugin process each record \(or log\), it tries to lookup for specific key names that might contain specific context for the record in question, the following table describe the keys and the discovery logic:

| Key | Description |
| :--- | :--- |
| level | If the record contains a key called `level` or `severity`, it will populate the context `level` key with that value. If not found, the context key is not set. |
| file | if the record contains a key called `file`, it will populate the context `file` with the value found, otherwise If the plugin configuration provided a `file` property, that value will be used instead \(see table above\). |
| app | If the record contains a key called `app`, it will populate the context `app` with the value found, otherwise it will use the value set for `app` in the configuration property \(see table above\). |
| meta | if the record contains a key called `meta`, it will populate the context `meta` with the value found. |

## Getting Started

The following configuration example, will emit a dummy example record and ingest it on LogDNA. Copy and paste the following content in a file called `logdna.conf`:

```python
[SERVICE]
    flush     1
    log_level info

[INPUT]
    name      dummy
    dummy     {"log":"a simple log message", "severity": "INFO", "meta": {"s1": 12345, "s2": true}, "app": "Fluent Bit"}
    samples   1

[OUTPUT]
    name      logdna
    match     *
    api_key   YOUR_API_KEY_HERE
    hostname  my-hostname
    ip        192.168.1.2
    mac       aa:bb:cc:dd:ee:ff
    tags      aa, bb
```

run Fluent Bit with the new configuration file:

```text
$ fluent-bit -c logdna.conf
```

Fluent Bit output:

```text
Fluent Bit v1.5.0
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2020/04/07 17:44:37] [ info] [storage] version=1.0.3, initializing...
[2020/04/07 17:44:37] [ info] [storage] in-memory
[2020/04/07 17:44:37] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2020/04/07 17:44:37] [ info] [engine] started (pid=2157706)
[2020/04/07 17:44:37] [ info] [output:logdna:logdna.0] configured, hostname=monox-fluent-bit-2
[2020/04/07 17:44:37] [ info] [sp] stream processor started
[2020/04/07 17:44:38] [ info] [output:logdna:logdna.0] logs.logdna.com:443, HTTP status=200
{"status":"ok","batchID":"f95849a8-ec6c-4775-9d52-30763604df9b:40710:ld72"}
```

Your record will be available and visible in your LogDNA dashboard after a few seconds.

### Query your Data in LogDNA

In your LogDNA dashboard, go to the top filters and mark the Tags `aa` and `bb`, then you will be able to see your records as the example below:

![](../../.gitbook/assets/logdna.png)

