# macOS

Fluent Bit is compatible with the latest Apple macOS software for x86_64 and Apple Silicon architectures.

## Installation packages

Installation packages can be found [in the Fluent Bit repository](https://packages.fluentbit.io/macos/).

## Requirements

You must have [Homebrew](https://brew.sh/) installed in your system. If it isn't present, install it with the following command:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Installing from Homebrew

The Fluent Bit package on Homebrew isn't officially supported, but should work for basic use cases and testing. It can be installed using:

```shell
brew install fluent-bit
```

## Compile from source

### Install build dependencies

Run the following brew command in your terminal to retrieve the dependencies:

```shell
brew install git cmake openssl bison libyaml
```

## Download and build the source

1. Download a copy of the Fluent Bit source code (upstream):

```shell
git clone https://github.com/fluent/fluent-bit
```

1. Go to the Fluent Bit directory.

```shell
cd fluent-bit
```

If you want to use a specific version, checkout to the proper tag. For example, to use `v4.0.4`, use the command:

```shell
git checkout v4.0.4
```

1. To prepare the build system, you must export certain environment variables so Fluent Bit CMake build rules can pick the right libraries:

```shell
export OPENSSL_ROOT_DIR=`brew --prefix openssl`

export PATH=`brew --prefix bison`/bin:$PATH
```

1. Change to the `build/` directory inside the Fluent Bit sources:

```shell
cd build/
```

1. Build Fluent Bit. This example indicates to the build system the location the final binaries and `config` files should be installed:

```shell
cmake -DFLB_DEV=on -DCMAKE_INSTALL_PREFIX=/opt/fluent-bit ../

make -j 16
```

1. Install Fluent Bit to the previously specified directory. Writing to this directory requires root privileges.

```shell
sudo make install
```

The binaries and configuration examples can be located at `/opt/fluent-bit/`.

## Create macOS installer from source

1. Clone the Fluent Bit source code (upstream):

```shell
git clone https://github.com/fluent/fluent-bit
```

1. Change to the Fluent Bit directory

```shell
cd fluent-bit
```

To use a specific version, checkout to the proper tag. For example, to use `v4.0.4` do:

```shell
git checkout v4.0.4
```

1. To prepare the build system, you must expose certain environment variables so Fluent Bit CMake build rules can pick the right libraries:

```shell
export OPENSSL_ROOT_DIR=`brew --prefix openssl`

export PATH=`brew --prefix bison`/bin:$PATH
```

1. Create the specific macOS SDK target. For example, to specify macOS Big Sur (11.3) SDK environment:

```shell
export MACOSX_DEPLOYMENT_TARGET=11.3
```

1. Change to the `build/` directory inside the Fluent Bit sources:

```shell
cd build/
```

1. Build the Fluent Bit macOS installer:

```shell
cmake -DCPACK_GENERATOR=productbuild -DCMAKE_INSTALL_PREFIX=/opt/fluent-bit ../

make -j 16

cpack -G productbuild
```

The macOS installer will be generated as:

```text
CPack: Create package using productbuild
CPack: Install projects
CPack: - Run preinstall target for: fluent-bit
CPack: - Install project: fluent-bit []
CPack: -   Install component: binary
CPack: -   Install component: library
CPack: -   Install component: headers
CPack: -   Install component: headers-extra
CPack: Create package
CPack: -   Building component package: /Users/fluent-bit-builder/GitHub/fluent-bit/build/_CPack_Packages/Darwin/productbuild//Users/fluent-bit-builder/GitHub/fluent-bit/build/fluent-bit-1.9.2-apple/Contents/Packages/fluent-bit-1.9.2-apple-binary.pkg
CPack: -   Building component package: /Users/fluent-bit-builder/GitHub/fluent-bit/build/_CPack_Packages/Darwin/productbuild//Users/fluent-bit-builder/GitHub/fluent-bit/build/fluent-bit-1.9.2-apple/Contents/Packages/fluent-bit-1.9.2-apple-headers.pkg
CPack: -   Building component package: /Users/fluent-bit-builder/GitHub/fluent-bit/build/_CPack_Packages/Darwin/productbuild//Users/fluent-bit-builder/GitHub/fluent-bit/build/fluent-bit-1.9.2-apple/Contents/Packages/fluent-bit-1.9.2-apple-headers-extra.pkg
CPack: -   Building component package: /Users/fluent-bit-builder/GitHub/fluent-bit/build/_CPack_Packages/Darwin/productbuild//Users/fluent-bit-builder/GitHub/fluent-bit/build/fluent-bit-1.9.2-apple/Contents/Packages/fluent-bit-1.9.2-apple-library.pkg
CPack: - package: /Users/fluent-bit-builder/GitHub/fluent-bit/build/fluent-bit-1.9.2-apple.pkg generated.
```

Finally, the `fluent-bit-<fluent-bit version>-(intel or apple)`.pkg will be generated.

The created installer will put binaries at `/opt/fluent-bit/`.

## Running Fluent Bit

To make the access path easier to Fluent Bit binary, extend the `PATH` variable:

```shell
export PATH=/opt/fluent-bit/bin:$PATH
```

To test, try Fluent Bit by generating a test message using the [Dummy input plugin](../../pipeline/inputs/dummy) which prints to the standard output interface every one second:

```shell
fluent-bit -i dummy -o stdout -f 1
```

You will see an output similar to this:

```text
...
[0] dummy.0: [1644362033.676766000, {"message"=>"dummy"}]
[0] dummy.0: [1644362034.676914000, {"message"=>"dummy"}]
```

To halt the process, press `ctrl-c` in the terminal.
