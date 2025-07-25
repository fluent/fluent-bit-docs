---
description: The production grade telemetry ecosystem
---

# Fluentd and Fluent Bit

Telemetry data processing can be complex, especially at scale. That's why [Fluentd](https://www.fluentd.org) was created. Fluentd is more than a simple tool, it's grown into a fullscale ecosystem that contains SDKs for different languages and subprojects like [Fluent Bit](https://fluentbit.io).

Here, we describe the relationship between the [Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) open source projects.

Both projects are:

- Licensed under the terms of Apache License v2.0. - Graduated hosted projects by the [Cloud Native Computing Foundation (CNCF)](https://cncf.io). - Production grade solutions: Deployed millions of times every single day. - Vendor neutral and community driven. - Widely adopted by the industry: Trusted by major companies like AWS, Microsoft, Google Cloud, and hundreds of others.

The projects have many similarities: [Fluent Bit](https://fluentbit.io) is designed and built on top of the best ideas of [Fluentd](https://www.fluentd.org) architecture and general design. Which one you choose depends on your end-users' needs.

The following table describes a comparison of different areas of the projects:

|  Attribute   | Fluentd               | Fluent Bit            |
| ------------ | --------------------- | --------------------- |
| Scope        | Containers / Servers  | Embedded Linux / Containers / Servers |
| Language     | C and Ruby            | C                                     |
| Memory       | Greater than 60&nbsp;MB | Approximately 1&nbsp;MB |
| Performance  | Medium Performance    | High Performance                      |
| Dependencies | Built as a Ruby Gem, depends on other gems. | Zero dependencies, unless required by a plugin. |
| Plugins      | Over 1,000 external plugins available. | Over 100 built-in plugins available. |
| License      | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) |

Both [Fluentd](https://www.fluentd.org) and [Fluent Bit](https://fluentbit.io) can work as Aggregators or Forwarders, and can complement each other or be used as standalone solutions.

In the recent years, cloud providers have switched from Fluentd to Fluent Bit for performance and compatibility. Fluent Bit is now considered the next-generation solution.
