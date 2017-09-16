# Fluentd and Fluent Bit

Data collection matters and nowadays the scenarios from where the information can _come from_ are very variable. For hence to be more flexible on certain markets needs, we may need different options. On this page we will describe the relationship between the [Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) open source projects.

[Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) projects are both created and sponsored by [Treasure Data](http://treasuredata.com) and they aim to solve the _collection_, _processing_ and _delivery_ of Logs.

Both projects shares a lot of similarities, Fluent Bit is fully based in the design and experience of Fluentd architecture and general design. Choosing which one to use depends of the final needs, from an architecture perspective we can consider:

- Fluentd is a log collector, processor and aggregator.
- Fluent Bit is a log collector and processor (it dont' have strong aggregation features such as Fluentd).

The following table describe a comparisson on different areas of the projects:

|                       | Fluentd               | Fluent Bit            |
|-----------------------|-----------------------|-----------------------|
| Scope                 | Containers / Servers  | Containers / Servers  |
| Language              | C & Ruby              | C                     |
| Memory                | ~40MB                 | ~450KB                |
| Performance           | High Performance      | High Performance      |
| Dependencies          | Built as a Ruby Gem, it requires a certain number of gems. | Zero dependencies, unless some special plugin requires them. |
| Plugins               | More than 650 plugins available | Around 35 plugins available|
| License               | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0)|

Considering Fluentd as a main Aggregator and Fluent Bit as a Log Forwarder, we can see both projects complement each other providing a full reliable solution.
