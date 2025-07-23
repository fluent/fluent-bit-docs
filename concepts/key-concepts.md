---
description: Learn these key concepts to understand how Fluent Bit operates.
---

# Key concepts

Before diving into [Fluent Bit](https://fluentbit.io) you might want to get acquainted with some of the key concepts of the service. This document provides an introduction to those concepts and common [Fluent Bit](https://fluentbit.io) terminology. Reading this document will help you gain a more general understanding of the following topics:

- Event or Record
- Filtering
- Tag
- Timestamp
- Match
- Structured Message

## Event or Record

Every incoming piece of data that belongs to a log or a metric that's retrieved by Fluent Bit is considered an _Event_ or a _Record_.

As an example, consider the following content of a Syslog file:

```text
Jan 18 12:52:16 flb systemd[2222]: Starting GNOME Terminal Server
Jan 18 12:52:16 flb dbus-daemon[2243]: [session uid=1000 pid=2243] Successfully activated service 'org.gnome.Terminal'
Jan 18 12:52:16 flb systemd[2222]: Started GNOME Terminal Server.
Jan 18 12:52:16 flb gsd-media-keys[2640]: # watch_fast: "/org/gnome/terminal/legacy/" (establishing: 0, active: 0)
```

It contains four lines that represent four independent Events.

An Event is comprised of:

- timestamp
- key/value metadata (v2.1.0 and greater)
- payload

### Event format

The Fluent Bit wire protocol represents an Event as a two-element array with a nested array as the first element:

```javascript copy
[[TIMESTAMP, METADATA], MESSAGE]
```

where

- _`TIMESTAMP`_ is a timestamp in seconds as an integer or floating point value (not a string).
- _`METADATA`_ is an object containing event metadata, and might be empty.
- _`MESSAGE`_ is an object containing the event body.

Fluent Bit versions prior to v2.1.0 used:

```javascript
[TIMESTAMP, MESSAGE]
```

to represent events. This format is still supported for reading input event streams.

## Filtering

You might need to perform modifications on an Event's content. The process to alter, append to, or drop Events is called [_filtering_](data-pipeline/filter.md).

Use filtering to:

- Append specific information to the Event like an IP address or metadata.
- Select a specific piece of the Event content.
- Drop Events that match a certain pattern.

## Tag

Every Event ingested by Fluent Bit is assigned a Tag. This tag is an internal string used in a later stage by the Router to decide which Filter or [Output](data-pipeline/output.md) phase it must go through.

Most tags are assigned manually in the configuration. If a tag isn't specified, Fluent Bit assigns the name of the [Input](data-pipeline/input.md) plugin instance where that Event was generated from.

{% hint style="info" %}
The [Forward](../pipeline/inputs/forward.md) input plugin doesn't assign tags. This plugin speaks the Fluentd wire protocol called Forward where every Event already comes with a Tag associated. Fluent Bit will always use the incoming Tag set by the client.
{% endhint %}

A tagged record must always have a Matching rule. To learn more about Tags and Matches, see [Routing](data-pipeline/router.md).

## Timestamp

The timestamp represents the time an Event was created. Every Event contains an associated timestamps. All events have timestamps, and they're set by the input plugin or discovered through a data parsing process.

The timestamp is a numeric fractional integer in the format:

```javascript
SECONDS.NANOSECONDS
```

where:

- `_SECONDS_` is the number of seconds that have elapsed since the Unix epoch.
- `_NANOSECONDS_` is a fractional second or one thousand-millionth of a second.

## Match

Fluent Bit lets you route your collected and processed Events to one or multiple destinations. A _Match_ represents a rule to select Events where a Tag matches a defined rule.

To learn more about Tags and Matches, see [Routing](data-pipeline/router.md).

## Structured messages

Source events can have a structure. A structure defines a set of `keys` and `values` inside the Event message to implement faster operations on data modifications. Fluent Bit treats every Event message as a structured message.

Consider the following two messages:

- No structured message

  ```javascript
  "Project Fluent Bit created on 1398289291"
  ```

- With a structured message

  ```javascript
  {"project": "Fluent Bit", "created": 1398289291}
  ```

For performance reasons, Fluent Bit uses a binary serialization data format called [MessagePack](https://msgpack.org/).
