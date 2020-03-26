---
description: The Production Grade Ecosystem
---

# Fluentd & Fluent Bit

Logging and data processing in general can be complex, and at scale a bit more, that's why [Fluentd](https://www.fluentd.org) was born. But now is more than a simple tool, it's a full ecosystem that contains SDKs for different languages and sub projects like [Fluent Bit](https://fluentbit.io). 

On this page, we will describe the relationship between the [Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) open source projects, as a summary we can say both are:

* Licensed under the terms of Apache License v2.0
* Hosted projects by the [Cloud Native Computing Foundation \(CNCF\)](https://cncf.io)
* Production Grade solutions: deployed **thousands** of times every single day, **millions** per ****month.
* Community driven projects
* Widely Adopted by the Industry: trusted by all major companies like AWS, Microsoft, Google Cloud and hundred of others.
* Originally created by [Treasure Data](https://www.treasuredata.com). 

Both projects share a lot of similarities, Fluent Bit is fully designed and built on top of the best ideas of Fluentd architecture and general design. Choosing which one to use depends on the end-user needs.

The following table describes a comparison in different areas of the projects:

|  | Fluentd | Fluent Bit |
| :--- | :--- | :--- |
| Scope | Containers / Servers | Embedded Linux / Containers / Servers |
| Language | C & Ruby | C |
| Memory | ~40MB | ~650KB |
| Performance | High Performance | High Performance |
| Dependencies | Built as a Ruby Gem, it requires a certain number of gems. | Zero dependencies, unless some special plugin requires them. |
| Plugins | More than 1000 plugins available | Around 50 plugins available |
| License | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) |

Both Fluentd and Fluent Bit can work as Aggregators of Forwarders, they both can complement each other or use them as standalone solutions. 

