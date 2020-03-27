# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is 1.4.1.

| INSTALLERS | SHA256 CHECKSUMS |
| :--- | :--- |
| [td-agent-bit-1.4.1-win32.exe](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.1-win32.exe) | 6a56b7075eee62c57362b897d6815f3c99266d1dcf10974e580eb569d165b449 |
| [td-agent-bit-1.4.1-win32.zip](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.1-win32.zip) | e6c7844b0af9f3c21d801d55fc3866ad30b7a66f2934ab7498fc13c21eff3220 |
| [td-agent-bit-1.4.1-win64.exe](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.1-win64.exe) | b781cc790c13c727d93ad8b8336cc318083d2aad1c73e042cfeb5e2649d5ddd9 |
| [td-agent-bit-1.4.1-win64.zip](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.1-win64.zip) | decb16cfe3da6b935e2e6917c28a6236f1f47b5f6ca307c8433ad2d5c40ad6ac |

To check the integrity, use `Get-FileHash` commandlet on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.4.1-win32.exe
```

## Installing from ZIP archive

Download a ZIP archive [from the download page](https://fluentbit.io/). There are installers for 32-bit and 64-bit environments, so choose one suitable for your environment.

Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.4.1-win64.zip
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

