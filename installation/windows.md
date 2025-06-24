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

The latest stable version is 4.0.3.
Each version is available from the following download URLs.

| INSTALLERS | SHA256 CHECKSUMS |
|----------- | ---------------- |
| [fluent-bit-4.0.3-win32.exe](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win32.exe) | [8739d87cc8ac1c4b776e8458e64f747719f4c38017e97c1e3abfdb90f1cfe801](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win32.exe.sha256) |
| [fluent-bit-4.0.3-win32.zip](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win32.zip) | [055e054ea60a961c9372ab7283d150808f811afd44963f5031cbd224e9be59da](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win32.zip.sha256) |
| [fluent-bit-4.0.3-win64.exe](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win64.exe) | [6817aecbd4d71679d1b32dcd466d81c2bce80978a6feecc44e037feab5f2f9ab](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win64.exe.sha256) |
| [fluent-bit-4.0.3-win64.zip](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win64.zip) | [ce9e7d4175a124550b3609fac810077428467dfad443c85936b160277d1e7ba5](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win64.zip.sha256) |
| [fluent-bit-4.0.3-winarm64.exe](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-winarm64.exe) | [cc539f92510659d437a1771bba9dbf42915a6dcf1b417faa32a7bad3d8d9729d](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-winarm64.exe.sha256) |
| [fluent-bit-4.0.3-winarm64.zip](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-winarm64.zip) | [71b014f0937d9bc1e8965e12847b956294d6ce7331acad764de6874a55c3c3f7](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-winarm64.zip.sha256) |

These are now using the Github Actions built versions. Legacy AppVeyor builds are
still available (AMD 32/64 only) at releases.fluentbit.io but are deprecated.

MSI installers are also available:

- [fluent-bit-4.0.3-win32.msi](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win32.msi)
- [fluent-bit-4.0.3-win64.msi](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-win64.msi)
- [fluent-bit-4.0.3-winarm64.msi](https://packages.fluentbit.io/windows/fluent-bit-4.0.3-winarm64.msi)

To check the integrity, use the `Get-FileHash` cmdlet for PowerShell.

```text copy
PS> Get-FileHash fluent-bit-4.0.3-win32.exe
```

## Installing from a ZIP archive

1. Download a ZIP archive. Choose the suitable installers for your 32-bit or 64-bit
   environments.

1. Expand the ZIP archive. You can do this by clicking **Extract All** in Explorer
   or `Expand-Archive` in PowerShell.

   ```text
   PS> Expand-Archive fluent-bit-4.0.3-win64.zip
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

   ```text
   PS> .\bin\fluent-bit.exe -i dummy -o stdout
   ```

The following output indicates Fluent Bit is running:

```text
PS> .\bin\fluent-bit.exe  -i dummy -o stdout
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

   ![Installation wizard screenshot](<../.gitbook/assets/windows\_installer (1) (1).png>)

1. Click **Next** and finish the installation. By default, Fluent Bit is installed
   in `C:\Program Files\fluent-bit\`.

You should be able to launch Fluent Bit using the following PowerShell command:.

```text
PS> C:\Program Files\fluent-bit\bin\fluent-bit.exe -i dummy -o stdout
```

### Installer options

The Windows installer is built by
[`CPack` using NSIS](https://cmake.org/cmake/help/latest/cpack_gen/nsis.html)
and supports the [default NSIS options](https://nsis.sourceforge.io/Docs/Chapter3.html#3.2.1)
for silent installation and install directory.

To silently install to `C:\fluent-bit` directory here is an example:

```text
PS> <installer exe> /S /D=C:\fluent-bit
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

```text
sc.exe create fluent-bit binpath= "\fluent-bit\bin\fluent-bit.exe -c \fluent-bit\conf\fluent-bit.conf"
```

Fluent Bit can be started and managed as a normal Windows service.

```text
% sc.exe start fluent-bit
% sc.exe query fluent-bit
SERVICE_NAME: fluent-bit
    TYPE               : 10  WIN32_OWN_PROCESS
    STATE              : 4 Running
    ...
```

To halt the Fluent Bit service, use the `stop` command.

```text
sc.exe stop fluent-bit
```

To start Fluent Bit automatically on boot, execute the following:

```text
sc.exe config fluent-bit start= auto
```

## FAQs

### Fluent Bit fails to start up when installed under `C:\Program Files`

Quotations are required if file paths contain spaces. For example:

```text
sc.exe create fluent-bit binpath= "\"C:\Program Files\fluent-bit\bin\fluent-bit.exe\" -c \"C:\Program Files\fluent-bit\conf\fluent-bit.conf\""
```

### Can you manage Fluent Bit service using PowerShell?

Instead of `sc.exe`, PowerShell can be used to manage Windows services.

Create a Fluent Bit service:

```text
PS> New-Service fluent-bit -BinaryPathName "`"C:\Program Files\fluent-bit\bin\fluent-bit.exe`" -c `"C:\Program Files\fluent-bit\conf\fluent-bit.conf`"" -StartupType Automatic -Description "This service runs Fluent Bit, a log collector that enables real-time processing and delivery of log data to centralized logging systems."
```

Start the service:

```text
PS> Start-Service fluent-bit
```

Query the service status:

```text
PS> get-Service fluent-bit | format-list
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

```text
PS> Stop-Service fluent-bit
```

Remove the service (requires PowerShell 6.0 or later)

```text
PS> Remove-Service fluent-bit
```

## Compile from Source

If you need to create a custom executable, use the following procedure to
compile Fluent Bit by yourself.

### Preparation

1. Install Microsoft Visual C++ to compile Fluent Bit. You can install the minimum
   toolkit using the following command:

```text
PS> wget -o vs.exe https://aka.ms/vs/16/release/vs_buildtools.exe
PS> start vs.exe
```

1. Choose `C++ Build Tools` and `C++ CMake tools for Windows` and wait until the process finishes.

1. Install flex and bison. One way to install them on Windows is to use
   [winflexbison](https://github.com/lexxmark/winflexbison).

   ```text
   PS> wget -o winflexbison.zip https://github.com/lexxmark/winflexbison/releases/download/v2.5.22/win_flex_bison-2.5.22.zip
   PS> Expand-Archive winflexbison.zip -Destination C:\WinFlexBison
   PS> cp -Path C:\WinFlexBison\win_bison.exe C:\WinFlexBison\bison.exe
   PS> cp -Path C:\WinFlexBison\win_flex.exe C:\WinFlexBison\flex.exe
   ```

1. Add the path `C:\WinFlexBison` to your systems environment variable `Path`.
   [Here's how to do that](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).

1. Install OpenSSL binaries, at least the library files and headers.

1. Install [Git](https://git-scm.com/download/win) to pull the source code from the repository.

   ```text
   PS> wget -o git.exe https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe
   PS> start git.exe
   ```

### Compilation

1. Open the **Start menu** on Windows and type `command Prompt for VS`. From the result
   list, select the one that corresponds to your target system ( `x86` or `x64`).

1. Verify the installed OpenSSL library files match the selected target. You can
   examine the library files by using the `dumpbin` command with the  `/headers`
   option .

1. Clone the source code of Fluent Bit.

   ```text
   % git clone https://github.com/fluent/fluent-bit
   % cd fluent-bit/build
   ```

1. Compile the source code.

   ```text
   % cmake .. -G "NMake Makefiles"
   % cmake --build .
   ```

Now you should be able to run Fluent Bit:

```text
.\bin\debug\fluent-bit.exe -i dummy -o stdout
```

### Packaging

To create a ZIP package, call `cpack` as follows:

```text
cpack -G ZIP
```
