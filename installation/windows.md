# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is 1.6.10:

| INSTALLERS | SHA256 CHECKSUMS |
| :--- | :--- |
| [td-agent-bit-1.6.10-win32.exe](https://fluentbit.io/releases/1.6/td-agent-bit-1.6.10-win32.exe) | b4623182db0ab7d5f1c77b165e6fc912db25aa50a88607a25707bd7ae9efaf06 |
| [td-agent-bit-1.6.10-win32.zip](https://fluentbit.io/releases/1.6/td-agent-bit-1.6.10-win32.zip) | a10255e7170ff4c5f9974f8be2b12385e4e6954558ee4af1e9fe65af3d591680 |
| [td-agent-bit-1.6.10-win64.exe](https://fluentbit.io/releases/1.6/td-agent-bit-1.6.10-win64.exe) | 28260ec7c8bc057a014eb526193cc1b66a1d6f231a9d68859edaff660918a84a |
| [td-agent-bit-1.6.10-win64.zip](https://fluentbit.io/releases/1.6/td-agent-bit-1.6.10-win64.zip) | f6984908a7dca3c0e01d638a58a6eb86e1e14aca7d2b43c187e4633daf4895e5 |

To check the integrity, use `Get-FileHash` commandlet on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.6.10-win32.exe
```

## Installing from ZIP archive

Download a ZIP archive [from the download page](https://fluentbit.io/). There are installers for 32-bit and 64-bit environments, so choose one suitable for your environment.

Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.6.10-win64.zip
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
Fluent Bit v1.6.x
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

