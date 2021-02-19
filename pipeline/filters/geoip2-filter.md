---
description: Look up Geo data from IP
---

# GeoIP2 Filter

GeoIP2 Filter allows you to enrich the incoming data stream using location data from GeoIP2 database.

## Configuration Parameters <a id="config"></a>

This plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| database | Path to the GeoIP2 database. |
| lookup\_key | Field name to process |
| record | Defines the `KEY LOOKUP_KEY VALUE` triplet. See below for how to set up this option. |

## Getting Started <a id="getting_started"></a>

The following configuration will process incoming `remote_addr`, and append country information retrieved from GeoLite2 database.

```text
[INPUT]
    Name   dummy
    Dummy  {"remote_addr": "8.8.8.8"}

[FILTER]
    Name geoip2
    Match *
    Database GeoLite2-City.mmdb
    Lookup_key remote_addr
    Record country remote_addr %{country.names.en}
    Record isocode remote_addr %{country.iso_code}

[OUTPUT]
    Name   stdout
    Match  *
```

Each `Record` parameter above specifies the following triplet:

1. The field name to be added to records \(`country`\)
2. The lookup key to process \(`remote_addr`\)
3. The query for GeoIP2 database \(`%{country.names.en}`\)

By running Fluent Bit with the configuration above, you will see the following output:

```javascript
{"remote_addr": "8.8.8.8", "country": "United States", "isocode": "US"}
```

Note that the `GeoLite2-City.mmdb` database is available from [MaxMind's official site](https://dev.maxmind.com/geoip/geoip2/geolite2/).

