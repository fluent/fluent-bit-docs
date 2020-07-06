# New Relic

[New Relic](https://newrelic.com/) is a data management platform that gives you real-time insights of your data for developers, operations and management teams.

The Fluent Bit `nrlogs` output plugin allows you to send your logs to New Relic service.

Before to get started with the plugin configuration, make sure to obtain the proper account to get access to the service. You can register and start with a free trial in the following link:

* [New Relic Sign Up](https://newrelic.com/signup)

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |


<table>
  <thead>
    <tr>
      <th style="text-align:left">base_uri</th>
      <th style="text-align:left">
        <p>Full address of New Relic API end-point. By default the value points to
          the US end-point.
          <br />
        </p>
        <p>If you want to use the EU end-point you can set this key to the following
          value:
          <br />
          <br /><a href="https://log-api.eu.newrelic.com/log/v1">https://log-api.eu.newrelic.com/log/v1</a>
        </p>
      </th>
      <th style="text-align:left"><a href="https://log-api.newrelic.com/log/v1">https://log-api.newrelic.com/log/v1</a>
      </th>
    </tr>
  </thead>
  <tbody></tbody>
</table>

<table>
  <thead>
    <tr>
      <th style="text-align:left">api_key</th>
      <th style="text-align:left">
        <p>Your key for data ingestion. The API key is also called the ingestion
          key, you can get more details on how to generated in the official documentation
          <a
          href="https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#event-insert-key">here</a>.</p>
        <p>From a configuration perspective either an <code>api_key</code> or an <code>license_key</code> is
          required. New Relic suggest to use primary the <code>api_key</code>.</p>
      </th>
      <th style="text-align:left"></th>
    </tr>
  </thead>
  <tbody></tbody>
</table>

<table>
  <thead>
    <tr>
      <th style="text-align:left">license_key</th>
      <th style="text-align:left">
        <p>Optional authentication parameter for data ingestion.
          <br />
        </p>
        <p>Note that New Relic suggest to use the <code>api_key</code> instead. You
          can read more about the License Key <a href="https://docs.newrelic.com/docs/accounts/install-new-relic/account-setup/license-key">here</a>.</p>
      </th>
      <th style="text-align:left"></th>
    </tr>
  </thead>
  <tbody></tbody>
</table>

| compress | Set the compression mechanism for the payload. This option allows two values: `gzip` \(enabled by default\) or `false` to disable compression. | gzip |
| :--- | :--- | :--- |


The following configuration example, will emit a dummy example record and ingest it on New Relic. Copy and paste the following content in a file called `newrelic.conf`:

```python
[SERVICE]
    flush     1
    log_level info

[INPUT]
    name      dummy
    dummy     {"message":"a simple message", "temp": "0.74", "extra": "false"}
    samples   1

[OUTPUT]
    name      nrlogs
    match     *
    api_key   YOUR_API_KEY_HERE
```

run Fluent Bit with the new configuration file:

```text
$ fluent-bit -c newrelic.conf
```

Fluent Bit output:

```text
Fluent Bit v1.5.0
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2020/04/10 10:58:32] [ info] [storage] version=1.0.3, initializing...
[2020/04/10 10:58:32] [ info] [storage] in-memory
[2020/04/10 10:58:32] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2020/04/10 10:58:32] [ info] [engine] started (pid=2772591)
[2020/04/10 10:58:32] [ info] [output:newrelic:newrelic.0] configured, hostname=log-api.newrelic.com:443
[2020/04/10 10:58:32] [ info] [sp] stream processor started
[2020/04/10 10:58:35] [ info] [output:nrlogs:nrlogs.0] log-api.newrelic.com:443, HTTP status=202
{"requestId":"feb312fe-004e-b000-0000-0171650764ac"}
```

