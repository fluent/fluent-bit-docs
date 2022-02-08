# macOS

Fluent Bit is compatible with latest Apple macOS system on x86_64 and Apple Silicon M1 architectures.  At the moment there is no official supported package but you can build it from sources by following the instructions below.

## Requirements

For the next steps, you will need to have [Homebrew](https://brew.sh/) installed in your system, if is not there, you can install it with the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install build dependencies

Run the following brew command in your terminal to retrieve the dependencies:

```bash
brew install git cmake openssl bison
```

## Get the source and build it

Grab a fresh copy of the Fluent Bit source code (upstream):

```bash
git clone https://github.com/fluent/fluent-bit
cd fluent-bit
```

Optionally, if you want to use a specific version, just checkout to the proper tag. If you want to use `v1.8.13` just do:

```bash
git checkout v1.8.13
```

In order to prepare the build system, we need to expose certain environment variables so Fluent Bit CMake build rules can pick the right libraries:

```bash
export OPENSSL_ROOT_DIR=`brew --prefix openssl`
export PATH=`brew --prefix bison`/bin:$PATH
```

Build Fluent Bit. Note that we are indicating to the build system "where" the final binaries and config files should be installed:

```bash
cmake -DFLB_DEV=on -DCMAKE_INSTALL_PREFIX=/opt/fluent-bit ../
make -j 16
```

Install the data. Note that this requires root privileges due to the directory we will write information to:

```bash
sudo make install
```

The binaries and configuration examples can be located at `/opt/fluent-bit/`.

## Running Fluent Bit

To make the access path easier to Fluent Bit binary, in your terminal extend the `PATH` variable:

```bash
export PATH=/opt/fluent-bit/bin:$PATH
```

Now as a simple test, try Fluent Bit by generating a simple dummy message which will be printed to the standard output interface every 1 second:

```bash
 fluent-bit -i dummy -o stdout -f 1
```

You will see an output similar to this:

```bash
Fluent Bit v1.9.0
* Copyright (C) 2015-2021 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2022/02/08 17:13:52] [ info] [engine] started (pid=14160)
[2022/02/08 17:13:52] [ info] [storage] version=1.1.6, initializing...
[2022/02/08 17:13:52] [ info] [storage] in-memory
[2022/02/08 17:13:52] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2022/02/08 17:13:52] [ info] [cmetrics] version=0.2.2
[2022/02/08 17:13:52] [ info] [sp] stream processor started
[0] dummy.0: [1644362033.676766000, {"message"=>"dummy"}]
[0] dummy.0: [1644362034.676914000, {"message"=>"dummy"}]
```

To halt the process, press `ctrl-c` in the terminal.

