---
description: Look up Geo data from IP.
---

# GeoIP2 filter

The GeoIP2 filter lets you enrich the incoming data stream with location data from the GeoIP2 database.

The `GeoLite2-City.mmdb` database is available from [MaxMind's official site](https://dev.maxmind.com/geoip/geoip2/geolite2/).

## Configuration parameters

This plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| `database` | Path to the GeoIP2 database. |
| `lookup_key` | Field name to process. |
| `record` | Defines the `KEY LOOKUP_KEY VALUE` triplet. |

## Get started

The following configuration processes the incoming `remote_addr` and appends country information retrieved from the GeoLite2 database.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: {"remote_addr": "8.8.8.8"}

  filters:
    - name: geoip2
      match: '*'
      database: GeoLite2-City.mmdb
      lookup_key: remote_addr
      record:
        - country remote_addr %{country.names.en}
        - isocode remote_addr %{country.iso_code}

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

Each `Record` parameter specifies the following triplet:

- `country`: The field name to be added to records.
- `remote_addr`: The lookup key to process.
- `%{country.names.en}`: The GeoIP2 database query.

By running Fluent Bit with this configuration, you will see the following output:

```text
{"remote_addr": "8.8.8.8", "country": "United States", "isocode": "US"}
```
