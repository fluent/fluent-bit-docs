# Windows

Fluent Bit is distributed as **fluent-bit** package for Windows and as a [Windows container on Docker Hub](docker.md). Fluent Bit has two flavours of Windows installers: a ZIP archive (for quick testing) and an EXE installer (for system installation).

Not all plugins are supported on Windows: the [CMake configuration](https://github.com/fluent/fluent-bit/blob/master/cmake/windows-setup.cmake) shows the default set of supported plugins.

## Configuration

Make sure to provide a valid Windows configuration with the installation, a sample one is shown below:

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

From version 1.9, `td-agent-bit` is a deprecated package and was removed after 1.9.9. The correct package name to use now is `fluent-bit`.

## Installation Packages

The latest stable version is 3.0.3.
Each version is available via the following download URLs.

| INSTALLERS                                                                                       | SHA256 CHECKSUMS                                                 |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------- |
| [fluent-bit-3.0.3-win32.exe](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win32.exe) | [4e8c839b643aecbb074b966d3935de7e9dd19383b906d17f430ce1d4672905c7](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win32.exe.sha256) |
| [fluent-bit-3.0.3-win32.zip](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win32.zip) | [ad4adae48b46eeb0f2809a2e6edf5c5d7375943c756dfe7d89788a12bc204ce1](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win32.zip.sha256) |
| [fluent-bit-3.0.3-win64.exe](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win64.exe) | [273180eb08d1507505337cc56ae71f651ec64bd4b2abaf62c4d51587bdb3d42b](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win64.exe.sha256) |
| [fluent-bit-3.0.3-win64.zip](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win64.zip) | [fa57c9c545b77228f033bd1c7845bff5e721147902b0470ccf6f029003eab397](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win64.zip.sha256) |
| [fluent-bit-3.0.3-winarm64.exe](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-winarm64.exe) | [b212322db5af51a89fe4745deb91d0095b42558e3babb5ff4f03a1be203e4283](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-winarm64.exe.sha256) |
| [fluent-bit-3.0.3-winarm64.zip](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-winarm64.zip) | [074045b6fb2914c9e575d2e7d3ed7f507bf0914a47955c71b388d78332a1e6e7](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-winarm64.zip.sha256) |

**Note these are now using the Github Actions built versions, the legacy AppVeyor builds are still available (AMD 32/64 only) at releases.fluentbit.io but are deprecated.**

MSI installers are also available:

- [fluent-bit-3.0.3-win32.msi](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win32.msi)
- [fluent-bit-3.0.3-win64.msi](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-win64.msi)
- [fluent-bit-3.0.3-winarm64.msi](https://packages.fluentbit.io/windows/fluent-bit-3.0.3-winarm64.msi)

To check the integrity, use `Get-FileHash` cmdlet on PowerShell.

```powershell
PS> Get-FileHash fluent-bit-3.0.3-win32.exe
```

## Installing from ZIP archive

Download a ZIP archive from above. There are installers for 32-bit and 64-bit environments, so choose one suitable for your environment.

Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` cmdlet.

```powershell
PS> Expand-Archive fluent-bit-3.0.3-win64.zip
```

The ZIP package contains the following set of files.

```
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

Now, launch cmd.exe or PowerShell on your machine, and execute `fluent-bit.exe` as follows.

```powershell
PS> .\bin\fluent-bit.exe -i dummy -o stdout
```

If you see the following output, it's working fine!

```powershell
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

To halt the process, press CTRL-C in the terminal.

## Installing from EXE installer

Download an EXE installer from the [download page](https://fluentbit.io/download/). It has both 32-bit and 64-bit builds. Choose one which is suitable for you.

Double-click the EXE installer you've downloaded. The installation wizard will automatically start.

![Installation wizard screenshot](<../.gitbook/assets/windows\_installer (1) (1).png>)

Click Next and proceed. By default, Fluent Bit is installed into `C:\Program Files\fluent-bit\`, so you should be able to launch fluent-bit as follows after installation.

```powershell
PS> C:\Program Files\fluent-bit\bin\fluent-bit.exe -i dummy -o stdout
```

### Installer options

The Windows installer is built by \[`CPack` using NSIS([https://cmake.org/cmake/help/latest/cpack\_gen/nsis.html](https://cmake.org/cmake/help/latest/cpack\_gen/nsis.html)) and so supports the [default options](https://nsis.sourceforge.io/Docs/Chapter3.html#3.2.1) that all NSIS installers do for silent installation and the directory to install to.

To silently install to `C:\fluent-bit` directory here is an example:

```powershell
PS> <installer exe> /S /D=C:\fluent-bit
```

The uninstaller automatically provided also supports a silent un-install using the same `/S` flag. This may be useful for provisioning with automation like Ansible, Puppet, etc.

## Windows Service Support

Windows services are equivalent to "daemons" in UNIX (i.e. long-running background processes). Since v1.5.0, Fluent Bit has the native support for Windows Service.

Suppose you have the following installation layout:

```
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

To register Fluent Bit as a Windows service, you need to execute the following command on Command Prompt. Please be careful that a single space is required after `binpath=`.

```powershell
% sc.exe create fluent-bit binpath= "\fluent-bit\bin\fluent-bit.exe -c \fluent-bit\conf\fluent-bit.conf"
```

Now Fluent Bit can be started and managed as a normal Windows service.

```powershell
% sc.exe start fluent-bit
% sc.exe query fluent-bit
SERVICE_NAME: fluent-bit
    TYPE               : 10  WIN32_OWN_PROCESS
    STATE              : 4 Running
    ...
```

To halt the Fluent Bit service, just execute the "stop" command.

```powershell
% sc.exe stop fluent-bit
```

To start Fluent Bit automatically on boot, execute the following:

```
% sc.exe config fluent-bit start= auto
```

### \[FAQ] Fluent Bit fails to start up when installed under `C:\Program Files`

Quotations are required if file paths contain spaces. Here is an example:

```
% sc.exe create fluent-bit binpath= "\"C:\Program Files\fluent-bit\bin\fluent-bit.exe\" -c \"C:\Program Files\fluent-bit\conf\fluent-bit.conf\""
```

### \[FAQ] How can I manage Fluent Bit service via PowerShell?

Instead of `sc.exe`, PowerShell can be used to manage Windows services.

Create a Fluent Bit service:

```powershell
PS> New-Service fluent-bit -BinaryPathName "C:\fluent-bit\bin\fluent-bit.exe -c C:\fluent-bit\conf\fluent-bit.conf" -StartupType Automatic
```

Start the service:

```powershell
PS> Start-Service fluent-bit
```

Query the service status:

```powershell
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

```powershell
PS> Stop-Service fluent-bit
```

Remove the service (requires PowerShell 6.0 or later)

```powershell
PS> Remove-Service fluent-bit
```

## Compile from Source

If you need to create a custom executable, you can use the following procedure to compile Fluent Bit by yourself.

### Preparation

First, you need Microsoft Visual C++ to compile Fluent Bit. You can install the minimum toolkit by the following command:

```powershell
PS> wget -o vs.exe https://aka.ms/vs/16/release/vs_buildtools.exe
PS> start vs.exe
```

When asked which packages to install, choose "C++ Build Tools" (make sure that "C++ CMake tools for Windows" is selected too) and wait until the process finishes.

Also you need to install flex and bison. One way to install them on Windows is to use [winflexbison](https://github.com/lexxmark/winflexbison).

```powershell
PS> wget -o winflexbison.zip https://github.com/lexxmark/winflexbison/releases/download/v2.5.22/win_flex_bison-2.5.22.zip
PS> Expand-Archive winflexbison.zip -Destination C:\WinFlexBison
PS> cp -Path C:\WinFlexBison\win_bison.exe C:\WinFlexBison\bison.exe
PS> cp -Path C:\WinFlexBison\win_flex.exe C:\WinFlexBison\flex.exe
```

Add the path `C:\WinFlexBison` to your systems environment variable "Path". [Here's how to do that](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/).

It is important to have installed OpenSSL binaries, at least the library files and headers.

Also you need to install [git](https://git-scm.com/download/win) to pull the source code from the repository.

```powershell
PS> wget -o git.exe https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe
PS> start git.exe
```

### Compilation

Open the start menu on Windows and type "Command Prompt for VS". From the result list select the one  that corresponds to your target system ( x86 or x64).

> **Note:** Check that  the  installed OpenSSL library files  match the selected target. You can check the library files by using the **dumpbin** command with the  **/headers** option .


Clone the source code of Fluent Bit.

```powershell
% git clone https://github.com/fluent/fluent-bit
% cd fluent-bit/build
```

Compile the source code.

```powershell
% cmake .. -G "NMake Makefiles"
% cmake --build .
```

Now you should be able to run Fluent Bit:

```powershell
% .\bin\debug\fluent-bit.exe -i dummy -o stdout
```

### Packaging

To create a ZIP package, call `cpack` as follows:

```powershell
% cpack -G ZIP
```
