# Fluentd & Fluent Bit

Data collection matters and nowadays the scenarios from where the information can _come from_ are very variable. For hence to be more flexible on certain markets needs, we may need different options. On this page we will describe the relationship between the [Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) open source projects.

[Fluentd](http://fluentd.org) and [Fluent Bit](http://fluentbit.io) projects are both created and sponsored by [Treasure Data](http://treasuredata.com) and they aim to solve the _Data Collection_ and _Data Forwarding_ needs as a whole.

From an architecture usability perspective:

* Fluentd is an Aggregator.
* Fluent Bit is a Data Forwarder.

The following table describe a comparisson on different areas of the projects:

|  | Fluentd | Fluent Bit |
| :--- | :--- | :--- |
| Scope | Containers / Servers | Containers / Servers |
| Language | C & Ruby | C |
| Memory | ~40MB | ~250KB |
| Performance | High Performance | High Performance |
| Dependencies | Built as a Ruby Gem, it requires a certain number of gems. | Zero dependencies, unless some special plugin requires them. |
| Plugins | More than 650 plugins available | Around 20 plugins available |
| License | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) | [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0) |

Considering Fluentd as a main Aggregator and Fluent Bit as a Data Forwarder, we can see both projects complement each other providing a full reliable solution.

