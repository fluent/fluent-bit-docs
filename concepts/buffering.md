# Buffering

  
The end-goal of [Fluent Bit](https://fluentbit.io/) is to collect, parse, filter and ship logs to a central place. In this workflow there are many phases and one of the critical pieces is the ability to do _buffering_ : a mechanism to place processed data into a temporal location until is ready to be shipped.

By default when Fluent Bit process data, it uses Memory as a primary and temporal place to store the record logs, but there are certain scenarios where would be ideal to have a persistent buffering mechanism based in the filesystem to provide aggregation and data safety capabilities.

Starting with Fluent Bit v1.0, we introduced a new _storage layer_ that can either work in memory or in the file system. Input plugins can be configured to use one or the other upon demand at start time.

