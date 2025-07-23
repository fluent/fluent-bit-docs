# Nightfall

The _Nightfall_ filter scans logs for sensitive data and redacts any sensitive
portions. This filter supports scanning for various sensitive information, ranging
from API keys and Personally Identifiable Information (PII) to custom regular
expressions you define. You can configure what to scan for in the
[Nightfall Dashboard](https://app.nightfall.ai).

This filter isn't enabled by default in version 1.9.0 due to a typo. To enable it,
set the flag ```-DFLB_FILTER_NIGHTFALL=ON``` when building. This is fixed for
versions 1.9.1 and later.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `nightfall_api_key` | The Nightfall API key to scan your logs with, obtainable from the [Nightfall Dashboard](https://app.nightfall.ai) | _none_ |
| `policy_id` | The Nightfall developer platform policy to scan your logs with, configurable in the [Nightfall Dashboard](https://app.nightfall.ai/developer-platform/policies). | _none_ |
| `sampling_rate` | The rate controlling how much of your logs you wish to be scanned. Must be a float between `(0,1]`. `1` means all logs will be scanned. Use this setting to avoid rate limits in conjunction with Fluent Bit match rules.| `1` |
| `tls.debug` | Debug level between `0` (nothing) and `4` (every detail). | `0` |
| `tls.verify` | When enabled, turns on certificate validation when connecting to the Nightfall API. | `true` |
| `tls.ca_path` | Absolute path to root certificates, required if `tls.verify` is true. | _none_ |

### Configuration file

The following is an example of a configuration file for the Nightfall filter:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      host: 0.0.0.0
      port: 8000

  filters:
    - name: nightfall
      match: '*'
      nightfall_api_key: <API key>
      policy_id: 5991946b-1cc8-4c38-9240-72677029a3f7
      sampling_rate: 1
      tls.ca_path: /etc/ssl/certs

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name http
  host 0.0.0.0
  port 8000

[FILTER]
  Name nightfall
  Match *
  nightfall_api_key <API key>
  policy_id 5991946b-1cc8-4c38-9240-72677029a3f7
  sampling_rate 1
  tls.ca_path /etc/ssl/certs

[OUTPUT]
  Name stdout
  Match *
```

{% endtab %}
{% endtabs %}

### Command line

After you configure the filter, you can use it from the command line by running a command like:

```shell
# For YAML configuration.
fluent-bit -c /PATH_TO_CONF_FILE/fluent-bit.yaml

# For classic configuration.
fluent-bit -c /PATH_TO_CONF_FILE/fluent-bit.conf
```

Replace _`PATH_TO_CONF_FILE`_ with the path for where your filter configuration file
is located.

Which results in output like:

```text
[2022/02/09 19:46:22] [ info] [engine] started (pid=53844)
[2022/02/09 19:46:22] [ info] [storage] version=1.1.5, initializing...
[2022/02/09 19:46:22] [ info] [storage] in-memory
[2022/02/09 19:46:22] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2022/02/09 19:46:22] [ info] [cmetrics] version=0.2.2
[2022/02/09 19:46:22] [ info] [input:http:http.0] listening on 0.0.0.0:8000
[2022/02/09 19:46:22] [ info] [sp] stream processor started
[2022/02/09 19:46:30] [ info] [filter:nightfall:nightfall.0] Nightfall request http_do=0, HTTP Status: 200
[0] app.log: [1644464790.280412000, {"A"=>"there is nothing sensitive here", "B"=>[{"A"=>"my credit card number is *******************"}, {"A"=>"*********** is my social security."}], "C"=>false, "D"=>"key ********************"}]
[2022/02/09 19:47:25] [ info] [filter:nightfall:nightfall.0] Nightfall request http_do=0, HTTP Status: 200
[0] app.log: [1644464845.675431000, {"A"=>"a very safe string"}]
```