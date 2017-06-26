# Unit Sizes

Certain configuration directives in Fluent Bit refers to unit sizes such as when defining the size of a buffer or specific limits, we can find these in plugins like [Tail Input](../input/tail.md), [Forward Input](../input/forward.md) or in generic properties like [Mem_Buf_Limit](backpressure.md).

Starting from [Fluent Bit](http://fluentbit.io) v0.11.10, all unit sizes have been standarizes across the core and plugins, the following table describe the options that can be used and what do they mean:

| Suffix           | Description       | Example |
|------------------|-------------------|---------|
|                  | When a suffix is __not__ specified, it's assumed that the value given is a bytes representation. | Specifying a value of 32000, means 32000 bytes|
| k                | Kilobyte: a unit of memory equal to 1,024 bytes. | 32k means 32728 bytes. |
| M                | Megabyte: a unit of memory equal to 1,048,576 bytes | 1M means 1024000 bytes |
| G                | Gigabyte: a unit of memory equal to 1,073,741,824 bytes | 1G means 1073741824 bytes |
