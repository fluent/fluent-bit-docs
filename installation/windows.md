# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is 1.4.6.

| INSTALLERS | SHA256 CHECKSUMS |
| :--- | :--- |
| [td-agent-bit-1.4.6-win32.exe](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.6-win32.exe) | 0cdc765bf384eb21ddd5aa80851ab7c0a236b4cca5d827e74879988de394889c |
| [td-agent-bit-1.4.6-win32.zip](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.6-win32.zip) | 32d791ccc737593401a369be4654cbc4dd08742098bab19fd4a7e928e990280d |
| [td-agent-bit-1.4.6-win64.exe](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.6-win64.exe) | 6bba62f25eeb632bada98c01a47019090962bb06e7c0bfc0af4527f3bde48648 |
| [td-agent-bit-1.4.6-win64.zip](https://fluentbit.io/releases/1.4/td-agent-bit-1.4.6-win64.zip) | b28151b3359b6cc995495c9b47920e2d989a31b0c8970df8462818878fce1f8d |

To check the integrity, use `Get-FileHash` commandlet on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.4.6-win32.exe
```

## Installing from ZIP archive

Download a ZIP archive [from the download page](https://fluentbit.io/). There are installers for 32-bit and 64-bit environments, so choose one suitable for your environment.

Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.4.6-win64.zip
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

