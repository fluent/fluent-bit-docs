# Unit Sizes

Certain configuration directives in Fluent Bit refer to unit sizes such as when defining the size of a buffer or specific limits, we can find these in plugins like [Tail Input](https://github.com/fluent/fluent-bit-docs/tree/5f926fd1330690179b8c1edab90d672699599ec7/administration/input/tail.md), [Forward Input](https://github.com/fluent/fluent-bit-docs/tree/5f926fd1330690179b8c1edab90d672699599ec7/administration/input/forward.md) or in generic properties like [Mem\_Buf\_Limit](https://github.com/fluent/fluent-bit-docs/tree/5f926fd1330690179b8c1edab90d672699599ec7/administration/configuring-fluent-bit/backpressure.md).

Starting from [Fluent Bit](http://fluentbit.io) v0.11.10, all unit sizes have been standardized across the core and plugins, the following table describes the options that can be used and what they mean:

| Suffix | Description | Example |
| :--- | :--- | :--- |
|  | When a suffix is **not** specified, it's assumed that the value given is a bytes representation. | Specifying a value of 32000, means 32000 bytes |
| k, K, KB, kb | Kilobyte: a unit of memory equal to 1,000 bytes. | 32k means 32000 bytes. |
| m, M, MB, mb | Megabyte: a unit of memory equal to 1,000,000 bytes | 1M means 1000000 bytes |
| g, G, GB, gb | Gigabyte: a unit of memory equal to 1,000,000,000 bytes | 1G means 1000000000 bytes |

