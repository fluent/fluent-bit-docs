# Output Formats

Some of the output plugin's has a config field called `formats`, with a limited
amount of options are available (`json`, `json_stream`, `json_lines`, `msgpack`, `gelf`).

The specifications, or reference to external documentation of the formats, is
available in this page.

## JSON Formats

The most custom format options are the JSON types, these are three quite
common variants of sending JSON encoded data over various API's.

The example payloads below, are all "prettified" for readability.

_Records shown in example payloads, are the three first commits of the fluent-bit repository_

### json

Queued records encoded as a single JSON array of JSON encoded fluent-bit records.

#### Example payload

```json
[
  {
    "timestamp": 1398282091.000,
    "log": "Core: initialization and 32 bit fixes.",
    "commit": "b327996bfcbc0f1f47e62c862c6f303592dfacea",
    "author": "Eduardo Silva"
  },
  {
    "timestamp": 1422350608.000,
    "log": "Initial import.",
    "commit": "49269c5ec3c74411943e362cfef85052665ae97f",
    "author": "Eduardo Silva"
  },
  {
    "timestamp": 1422418113.000,
    "log": "Doc: add reference to Apache License v2.0",
    "commit": "6e09478733e8273ec216328dfc921e622740695d",
    "author": "Eduardo Silva"
  }
]
```

### json_stream

_a.k.a. Concatenated JSON_

Queued JSON-encoded fluent-bit records, with no separator between records.

#### Example payload

```json
{
  "timestamp": 1398282091.000,
  "log": "Core: initialization and 32 bit fixes.",
  "commit": "b327996bfcbc0f1f47e62c862c6f303592dfacea",
  "author": "Eduardo Silva"
}{
  "timestamp": 1422350608.000,
  "log": "Initial import.",
  "commit": "49269c5ec3c74411943e362cfef85052665ae97f",
  "author": "Eduardo Silva"
}{
  "timestamp": 1422418113.000,
  "log": "Doc: add reference to Apache License v2.0",
  "commit": "6e09478733e8273ec216328dfc921e622740695d",
  "author": "Eduardo Silva"
}
```

### json_lines

_a.k.a. Newline-Delimited JSON_

Queued JSON-encoded fluent-bit records, separated by line-breaks (`\n`).

#### Example payload

```json
{
  "timestamp": 1398282091.000,
  "log": "Core: initialization and 32 bit fixes.",
  "commit": "b327996bfcbc0f1f47e62c862c6f303592dfacea",
  "author": "Eduardo Silva"
}
{
  "timestamp": 1422350608.000,
  "log": "Initial import.",
  "commit": "49269c5ec3c74411943e362cfef85052665ae97f",
  "author": "Eduardo Silva"
}
{
  "timestamp": 1422418113.000,
  "log": "Doc: add reference to Apache License v2.0",
  "commit": "6e09478733e8273ec216328dfc921e622740695d",
  "author": "Eduardo Silva"
}
```

## msgpack

MessagePack is a binary format for serializing objects.

Please refer to the official MessagePack format specification, found here:
https://github.com/msgpack/msgpack/blob/master/spec.md

## GELF

**G**raylog **E**xtended **L**og **F**ormat is a JSON based log format which is
designed to avoid the shortcomings of classic plain syslog.

The official documentation for the GELF format can be found here:
https://archivedocs.graylog.org/en/latest/pages/gelf.html

It uses a fixed set of keys, with the addition of adding custom keys prefixed
by one single underscore character.

### Example payload

Here is an example payload, copied directly from the official docs (linked above)

```json
{
  "version": "1.1",
  "host": "example.org",
  "short_message": "A short message that helps you identify what is going on",
  "full_message": "Backtrace here\n\nmore stuff",
  "timestamp": 1385053862.3072,
  "level": 1,
  "_user_id": 9001,
  "_some_info": "foo",
  "_some_env_var": "bar"
}
```
