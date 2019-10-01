# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is v1.3.0:

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.0-1.AMD64.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.0-1.AMD64.exe) | f91181e14bcd8d66f6d7761180a359c9d192b7665e41deda1f29db65a8b91426 |
| [td-agent-bit-1.3.0-1.AMD64.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.0-1.AMD64.zip) | 5d3af81500a0aa5d33ce692baf870fbe4669f628c77af739bf1443a1f7b6663e |

To check the integrity, use `Get-FileHash` command on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.2.2-win32.exe
```

## Installing from ZIP archive

Download a ZIP archive from the list above. Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.2.0-win64.zip
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
Fluent Bit v1.3.0
Copyright (C) Treasure Data

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

