# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is 1.4.1.

| INSTALLERS | SHA256 CHECKSUMS |
| :--- | :--- |
| [td-agent-bit-1.4.2-win32.exe](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.2-win32.exe) | 1a7de3f12fb3453d0b7e086036426ff8265c8caf57d7b88b8d44c3d775acf2cd |
| [td-agent-bit-1.4.2-win32.zip](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.2-win32.zip) | e65fd9915f7b8c8d9cc3856f9bf2abd7d189b3aba55b3372d9f94a21011da2da |
| [td-agent-bit-1.4.2-win64.exe](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.2-win64.exe) | f022ae48797e905ced9f9fe52b9b395605bf20ad4cad22aa216d359927468ace |
| [td-agent-bit-1.4.2-win64.zip](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.2-win64.zip) | 3c8b171bfea8aeeced71a85195d83acac21af13f1a049ae7a596b7ee9fa97edc |

To check the integrity, use `Get-FileHash` cmdlet on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.4.2-win32.exe
```

## Installing from ZIP archive

Download a ZIP archive [from the download page](https://fluentbit.io/). There are installers for 32-bit and 64-bit environments, so choose one suitable for your environment.

Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` cmdlet.

```text
PS> Expand-Archive td-agent-bit-1.4.2-win64.zip
```

The ZIP package contains the following set of files.

```text
td-agent-bit
├── bin
│   ├── fluent-bit.dll
│   └── fluent-bit.exe
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

```text
PS> .\bin\fluent-bit.exe -i dummy -o stdout
```

If you see the following output, it's working fine!

```text
PS> .\bin\fluent-bit.exe  -i dummy -o stdout
Fluent Bit v1.4.x
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

Then, double-click the EXE installer you've downloaded. Installation wizard will automatically start.

![](../.gitbook/assets/windows_installer%20%281%29.png)

Click Next and proceed. By default, Fluent Bit is installed into `C:\Program Files\td-agent-bit\`, so you should be able to launch fluent-bit as follow after installation.

```text
PS> C:\Program Files\td-agent-bit\bin\fluent-bit.exe -i dummy -o stdout
```

## Windows Service Support

Windows services are equivalent to "daemons" in UNIX \(i.e. long-running background processes\). Since v1.5.0, Fluent Bit has the native support for Windows Service.

Suppose you have the following installation layout:

```text
C:\fluent-bit\
├── conf
│   ├── fluent-bit.conf
│   └── parsers.conf
└── bin
    ├── fluent-bit.dll
    └── fluent-bit.exe
```

To register Fluent Bit as a Windows service, you need to execute the following command on Command Prompt. Please be careful that a single space is required after `binpath=`.

```text
% sc.exe create fluent-bit binpath= "\fluent-bit\bin\fluent-bit.exe -c \fluent-bit\conf\fluent-bit.conf"
```

Now Fluent Bit can be started and managed as a normal Windows service.

```text
% sc.exe start fluent-bit
% sc.exe query fluent-bit
SERVICE_NAME: fluent-bit
    TYPE               : 10  WIN32_OWN_PROCESS
    STATE              : 4 Running
    ...
```

To halt the Fluent Bit service, just execute the "stop" command.

```text
% sc.exe stop fluent-bit
```

## Compile from Source

If you need to create a custom exectable, you can use the following procedure to compile Fluent Bit by yourself.

### Preparation

First, you need Microsoft Visual C++ to compile Fluent Bit. You can install the minimum toolkit by the following command:

```text
PS> wget -o vs.exe https://aka.ms/vs/16/release/vs_buildtools.exe
PS> start vs.exe
```

When asked which packages to install, choose "C++ Build Tools" \(make sure that "C++ CMake tools for Windows" is selected too\) and wait until the process finishes.

Also you need to install flex and bison. One way to install them on Windows is to use [winflexbison](https://github.com/lexxmark/winflexbison).

```text
PS> wget -o winflexbison.zip https://github.com/lexxmark/winflexbison/releases/download/v2.5.22/win_flex_bison-2.5.22.zip
PS> Expand-Archive winflexbison.zip -Destination C:\WinFlexBison
PS> cp -Path C:\WinFlexBison\win_bison.exe C:\WinFlexBison\bison.exe
PS> cp -Path C:\WinFlexBison\win_flex.exe C:\WinFlexBison\flex.exe
PS> setx /M PATH "%PATH%;C:\WinFlexBison"
```

Also you need to install [git](https://git-scm.com/download/win) to pull the source code from the repository.

```text
PS> wget -o git.exe https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe
PS> start git.exe
```

### Compilation

Open the start menu on Windows and type "Developer Command Prompt".

Clone the source code of Fluent Bit.

```text
% git clone https://github.com/fluent/fluent-bit
% cd fluent-bit/build
```

Compile the source code.

```text
% cmake .. -G "NMake Makefiles"
% cmake --build .
```

Now you should be able to run Fluent Bit:

```text
% .\bin\debug\fluent-bit.exe -i dummy -o stdout
```

### Packaging

To create a ZIP package, call `cpack` as follows:

```text
% cpack -G ZIP
```

