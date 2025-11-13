---
description: Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
---

# What is Fluent Bit?

[Fluent Bit](https://fluentbit.io) is an open source telemetry agent specifically designed to efficiently handle the challenges of collecting and processing telemetry data across a wide range of environments, from constrained systems to complex cloud infrastructures. Managing telemetry data from various sources and formats can be a constant challenge, particularly when performance is a critical factor.

Rather than serving as a drop-in replacement, Fluent Bit enhances the observability strategy for your infrastructure by adapting and optimizing your existing logging layer, and adding metrics and traces processing. Fluent Bit supports a vendor-neutral approach, seamlessly integrating with other ecosystems such as Prometheus and OpenTelemetry. Trusted by major cloud providers, banks, and companies in need of a ready-to-use telemetry agent solution, Fluent Bit effectively manages diverse data sources and formats while maintaining optimal performance and keeping resource consumption low.

Fluent Bit can be deployed as an edge agent for localized telemetry data handling or utilized as a central aggregator/collector for managing telemetry data across multiple sources and environments.

{% embed url="https://www.youtube.com/watch?v=3ELc1helke4" %}

## The history of Fluent Bit

In 2014, the [Fluentd](https://www.fluentd.org/) team at [Treasure Data](https://www.treasuredata.com/) was forecasting the need for a lightweight log processor for constraint environments like embedded Linux and gateways. To meet this need, Eduardo Silva created Fluent Bit, a new open-source solution and part of the Fluentd ecosystem.

After the project matured, it gained traction for normal Linux systems. With the new containerized world, the cloud native community asked to extend the project scope to support more sources, filters, and destinations. Not long after, Fluent Bit became one of the preferred solutions to solve the logging challenges in cloud environments.
