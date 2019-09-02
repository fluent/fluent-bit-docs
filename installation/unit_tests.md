# Unit Tests

[Fluent Bit](http://fluentbit.io) comes with some unit test programs that uses the _library_ mode to ingest data and test the output. 

In the source code, we provide two kinds of tests:

- internal
- runtime

_Internal_ tests are unit tests that runs isolated from the engine, their target is mostly to validate specific functions from the core. In the other side, _runtime_ tests runs in with the engine in library mode.

> By default only internal tests are enabled

## Enable Runtime Tests

By default [Fluent Bit](http://fluentbit.io) have runtime tests disabled, you need to append the option -DFLB_RUNTIME_TESTS=on to your **cmake** line, e.g:

```bash
$ cd build/
$ cmake -DFLB_RUNTIME_TESTS=ON ../
```

## Running Tests

To run the tests just issue the following command:

```bash
$ make test
```

