# Unit sizes

Some configuration directives in [Fluent Bit](http://fluentbit.io) refer to unit sizes such as when defining the size of a buffer or specific limits. Plugins like [Tail Input](../../pipeline/inputs/tail.md), [Forward Input](../../pipeline/inputs/forward.md), or generic properties like [`Mem_Buf_Limit`](../backpressure.md) use unit sizes.

Fluent Bit v0.11.10 standardized unit sizes across the core and plugins. The following table describes the options that can be used and what they mean:

| Suffix | Description | Example |
| :--- | :--- | :--- |
|  | When a suffix isn't specified, assume that the value given is a bytes representation. | Specifying a value of `32000` means 32000 bytes. |
| `k`, `K`, `KB`, `kb` | Kilobyte: a unit of memory equal to 1,000 bytes. | `32k` means 32000 bytes. |
| `m`, `M`, `MB`, `mb` | Megabyte: a unit of memory equal to 1,000,000 bytes. | `1M` means 1000000 bytes. |
| `g`, `G`, `GB`, `gb` | Gigabyte: a unit of memory equal to 1,000,000,000 bytes. | `1G` means 1000000000 bytes. |
