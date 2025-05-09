# C library API

Fluent Bit is written in C and can be used from any C or C++ application.

## Workflow

Fluent Bit runs as a service, which means that the exposed API provides interfaces to create and manage contexts, specify inputs and outputs, set configuration parameters, and set routing paths for events or records. A typical usage of this library involves:

* Creating library instance and contexts and setting their properties.
* Enabling input plugins and setting their properties.
* Enabling output plugins and setting their properties.
* Starting the library runtime.
* Optionally ingesting records manually.
* Stopping the library runtime.
* Destroying library instances and contexts.

## Data types

There is only one data type exposed by the library. By convention, this data type is prefixed with `flb_`.

| Type | Description |
| :--- | :--- |
| `flb_ctx_t` | Main library context. This references the context returned by `flb_create();`. |

## API reference

### Library context creation

Use the `flb_create()` function to create library context.

#### Prototype

```c
flb_ctx_t *flb_create();
```

#### Return value

On success, this function returns the library context. On error, it returns `NULL`.

#### Usage

```c
flb_ctx_t *ctx;

ctx = flb_create();
if (!ctx) {
    return NULL;
}
```

### Set service properties

Use the `flb_service_set()` function to set context properties.

#### Prototype

```c
int flb_service_set(flb_ctx_t *ctx, ...);
```

#### Return value

On success, this function returns `0`. On error, it returns a negative number.

#### Usage

This function sets one or more properties as a key/value string. For example:

```c
int ret;

ret = flb_service_set(ctx, "Flush", "1", NULL);
```

This example specified the values for the property `Flush`. Its value is always a string (`char *`), and after all parameters are listed, you must add a `NULL` argument at the end of the list.

### Enable input plugin instance

The Fluent Bit library contains several input plugins. To enable an input plugin, use the `flb_input()` function to create an instance of it.

{% hint style="info" %}
For plugins, an _instance_ means a context of the plugin enabled. You can create multiple instances of the same plugin.
{% endhint %}

#### Prototype

```c
int flb_input(flb_ctx_t *ctx, char *name, void *data);
```

The argument `ctx` represents the library context created by `flb_create()`, and `name` is the name of the input plugin to enable.

The argument `data` can be used to pass a custom reference to the plugin instance. This is mostly used by custom or third-party plugins. For generic plugins, it's okay to pass `NULL`.

#### Return value

On success, this function returns an integer value greater than or equal to zero, similar to a file descriptor. On error, it returns a negative number.

#### Usage

```c
int in_ffd;

in_ffd = flb_input(ctx, "cpu", NULL);
```

### Set input plugin properties

A plugin instance created through `flb_input()` can include configuration properties. Use the `flb_input_set()` function to set these properties.

#### Prototype

```c
int flb_input_set(flb_ctx_t *ctx, int in_ffd, ...);
```

#### Return value

On success, this function returns `0`. On error, it returns a negative number.

#### Usage

This function sets one or more properties as a key/value string. For example:

```c
int ret;

ret = flb_input_set(ctx, in_ffd,
                    "tag", "my_records",
                    "ssl", "false",
                    NULL);
```

The argument `ctx` represents the library context created by `flb_create()`. The previous example specified the values for the properties `tag` and `ssl`. Its value is always a string (`char *`), and after all parameters are listed, you must add a `NULL` argument at the end of the list.

The properties allowed per input plugin are specified in the documentation for each plugin.

### Enable output plugin instance

The Fluent Bit library contains several output plugins. To enable an output plugin, use the `flb_output()` function to create an instance of it.

{% hint style="info" %}
For plugins, an _instance_ means a context of the plugin enabled. You can create multiple instances of the same plugin.
{% endhint %}

#### Prototype

```c
int flb_output(flb_ctx_t *ctx, char *name, void *data);
```

The argument `ctx` represents the library context created by `flb_create()`, and `name` is the name of the output plugin to enable.

The argument `data` can be used to pass a custom reference to the plugin instance. This is mostly used by custom or third-party plugins. For generic plugins, it's okay to pass `NULL`.

#### Return value

On success, this function returns the output plugin instance. On error, it returns a negative number.

#### Usage

```c
int out_ffd;

out_ffd = flb_output(ctx, "stdout", NULL);
```

### Set output plugin properties

A plugin instance created through `flb_output()` can include configuration properties. Use the `flb_output_set()` function to set these properties.

#### Prototype

```c
int flb_output_set(flb_ctx_t *ctx, int out_ffd, ...);
```

#### Return value

On success, this function returns and integer value greater than or equal to zero, similar to a file descriptor. On error, it returns a negative number.

#### Usage

This function sets one or more properties as a key/value string. For example:

```c
int ret;

ret = flb_output_set(ctx, out_ffd,
                     "tag", "my_records",
                     "ssl", "false",
                     NULL);
```

The argument `ctx` represents the library context created by `flb_create()`. The previous example specified the values for the properties `tag` and `ssl`. Its value is always a string (`char *`), and after all parameters are listed, you must add a `NULL` argument at the end of the list.

The properties allowed per output plugin are specified in the documentation for each plugin.

## Start Fluent Bit engine

After you create the library context and set input and output plugin instances, use the `flb_start()` function to start the engine. After the engine has started, it runs inside a new thread (POSIX thread) without blocking the caller application.

### Prototype

```c
int flb_start(flb_ctx_t *ctx);
```

### Return value

On success, this function returns `0`. On error, it returns a negative number.

### Usage

This function uses the `ctx` argument, which is a reference to the context created by `flb_create()`.

```c
int ret;

ret = flb_start(ctx);
```

## Stop Fluent Bit engine

To stop a running Fluent Bit engine, use `flb_stop()`.

### Prototype

```c
int flb_stop(flb_ctx_t *ctx);
```

The argument `ctx` is a reference to the context created by `flb_create()` and started by `flb_start()`.

When the call is invoked, the engine waits a maximum of five seconds to flush buffers and release any resources in use. A stopped context can be restarted at any time, but without any data on it.

### Return value

On success, this function returns `0`. On error, it returns a negative number.

### Usage

```c
int ret;

ret = flb_stop(ctx);
```

## Destroy library context

You can destroy a library context after it's no longer necessary. A previous `flb_stop()` call is mandatory. After a library context is destroyed, all associated resources are released.

### Prototype

```c
void flb_destroy(flb_ctx_t *ctx);
```

The argument `ctx` is a reference to the context created by `flb_create()`.

### Return value

This function doesn't return a value.

### Usage

```c
flb_destroy(ctx);
```

## Ingest data manually

In some cases, the caller application might want to ingest data into Fluent Bit. You can use the `flb_lib_push()` function to do so.

### Prototype

```c
int flb_lib_push(flb_ctx_t *ctx, int in_ffd, void *data, size_t len);
```

The first argument is the context created through `flb_create()`. The `in_ffd` argument is the numeric reference of the input plugin, which in this case is a `lib` input plugin. The `data` argument is a reference to the message to be ingested, and the `len` argument is the number of bytes to take from it.

### Return value

On success, this function returns the number of bytes written. On error, it returns `-1`.

### Usage

For more information about how to use this function, including examples, see [Ingest Records Manually](ingest-records-manually.md).
