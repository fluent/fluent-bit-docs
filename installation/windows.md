# Windows

Fluent Bit is distributed as the `fluent-bit` package for Windows and as a
[Windows container on Docker Hub](docker.md). Fluent Bit provides two Windows
installers: a `ZIP` archive and an `EXE` installer.

Not all plugins are supported on Windows. The
[CMake configuration](https://github.com/fluent/fluent-bit/blob/master/cmake/windows-setup.cmake)
shows the default set of supported plugins.

## Configuration

Provide a valid Windows configuration with the installation.

The following configuration is an example:

```python
[SERVICE]
    # Flush
    # =====
    # set an interval of seconds before to flush records to a destination
    flush        5

    # Daemon
    # ======
    # instruct Fluent Bit to run in foreground or background mode.
    daemon       Off

    # Log_Level
    # =========
    # Set the verbosity level of the service, values can be:
    #
    # - error
    # - warning
    # - info
    # - debug
    # - trace
    #
    # by default 'info' is set, that means it includes 'error' and 'warning'.
    log_level    info

    # Parsers File
    # ============
    # specify an optional 'Parsers' configuration file
    parsers_file parsers.conf

    # Plugins File
    # ============
    # specify an optional 'Plugins' configuration file to load external plugins.
    plugins_file plugins.conf

    # HTTP Server
    # ===========
    # Enable/Disable the built-in HTTP Server for metrics
    http_server  Off
    http_listen  0.0.0.0
    http_port    2020

    # Storage
    # =======
    # Fluent Bit can use memory and filesystem buffering based mechanisms
    #
    # - https://docs.fluentbit.io/manual/administration/buffering-and-storage
    #
    # storage metrics
    # ---------------
    # publish storage pipeline metrics in '/api/v1/storage'. The metrics are
    # exported only if the 'http_server' option is enabled.
    #
    storage.metrics on

[INPUT]
    Name         winlog
    Channels     Setup,Windows PowerShell
    Interval_Sec 1

[OUTPUT]
    name  stdout
    match *
```

## Migration to Fluent Bit

For version 1.9 and later, `td-agent-bit` is a deprecated package and was removed
after 1.9.9. The correct package name to use now is `fluent-bit`.

## Installation packages

The latest stable version is 4.0.5.
Each version is available from the following download URLs.

| INSTALLERS | SHA256 CHECKSUMS |
|----------- | ---------------- |
| [fluent-bit-4.0.5-win32.exe](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win32.exe) | [31d1d98f3c9a8cb829abc448de93ef859b63d02852c8529482fe284ed1176356](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win32.exe.sha256) |
| [fluent-bit-4.0.5-win32.zip](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win32.zip) | [98463c4a2d49392a2a01a8942f9ec6096328845c71476b5fd8a6055487101772](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win32.zip.sha256) |
| [fluent-bit-4.0.5-win64.exe](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win64.exe) | [935bc64cd81140e37c3e59aeed65e96a5e2c1e255252d2084754f2e829f04301](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win64.exe.sha256) |
| [fluent-bit-4.0.5-win64.zip](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win64.zip) | [f0c101bfd889c6f327dc74914e6084b77dbad9c9d64fe58a63fddd836aa29fec](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win64.zip.sha256) |
| [fluent-bit-4.0.5-winarm64.exe](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-winarm64.exe) | [be71a4c9ce51d69ea7ae18b32670c377e21039d4543a362ee06cee519e6c5308](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-winarm64.exe.sha256) |
| [fluent-bit-4.0.5-winarm64.zip](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-winarm64.zip) | [b39bfc3901b6da135acdc5fd16ce36ba7c6195efa7c68635815991816c35882e](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-winarm64.zip.sha256) |

These are now using the Github Actions built versions. Legacy AppVeyor builds are
still available (AMD 32/64 only) at releases.fluentbit.io but are deprecated.

MSI installers are also available:

- [fluent-bit-4.0.5-win32.msi](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win32.msi)
- [fluent-bit-4.0.5-win64.msi](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-win64.msi)
- [fluent-bit-4.0.5-winarm64.msi](https://packages.fluentbit.io/windows/fluent-bit-4.0.5-winarm64.msi)

To check the integrity, use the `Get-FileHash` cmdlet for PowerShell.

```shell copy
Get-FileHash fluent-bit-4.0.5-win32.exe
```

## Installing from a ZIP archive

1. Download a ZIP archive. Choose the suitable installers for your 32-bit or 64-bit
   environments.

1. Expand the ZIP archive. You can do this by clicking **Extract All** in Explorer
   or `Expand-Archive` in PowerShell.

   ```shell
   Expand-Archive fluent-bit-4.0.5-win64.zip
   ```

   The ZIP package contains the following set of files.

   ```text
   fluent-bit
   ├── bin
   │   ├── fluent-bit.dll
   │   └── fluent-bit.exe
   │   └── fluent-bit.pdb
   ├── conf
   │   ├── fluent-bit.conf
   │   ├── parsers.conf
   │   └── plugins.conf
   └── include
       │   ├── flb_api.h
       │   ├── ...
       │   └── flb_worker.h
       └── fluent-bit.h
   ```

1. Launch `cmd.exe` or PowerShell on your machine, and execute `fluent-bit.exe`:

   ```shell
   .\bin\fluent-bit.exe -i dummy -o stdout
   ```

The following output indicates Fluent Bit is running:

```shell
.\bin\fluent-bit.exe  -i dummy -o stdout
Fluent Bit v2.0.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2019/06/28 10:13:04] [ info] [storage] initializing...
[2019/06/28 10:13:04] [ info] [storage] in-memory
[2019/06/28 10:13:04] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2019/06/28 10:13:04] [ info] [engine] started (pid=10324)
[2019/06/28 10:13:04] [ info] [sp] stream processor started
[0] dummy.0: [1561684385.443823800, {"message"=>"dummy"}]
[1] dummy.0: [1561684386.428399000, {"message"=>"dummy"}]
[2] dummy.0: [1561684387.443641900, {"message"=>"dummy"}]
[3] dummy.0: [1561684388.441405800, {"message"=>"dummy"}]
```

To halt the process, press `Control+C` in the terminal.

## Installing from the EXE installer

1. Download an EXE installer for the appropriate 32-bit or 64-bit build.
1. Double-click the EXE installer you've downloaded. The installation wizard starts.

1. Click **Next** and finish the installation. By default, Fluent Bit is installed
   in `C:\Program Files\fluent-bit\`.

```shell
& "C:\Program Files\fluent-bit\bin\fluent-bit.exe" -i dummy -o stdout
```

### Installer options

The Windows installer is built by
[`CPack` using NSIS](https://cmake.org/cmake/help/latest/cpack_gen/nsis.html)
and supports the [default NSIS options](https://nsis.sourceforge.io/Docs/Chapter3.html#3.2.1)
for silent installation and install directory.

To silently install to `C:\fluent-bit` directory here is an example:

```shell
<installer exe> /S /D=C:\fluent-bit
```

The uninstaller also supports a silent uninstall using the same `/S` flag.
This can be used for provisioning with automation like Ansible, Puppet, and so on.

## Windows service support

Windows services are equivalent to daemons in UNIX (long-running background
processes).
For v1.5.0 and later, Fluent Bit has native support for Windows services.

For example, you have the following installation layout:

```text
C:\fluent-bit\
├── conf
│   ├── fluent-bit.conf
│   └── parsers.conf
│   └── plugins.conf
└── bin
    ├── fluent-bit.dll
    └── fluent-bit.exe
    └── fluent-bit.pdb
```

To register Fluent Bit as a Windows service, execute the following command on
at a command prompt. A single space is required after `binpath=`.

```shell
sc.exe create fluent-bit binpath= "\fluent-bit\bin\fluent-bit.exe -c \fluent-bit\conf\fluent-bit.conf"
```

Fluent Bit can be started and managed as a normal Windows service.

```shell
sc.exe start fluent-bit
sc.exe query fluent-bit
SERVICE_NAME: fluent-bit
    TYPE               : 10  WIN32_OWN_PROCESS
    STATE              : 4 Running
    ...
```

To halt the Fluent Bit service, use the `stop` command.

```shell
sc.exe stop fluent-bit
```

To start Fluent Bit automatically on boot, execute the following:

```shell
sc.exe config fluent-bit start= auto
```

## FAQs

### Can you manage Fluent Bit service using PowerShell?

Instead of `sc.exe`, PowerShell can be used to manage Windows services.

Create a Fluent Bit service:

```shell
New-Service fluent-bit -BinaryPathName "`"C:\Program Files\fluent-bit\bin\fluent-bit.exe`" -c `"C:\Program Files\fluent-bit\conf\fluent-bit.conf`"" -StartupType Automatic -Description "This service runs Fluent Bit, a log collector that enables real-time processing and delivery of log data to centralized logging systems."
```

Start the service:

```shell
Start-Service fluent-bit
```

Query the service status:

```shell
get-Service fluent-bit | format-list
Name                : fluent-bit
DisplayName         : fluent-bit
Status              : Running
DependentServices   : {}
ServicesDependedOn  : {}
CanPauseAndContinue : False
CanShutdown         : False
CanStop             : True
ServiceType         : Win32OwnProcess
```

Stop the service:

```shell
Stop-Service fluent-bit
```

Remove the service (requires PowerShell 6.0 or later)

```shell
Remove-Service fluent-bit
```

## Compile from Source

If you need to create a custom executable, use the following procedure to
compile Fluent Bit by yourself.

### Preparation

1. Install Microsoft Visual C++ to compile Fluent Bit. You can install the minimum
   toolkit using the following command:

```shell
wget -o vs.exe https://aka.ms/vs/16/release/vs_buildtools.exe
start vs.exe
```

1. Choose `C++ Build Tools` and `C++ CMake tools for Windows` and wait until the process finishes.

1. Install flex and bison. One way to install them on Windows is to use
   [winflexbison](https://github.com/lexxmark/winflexbison).

   ```shell
   wget -o winflexbison.zip https://github.com/lexxmark/winflexbison/releases/download/v2.5.22/win_flex_bison-2.5.22.zip
   Expand-Archive winflexbison.zip -Destination C:\WinFlexBison
   cp -Path C:\WinFlexBison\win_bison.exe C:\WinFlexBison\bison.exe
   cp -Path C:\WinFlexBison\win_flex.exe C:\WinFlexBison\flex.exe
   ```

1. Add the path `C:\WinFlexBison` to your systems environment variable `Path`.
   [Here's how to do that](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).

1. Install OpenSSL binaries, at least the library files and headers.

1. Install [Git](https://git-scm.com/download/win) to pull the source code from the repository.

   ```shell
   wget -o git.exe https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe
   start git.exe
   ```

### Compilation

1. Open the **Start menu** on Windows and type `command Prompt for VS`. From the result
   list, select the one that corresponds to your target system ( `x86` or `x64`).

1. Verify the installed OpenSSL library files match the selected target. You can
   examine the library files by using the `dumpbin` command with the  `/headers`
   option .

1. Clone the source code of Fluent Bit.

   ```shell
   git clone https://github.com/fluent/fluent-bit
   cd fluent-bit/build
   ```

1. Compile the source code.

   ```shell
   cmake .. -G "NMake Makefiles"
   cmake --build .
   ```

Now you should be able to run Fluent Bit:

```shell
.\bin\debug\fluent-bit.exe -i dummy -o stdout
```

### Packaging

To create a ZIP package, call `cpack` as follows:

```text
cpack -G ZIP
```
