# Ingest records manually

There are some cases where Fluent Bit library is used to send records from the caller application to some destination. This process is called _manual data ingestion_.

For this purpose, a specific input plugin called **lib** exists and can be used in conjunction with the `flb_lib`_push()` API function.

## Data format

The `lib` input plugin expects the data in the following fixed JSON format:

```json
[UNIX_TIMESTAMP, MAP]
```

Every record must be in a JSON array that contains at least two entries. The first one is the `UNIX_TIMESTAMP` which is a number representing time associated to the event generation (Epoch time). the second entry is a JSON map with a list of keys and values. A valid entry can be the following:

```javascript
[1449505010, {"key1": "some value", "key2": false}]
```

## Usage

The following C code snippet shows how to insert a few JSON records into a running Fluent Bit engine:

```c
#include <fluent-bit.h>

#define JSON_1   "[1449505010, {\"key1\": \"some value\"}]"
#define JSON_2   "[1449505620, {\"key1\": \"some new value\"}]"

int main()
{
    int ret;
    int in_ffd;
    int out_ffd;
    flb_ctx_t *ctx;

    /* Create library context */
    ctx = flb_create();
    if (!ctx) {
        return -1;
    }

    /* Enable the input plugin for manual data ingestion */
    in_ffd = flb_input(ctx, "lib", NULL);
    if (in_ffd == -1) {
        flb_destroy(ctx);
        return -1;
    }

    /* Enable output plugin 'stdout' (print records to the standard output) */
    out_ffd = flb_output(ctx, "stdout", NULL);
    if (out_ffd == -1) {
        flb_destroy(ctx);
        return -1;
    }

    /* Start the engine */
    ret = flb_start(ctx);
    if (ret == -1) {
        flb_destroy(ctx);
        return -1;
    }

    /* Ingest data manually */
    flb_lib_push(ctx, in_ffd, JSON_1, sizeof(JSON_1) - 1);
    flb_lib_push(ctx, in_ffd, JSON_2, sizeof(JSON_2) - 1);

    /* Stop the engine (5 seconds to flush remaining data) */
    flb_stop(ctx);

    /* Destroy library context, release all resources */
    flb_destroy(ctx);

    return 0;
}
```
