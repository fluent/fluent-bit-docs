---
description: >-
  There are a few key concepts that are really important to understand how
  Fluent Bit operates.
---

# Key Concepts

Before diving into [Fluent Bit](https://fluentbit.io) it’s good to get acquainted with some of the key concepts of the service. This document provides a gentle introduction to those concepts and common [Fluent Bit](https://fluentbit.io) terminology. We’ve provided a list below of all the terms we’ll cover, but we recommend reading this document from start to finish to gain a more general understanding of our log and stream processor.

* Event or Record
* Filtering
* Tag
* Timestamp
* Match
* Structured Message

### Event or Record

Every incoming piece of data that belongs to a log or a metric that is retrieved by Fluent Bit is considered an Event or a Record. 

As an example consider the following content of a Syslog file:

```text
Jan 18 12:52:16 flb systemd[2222]: Starting GNOME Terminal Server
Jan 18 12:52:16 flb dbus-daemon[2243]: [session uid=1000 pid=2243] Successfully activated service 'org.gnome.Terminal'
Jan 18 12:52:16 flb systemd[2222]: Started GNOME Terminal Server.
Jan 18 12:52:16 flb gsd-media-keys[2640]: # watch_fast: "/org/gnome/terminal/legacy/" (establishing: 0, active: 0)
```

It contains four lines and all of them represents **four** independent Events. 

Internally, an Event always has two components \(in an array form\):

```javascript
[TIMESTAMP, MESSAGE]
```

### Filtering

In some cases is required to perform modifications on the Events content,  the process to alter, enrich or drop Events is called Filtering. 

There are many use cases when Filtering is required like:

* Append specific information to the Event like an IP address or metadata.
* Select a specific piece of the Event content.
* Drop Events that matches certain pattern.

### Tag

Every Event that gets into Fluent Bit gets assigned a Tag. This tag is an internal string that is used in a later stage by the Router to decide which Filter or Output phase it must go through.

Most of the tags are assigned manually in the configuration. If a tag is not specified, Fluent Bit will assign the name of the Input plugin instance from where that Event was generated from.

{% hint style="info" %}
The only input plugin that **don't** assign Tags is Forward input. This plugin speaks the Fluentd wire protocol called Forward where every Event already comes with a Tag associated. Fluent Bit will always use the incoming Tag set by the client.
{% endhint %}

### Timestamp

The Timestamp represents the _time_ when an Event was created. Every Event contains a Timestamp associated. The Timestamp is a numeric fractional integer in the format:

```javascript
SECONDS.NANOSECONDS
```

#### Seconds

It is the number of seconds that have elapsed since the _Unix epoch._

#### Nanoseconds

Fractional second or one thousand-millionth of a second.

{% hint style="info" %}
A timestamp always exists, either set by the Input plugin or discovered through a data parsing process.
{% endhint %}

### Match

Fluent Bit allows to deliver your collected and processed Events to one or multiple destinations, this is done through a routing phase. A Match represent a simple rule to select Events where it Tags maches a defined rule.

FIXME: More about Tag and Matchs in the Routing section.

### Structured Message

Events can have or not have a structure. A structure defines a set of _keys_ and _values_ inside the Event message. As an example consider the following two messages:

#### No structured message

```javascript
"Project Fluent Bit created on 1398289291"
```

#### Structured Message

```javascript
{"project": "Fluent Bit", "created": 1398289291}
```

At a low level both are just an array of bytes, but the Structured message defines _keys_ and _values_, having a structure helps to implement faster operations on data modifications.

{% hint style="info" %}
Fluent Bit **always** handle every Event message as a structured message. For performance reasons, we use a binary serialization data format called [MessagePack](https://msgpack.org/). 

Consider [MessagePack](https://msgpack.org/) as a binary version of JSON on steroids. 
{% endhint %}

