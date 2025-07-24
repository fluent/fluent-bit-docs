# Contribution guide for beginners

If you have some knowledge of C, this guide should help you understand how to make code changes to Fluent Bit.

## Libraries

Most external libraries are embedded in the project in the [/lib](https://github.com/fluent/fluent-bit/tree/master/lib) folder. To keep its footprint low and maximize compatibility in cross-platform builds, Fluent Bit attempts to keep its dependency graph small.

The external library that you're mostly likely to interact with is [MessagePack](https://github.com/msgpack/msgpack-c).

For cryptographic support, Fluent Bit uses the system installed version of OpenSSL. You must install OpenSSL libraries and headers before Building Fluent Bit.

### Memory management

When you write Fluent Bit code, you'll use the Fluent Bit versions of the standard C functions for working with memory:

* [`flb_malloc()`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_mem.h): Equivalent to `malloc`, allocates memory.
* [`flb_calloc()`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_mem.h): Equivalent to `calloc`, allocates memory and initializes it to zero.
* [`flb_realloc()`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_mem.h): Equivalent to `realloc`.
* [`flb_free()`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_mem.h): Equivalent to `free`, releases allocated memory.

{% hint style="info" %}
Many types have specialized create and destroy functions, like [`flb_sds_create()` and `flb_sds_destroy()`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_sds.h).
{% endhint %}

### Strings

Fluent Bit has a stripped down version of the popular [SDS](https://github.com/antirez/sds) string library. See [`flb_sds.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_sds.h) for the API.

In general, you should use SDS strings in any string processing code. SDS strings are fully compatible with any C function that accepts a null-terminated sequence of characters. To understand how they work, see the [explanation on Github](https://github.com/antirez/sds#how-sds-strings-work).

### HTTP client

Fluent Bit has its own network connection library. The key types and functions are defined in the following header files:

* [`flb_upstream.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_upstream.h)
* [`flb_http_client.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_http_client.h)
* [`flb_io.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_io.h)

The following code demonstrates an HTTP request in Fluent Bit:

```c
#include <fluent-bit/flb_upstream.h>
#include <fluent-bit/flb_io.h>
#include <fluent-bit/flb_http_client.h>
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_config.h>

#define HOST  "127.0.0.1"
#define PORT  80

static flb_sds_t make_request(struct flb_config *config)
{
    struct flb_upstream *upstream;
    struct flb_http_client *client;
    size_t b_sent;
    int ret;
    struct flb_upstream_conn *u_conn;
    flb_sds_t resp;

    /* Create an 'upstream' context */
    upstream = flb_upstream_create(config, HOST, PORT, FLB_IO_TCP, NULL);
    if (!upstream) {
        flb_error("[example] connection initialization error");
        return -1;
    }

    /* Retrieve a TCP connection from the 'upstream' context */
    u_conn = flb_upstream_conn_get(upstream);
    if (!u_conn) {
        flb_error("[example] connection initialization error");
        flb_upstream_destroy(upstream);
        return -1;
    }

    /* Create HTTP Client request/context */
    client = flb_http_client(u_conn,
                             FLB_HTTP_GET, metadata_path,
                             NULL, 0,
                             FLB_FILTER_AWS_IMDS_V2_HOST, 80,
                             NULL, 0);

    if (!client) {
        flb_error("[example] count not create http client");
        flb_upstream_conn_release(u_conn);
        flb_upstream_destroy(upstream);
        return -1;
    }

    /* Perform the HTTP request */
    ret = flb_http_do(client, &b_sent)

    /* Validate return status and HTTP status if set */
    if (ret != 0 || client->resp.status != 200) {
        if (client->resp.payload_size > 0) {
            flb_debug("[example] Request failed and returned: \n%s",
                      client->resp.payload);
        }
        flb_http_client_destroy(client);
        flb_upstream_conn_release(u_conn);
        flb_upstream_destroy(upstream);
        return -1;
    }

    /* Copy payload response to an output SDS buffer */
    data = flb_sds_create_len(client->resp.payload,
                              client->resp.payload_size);

    flb_http_client_destroy(client);
    flb_upstream_conn_release(u_conn);
    flb_upstream_destroy(upstream);

    return resp;
}
```

The `flb_upstream` structure represents the host/endpoint that you want to call. Normally, you'd store this structure somewhere so that it can be reused. An `flb_upstream_conn` represents a connection to that host for a single HTTP request. This connection structure shouldn't be used for more than one request.

### Linked lists

Fluent Bit contains a library for constructing linked lists: [`cfl_list`](https://github.com/fluent/fluent-bit/blob/master/lib/cfl/include/cfl/cfl_list.h). The type stores data as a circular linked list.

The [`cfl_list.h`](https://github.com/fluent/fluent-bit/blob/master/lib/cfl/include/cfl/cfl_list.h) header file contains several macros and functions for use with the lists. The following example shows how to create a list, iterate through it, and delete an element.

```c
#include <cfl/cfl.h>
#include <fluent-bit/flb_info.h>

struct item {
    char some_data;

    struct cfl_list _head;
};

static int example()
{
    struct cfl_list *tmp;
    struct cfl_list *head;
    struct cfl_list items;
    int i;
    int len;
    char characters[] = "abcdefghijk";
    struct item *an_item;

    len = strlen(characters);

    /* construct a list */
    cfl_list_init(&items);

    for (i = 0; i < len; i++) {
        an_item = flb_malloc(sizeof(struct item));
        if (!an_item) {
            flb_errno();
            return -1;
        }
        an_item->some_data = characters[i];
        cfl_list_add(&an_item->_head, &items);
    }

    /* iterate through the list */
    flb_info("Iterating through list");
    cfl_list_foreach_safe(head, tmp, &items) {
        an_item = cfl_list_entry(head, struct item, _head);
        flb_info("list item data value: %c", an_item->some_data);
    }

    /* remove an item */
    cfl_list_foreach_safe(head, tmp, &items) {
        an_item = cfl_list_entry(head, struct item, _head);
        if (an_item->some_data == 'b') {
            cfl_list_del(&an_item->_head);
            flb_free(an_item);
        }
    }
}
```

### MessagePack

Fluent Bit uses [MessagePack](https://msgpack.org/index.html) to internally store data. If you write code for Fluent Bit, it's almost certain that you will interact with MessagePack.

Fluent Bit embeds the [`msgpack-c`](https://github.com/msgpack/msgpack-c) library. The following example shows how to manipulate message pack to add a new key/value pair to a record. In Fluent Bit, the [`filter_record_modifier`](https://github.com/fluent/fluent-bit/tree/master/plugins/filter_record_modifier) plugin adds or deletes keys from records. See its code for more.

```c
#define A_NEW_KEY        "key"
#define A_NEW_KEY_LEN    3
#define A_NEW_VALUE      "value"
#define A_NEW_VALUE_LEN  5

static int cb_filter(const void *data, size_t bytes,
                     const char *tag, int tag_len,
                     void **out_buf, size_t *out_size,
                     struct flb_filter_instance *f_ins,
                     void *context,
                     struct flb_config *config)
{
    (void) f_ins;
    (void) config;
    size_t off = 0;
    int i = 0;
    int ret;
    struct flb_time tm;
    int total_records;
    int new_keys = 1;
    msgpack_sbuffer tmp_sbuf;
    msgpack_packer tmp_pck;
    msgpack_unpacked result;
    msgpack_object  *obj;
    msgpack_object_kv *kv;

    /* Create temporary msgpack buffer */
    msgpack_sbuffer_init(&tmp_sbuf);
    msgpack_packer_init(&tmp_pck, &tmp_sbuf, msgpack_sbuffer_write);

    /* Iterate over each item */
    msgpack_unpacked_init(&result);
    while (msgpack_unpack_next(&result, data, bytes, &off) == MSGPACK_UNPACK_SUCCESS) {
        /*
         * Each record is a msgpack array [timestamp, map] of the
         * timestamp and record map. We 'unpack' each record, and then re-pack
         * it with the new fields added.
         */

        if (result.data.type != MSGPACK_OBJECT_ARRAY) {
            continue;
        }

        /* unpack the array of [timestamp, map] */
        flb_time_pop_from_msgpack(&tm, &result, &obj);

        /* obj should now be the record map */
        if (obj->type != MSGPACK_OBJECT_MAP) {
            continue;
        }

        /* re-pack the array into a new buffer */
        msgpack_pack_array(&tmp_pck, 2);
        flb_time_append_to_msgpack(&tm, &tmp_pck, 0);

        /* new record map size is old size + the new keys we will add */
        total_records = obj->via.map.size + new_keys;
        msgpack_pack_map(&tmp_pck, total_records);

        /* iterate through the old record map and add it to the new buffer */
        kv = obj->via.map.ptr;
        for(i=0; i < obj->via.map.size; i++) {
            msgpack_pack_object(&tmp_pck, (kv+i)->key);
            msgpack_pack_object(&tmp_pck, (kv+i)->val);
        }

        /* append new keys */
        msgpack_pack_str(&tmp_pck, A_NEW_KEY_LEN);
        msgpack_pack_str_body(&tmp_pck, A_NEW_KEY, A_NEW_KEY_LEN);
        msgpack_pack_str(&tmp_pck, A_NEW_VALUE_LEN);
        msgpack_pack_str_body(&tmp_pck, A_NEW_VALUE, A_NEW_VALUE_LEN);

    }
    msgpack_unpacked_destroy(&result);

    /* link new buffers */
    *out_buf  = tmp_sbuf.data;
    *out_size = tmp_sbuf.size;
    return FLB_FILTER_MODIFIED;
```

For more info, see the MessagePack examples in the [msgpack-c GitHub repository](https://github.com/msgpack/msgpack-c).

## Plugin API

Each plugin is a shared object which is [loaded into Fluent Bit](https://github.com/fluent/fluent-bit/blob/1.3/src/flb_plugin.c#L70) using `dlopen`and `dlsym`.

### Input

The input plugin structure is defined in [`flb_input.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_input.h#L62). There are a number of functions which a plugin can implement, but most only implement `cb_init`, `cb_collect`, and `cb_exit`.

The [`"dummy"` input plugin](https://github.com/fluent/fluent-bit/tree/master/plugins/in_dummy) is very basic and is an excellent example to review to understand more.

Input plugins can use threaded mode if the flag `FLB_INPUT_THREADED` is provided.
To enable threading in your plugin, add the `FLB_INPUT_THREADED` to the set of `flags` when registering:

```c
struct flb_input_plugin in_your_example_plugin = {
    .name         = "your example",
    .description  = "Ingest example data",
    .cb_init      = in_your_example_init,
    .cb_pre_run   = NULL,
    .cb_collect   = in_your_example_collect,
    .cb_flush_buf = NULL,
    .config_map   = config_map,
    .cb_pause     = in_your_example_pause,
    .cb_resume    = in_example_resume,
    .cb_exit      = in_example_exit,
    .flags        = FLB_INPUT_THREADED
};
```

### Filter

The structure for filter plugins is defined in [`flb_filter.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_filter.h#L44). Each plugin must implement `cb_init`, `cb_filter`, and `cb_exit`.

The [`filter_record_modifier`](https://github.com/fluent/fluent-bit/tree/master/plugins/filter_record_modifier) is a good example of a filter plugin.

Filter plugins can not asynchronously make HTTP requests. If your plugin needs to make a request, add the following code when you initialize your `flb_upstream`:

```c
/* Remove async flag from upstream */
upstream->flags &= ~(FLB_IO_ASYNC);
```

### Output

Output plugins are defined in [`flb_output.h`](https://github.com/fluent/fluent-bit/blob/master/include/fluent-bit/flb_output.h#L57). Each plugin must implement `cb_init`, `cb_flush`, and `cb_exit`.

The [stdout plugin](https://github.com/fluent/fluent-bit/tree/master/plugins/out_stdout) is very basic; review its code to understand how output plugins work.

## Development environment

Fluent Bit provides a standalone environment for development. Developers who use different operating systems or distributions can develop on a basic, common stack. The development environment provides the required libraries and tools for you.

Development environments are provided for:
- [Devcontainer](https://github.com/fluent/fluent-bit/blob/master/DEVELOPER_GUIDE.md#devcontainer)
- [Vagrant](https://github.com/fluent/fluent-bit/blob/master/DEVELOPER_GUIDE.md#vagrant).

## Testing

During development, you can build Fluent Bit as follows:

```text
cd build
cmake -DFLB_DEV=On ../
make
```

{% hint style="info" %}
Fluent Bit uses CMake 3. On some systems you might need to invoke it as `cmake3`.
{% endhint %}

To enable the unit tests, run the following command:

```text
cmake -DFLB_DEV=On -DFLB_TESTS_RUNTIME=On -DFLB_TESTS_INTERNAL=On ../
make
```

Internal tests are for the internal libraries of Fluent Bit. Runtime tests are for the plugins.

You can run the unit tests with `make test`. However, this is inconvenient in practice. Each test file will create an executable in the `build/bin` directory, which you can run directly. For example, if you want to run the SDS tests, you can invoke them as follows:

```text
$ ./bin/flb-it-sds
Test sds_usage...                               [   OK   ]
Test sds_printf...                              [   OK   ]
SUCCESS: All unit tests have passed.
```
