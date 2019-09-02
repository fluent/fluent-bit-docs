# Library API

[Fluent Bit](http://fluentbit.io) library is written in C language and can be used from any C or C++ application. Before digging into the specification it is recommended to understand the workflow involved in the runtime.

## Workflow

[Fluent Bit](http://fluentbit.io) runs as a service, meaning that the API exposed for developers provide interfaces to create and manage a context, specify inputs/outputs, set configuration parameters and set routing paths for the event/records. A typical usage of the library involves:

* Create library instance/context and set properties.
* Enable _input_ plugin\(s\) and set properties.
* Enable _output_ plugin\(s\) and set properties.
* Start the library runtime.
* Optionally ingest records manually.
* Stop the library runtime.
* Destroy library instance/context.

## Data Types

Starting from Fluent Bit v0.9, there is only one data type exposed by the library, by convention prefixed with **flb\_**.

| Type | Description |
| :--- | :--- |
| flb\_ctx\_t | Main library context. It aims to reference the context returned by _flb\_create\(\);_ |

## API Reference

### Library Context Creation

As described earlier, the first step to use the library is to create a context of it, for the purpose the function **flb\_create\(\)** is used.

**Prototype**

```c
flb_ctx_t *flb_create();
```

**Return Value**

On success, **flb\_create\(\)** returns the library context; on error, it returns NULL.

**Usage**

```c
flb_ctx_t *ctx;

ctx = flb_create();
if (!ctx) {
    return NULL;
}
```

### Set Service Properties

Using the **flb\_service\_set\(\)** function is possible to set context properties.

**Prototype**

```c
int flb_service_set(flb_ctx_t *ctx, ...);
```

**Return Value**

On success it returns 0; on error it returns a negative number.

**Usage**

The **flb\_service\_set\(\)** allows to set one or more properties in a key/value string mode, e.g:

```c
int ret;

ret = flb_service_set(ctx, "Flush", "1", NULL);
```

The above example specified the values for the properties **Flush** , note that the value is always a string \(char \*\) and once there is no more parameters a NULL argument must be added at the end of the list.

### Enable Input Plugin Instance

When built, [Fluent Bit](http://fluentbit.io) library contains a certain number of built-in _input_ plugins. In order to enable an _input_ plugin, the function **flb\_input**\(\) is used to create an instance of it.

> For plugins, an _instance_ means a context of the plugin enabled. You can create multiples instances of the same plugin.

**Prototype**

```c
int flb_input(flb_ctx_t *ctx, char *name, void *data);
```

The argument **ctx** represents the library context created by **flb\_create\(\)**, then **name** is the name of the input plugin that is required to enable.

The third argument **data** can be used to pass a custom reference to the plugin instance, this is mostly used by custom or third party plugins, for generic plugins passing _NULL_ is OK.

**Return Value**

On success, **flb\_input\(\)** returns an integer value &gt;= zero \(similar to a file descriptor\); on error, it returns a negative number.

**Usage**

```c
int in_ffd;

in_ffd = flb_input(ctx, "cpu", NULL);
```

### Set Input Plugin Properties

A plugin instance created through **flb\_input\(\)**, may provide some configuration properties. Using the **flb\_input\_set\(\)** function is possible to set these properties.

**Prototype**

```c
int flb_input_set(flb_ctx_t *ctx, int in_ffd, ...);
```

**Return Value**

On success it returns 0; on error it returns a negative number.

**Usage**

The **flb\_input\_set\(\)** allows to set one or more properties in a key/value string mode, e.g:

```c
int ret;

ret = flb_input_set(ctx, in_ffd,
                    "tag", "my_records",
                    "ssl", "false",
                    NULL);
```

The argument **ctx** represents the library context created by **flb\_create\(\)**. The above example specified the values for the properties **tag** and **ssl**, note that the value is always a string \(char \*\) and once there is no more parameters a NULL argument must be added at the end of the list.

The properties allowed per input plugin are specified on each specific plugin documentation.

### Enable Output Plugin Instance

When built, [Fluent Bit](http://fluentbit.io) library contains a certain number of built-in _output_ plugins. In order to enable an _output_ plugin, the function **flb\_output**\(\) is used to create an instance of it.

> For plugins, an _instance_ means a context of the plugin enabled. You can create multiples instances of the same plugin.

**Prototype**

```c
int flb_output(flb_ctx_t *ctx, char *name, void *data);
```

The argument **ctx** represents the library context created by **flb\_create\(\)**, then **name** is the name of the output plugin that is required to enable.

The third argument **data** can be used to pass a custom reference to the plugin instance, this is mostly used by custom or third party plugins, for generic plugins passing _NULL_ is OK.

**Return Value**

On success, **flb\_output\(\)** returns the output plugin instance; on error, it returns a negative number.

**Usage**

```c
int out_ffd;

out_ffd = flb_output(ctx, "stdout", NULL);
```

### Set Output Plugin Properties

A plugin instance created through **flb\_output\(\)**, may provide some configuration properties. Using the **flb\_output\_set\(\)** function is possible to set these properties.

**Prototype**

```c
int flb_output_set(flb_ctx_t *ctx, int out_ffd, ...);
```

**Return Value**

On success it returns an integer value &gt;= zero \(similar to a file descriptor\); on error it returns a negative number.

**Usage**

The **flb\_output\_set\(\)** allows to set one or more properties in a key/value string mode, e.g:

```c
int ret;

ret = flb_output_set(ctx, out_ffd,
                     "tag", "my_records",
                     "ssl", "false",
                     NULL);
```

The argument **ctx** represents the library context created by **flb\_create\(\)**. The above example specified the values for the properties **tag** and **ssl**, note that the value is always a string \(char \*\) and once there is no more parameters a NULL argument must be added at the end of the list.

The properties allowed per output plugin are specified on each specific plugin documentation.

## Start Fluent Bit Engine

Once the library context has been created and the input/output plugin instances are set, the next step is to start the engine. When started, the engine runs inside a new thread \(POSIX thread\) without blocking the caller application. To start the engine the function **flb\_start\(\)** is used.

**Prototype**

```c
int flb_start(flb_ctx_t *ctx);
```

**Return Value**

On success it returns 0; on error it returns a negative number.

**Usage**

This simple call only needs as argument **ctx** which is the reference to the context created at the beginning with **flb\_create\(\)**:

```c
int ret;

ret = flb_start(ctx);
```

## Stop Fluent Bit Engine

To stop a running Fluent Bit engine, we provide the call **flb\_stop\(\)** for that purpose.

**Prototype**

```c
int flb_stop(flb_ctx_t *ctx);
```

The argument **ctx** is a reference to the context created at the beginning with **flb\_create\(\)** and previously started with **flb\_start\(\)**.

When the call is invoked, the engine will wait a maximum of five seconds to flush buffers and release the resources in use. A stopped context can be re-started any time but without any data on it.

**Return Value**

On success it returns 0; on error it returns a negative number.

**Usage**

```c
int ret;

ret = flb_stop(ctx);
```

## Destroy Library Context

A library context must be destroyed after is not longer necessary, note that a previous **flb\_stop\(\)** call is mandatory. When destroyed all resources associated are released.

**Prototype**

```c
void flb_destroy(flb_ctx_t *ctx);
```

The argument **ctx** is a reference to the context created at the beginning with **flb\_create\(\)**.

**Return Value**

No return value.

**Usage**

```c
flb_destroy(ctx);
```

## Ingest Data Manually

There are some cases where the caller application may want to ingest data into Fluent Bit, for this purpose exists the function **flb\_lib\_push\(\)**.

**Prototype**

```c
int flb_lib_push(flb_ctx_t *ctx, int in_ffd, void *data, size_t len);
```

The first argument is the context created previously through **flb\_create\(\)**. **in\_ffd** is the numeric reference of the input plugin \(for this case it should be an input of plugin **lib** type\), **data** is a reference to the message to be ingested and **len** the number of bytes to take from it.

**Return Value**

On success, it returns the number of bytes written; on error it returns -1.

**Usage**

For more details and an example about how to use this function properly please refer to the next section [Ingest Records Manually](ingest_records_manually.md).

