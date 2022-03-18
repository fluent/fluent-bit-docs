# Nightfall

The Nightfall filter scans logs for sensitive data and redacts the sensitive portions. This filter supports scanning for
various sensitive information, ranging from API keys and personally identifiable information(PII) to custom regexes you
define. You can configure what to scan for in the [Nightfall Dashboard](https://app.nightfall.ai).

> This filter is not enabled by default in 1.9.0 due to a typo. It must be enabled by setting flag ```-DFLB_FILTER_NIGHTFALL=ON``` when building. In 1.9.1 and above this is fixed.
## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| nightfall\_api_key | The Nightfall API key to scan your logs with, obtainable from the [Nightfall Dashboard](https://app.nightfall.ai) | |
| policy\_id | The Nightfall dev platform policy to scan your logs with, configurable in the [Nightfall Dashboard](https://app.nightfall.ai/developer-platform/policies). | |
| sampling\_rate | The rate controlling how much of your logs you wish to be scanned, must be a float between (0,1]. 1 means all logs will be scanned. Useful for avoiding rate limits in conjunction with Fluent Bit's match rule.| 1 |
| tls.debug | Debug level between 0 (nothing) and 4 (every detail). | 0 |
| tls.verify | When enabled, turns on certificate validation when connecting to the Nightfall API. | true |
| tls.ca_path | Absolute path to root certificates, required if tls.verify is true. | |

### Command Line

```text
$ bin/fluent-bit -c /PATH_TO_CONF_FILE/fluent-bit.conf

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

### Configuration File

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
```

