---
description: The Production Grade Telemetry Ecosystem
---

# Fluentd & Fluent Bit

Telemetry data processing in general can be complex, and at scale a bit more, that's why [Fluentd](https://www.fluentd.org) was born. Fluentd has become more than a simple tool, it has grown into a fullscale ecosystem that contains SDKs for different languages and sub-projects like [Fluent Bit](https://fluentbit.io).

On this page, we will describe the relationship between the [Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) open source projects, as a summary we can say both are:

* Licensed under the terms of Apache License v2.0
* **Graduated** Hosted projects by the [Cloud Native Computing Foundation (CNCF)](https://cncf.io)
* Production Grade solutions: deployed **million** of times every single day.
* **Vendor neutral** and community driven projects
* Widely Adopted by the Industry: trusted by all major companies like AWS, Microsoft, Google Cloud and hundreds of others.

Both projects share a lot of similarities, [Fluent Bit](https://fluentbit.io) is fully designed and built on top of the best ideas of [Fluentd](https://www.fluentd.org) architecture and general design. Choosing which one to use depends on the end-user needs.

The following table describes a comparison of different areas of the projects:

|              | Fluentd                                                           | Fluent Bit                                                        |
| ------------ | ----------------------------------------------------------------- | ----------------------------------------------------------------- |
| Scope        | Containers / Servers                                              | Embedded Linux / Containers / Servers                             |
| Language     | C & Ruby                                                          | C                                                                 |
| Memory       |  > 60MB                                                           | \~1MB                                                             |
| Performance  | Medium Performance                                                | High Performance                                                  |
| Dependencies | Built as a Ruby Gem, it requires a certain number of gems.        | Zero dependencies, unless some special plugin requires them.      |
| Plugins      | More than 1000 external plugins are available                     | More than 100 built-in plugins are available                      |
| License      | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) |

Both [Fluentd](https://www.fluentd.org) and [Fluent Bit](https://fluentbit.io) can work as Aggregators or Forwarders, they both can complement each other or use them as standalone solutions.\
\
In the recent years, Cloud Providers switched from Fluentd to Fluent Bit for performance and compatibility reasons. Fluent Bit is now considered the **next generation** solution.
