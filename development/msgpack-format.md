# MessagePack format

Fluent Bit always handles every Event message as a structured message using a binary serialization data format called [MessagePack](https://msgpack.org/).

## Fluent Bit usage

MessagePack is a standard and well-defined format, refer to the official documentation for full details.
This section provides an overview of the specific types used by Fluent Bit within the format to help anyone consuming it.

- The data structure used by Fluent Bit is a 2-length [`fixarray`](https://github.com/msgpack/msgpack/blob/master/spec.md#array-format-family) of the timestamp and the data.
- The timestamp comes from [`flb_time_append_to_msgpack`](https://github.com/fluent/fluent-bit/blob/2138cee8f4878733956d42d82f6dcf95f0aa9339/src/flb_time.c#L197), so it's either a `uint64`, a `float64`, or a [`fixext`](https://github.com/msgpack/msgpack/blob/master/spec.md#ext-format-family) where the 4 MSBs are the seconds (big-endian `uint32`) and 4 LSBs are nanoseconds.
- The data itself is a [`msgpack` map](https://github.com/msgpack/msgpack/blob/master/spec.md#map-format-family) with the keys as strings.

## Example

Set up Fluent Bit to send in `msgpack` format to a specific port.

```bash
docker run --rm -it --network=host fluent/fluent-bit /fluent-bit/bin/fluent-bit -i cpu -o tcp://127.0.0.1:5170 -p format=msgpack -v
```

You could send this to stdout but as it's a serialized format you would end up with strange output.
As an example, use the [Python `msgpack` library](https://msgpack.org/#languages) to handle it:

```python
#Python3
import socket
import msgpack

unpacker = msgpack.Unpacker(use_list=False, raw=False)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 5170))
s.listen(1)
connection, address = s.accept()

while True:
    data = connection.recv(1024)
    if not data:
        break
    unpacker.feed(data)
    for unpacked in unpacker:
        print(unpacked)
```

Now make sure to install `msgpack` for Python (3) and then run up your test code:

```bash
$ pip install msgpack
$ python3 test.py
(ExtType(code=0, data=b'b\n5\xc65\x05\x14\xac'), {'cpu_p': 0.1875, 'user_p': 0.125, 'system_p': 0.0625, 'cpu0.p_cpu': 0.0, 'cpu0.p_user': 0.0, 'cpu0.p_system': 0.0, 'cpu1.p_cpu': 0.0, 'cpu1.p_user': 0.0, 'cpu1.p_system': 0.0, 'cpu2.p_cpu': 1.0, 'cpu2.p_user': 0.0, 'cpu2.p_system': 1.0, 'cpu3.p_cpu': 0.0, 'cpu3.p_user': 0.0, 'cpu3.p_system': 0.0, 'cpu4.p_cpu': 0.0, 'cpu4.p_user': 0.0, 'cpu4.p_system': 0.0, 'cpu5.p_cpu': 0.0, 'cpu5.p_user': 0.0, 'cpu5.p_system': 0.0, 'cpu6.p_cpu': 0.0, 'cpu6.p_user': 0.0, 'cpu6.p_system': 0.0, 'cpu7.p_cpu': 0.0, 'cpu7.p_user': 0.0, 'cpu7.p_system': 0.0, 'cpu8.p_cpu': 0.0, 'cpu8.p_user': 0.0, 'cpu8.p_system': 0.0, 'cpu9.p_cpu': 1.0, 'cpu9.p_user': 1.0, 'cpu9.p_system': 0.0, 'cpu10.p_cpu': 0.0, 'cpu10.p_user': 0.0, 'cpu10.p_system': 0.0, 'cpu11.p_cpu': 0.0, 'cpu11.p_user': 0.0, 'cpu11.p_system': 0.0, 'cpu12.p_cpu': 0.0, 'cpu12.p_user': 0.0, 'cpu12.p_system': 0.0, 'cpu13.p_cpu': 0.0, 'cpu13.p_user': 0.0, 'cpu13.p_system': 0.0, 'cpu14.p_cpu': 0.0, 'cpu14.p_user': 0.0, 'cpu14.p_system': 0.0, 'cpu15.p_cpu': 0.0, 'cpu15.p_user': 0.0, 'cpu15.p_system': 0.0})

```
