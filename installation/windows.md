# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is v1.3.7:

### 64 Bits

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.7-win64.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.7-win64.exe) | 553c594ac7478edd805bc1839991e3d1b44fa8ab9a58540278d304e7a35bdb51 |
| [td-agent-bit-1.3.7-win64.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.7-win64.zip) | ab1c72391ef727a821ba3c754bc95bdf8c3366e125bbcf31eb3107ab18518881 |

### 32 Bits

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.7-win32.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.7-win32.exe) | 718059a42767f4d0b4fdb01737b2392ca1637b69830124b8565356faff485ff7 |
| [td-agent-bit-1.3.7-win32.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.7-win32.zip) | b4044870e37d2fc0b0229da41925c4f2ed1a50c0c95513c3e45d8e59bc22e93a |

To check the integrity, use `Get-FileHash` command on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.3.7-win64.zip
```

## Installing from ZIP archive

Download a ZIP archive from the list above. Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.3.7-win64.zip
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
Fluent Bit v1.3.7
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

Download an EXE installer from the links above. Then, double-click the EXE installer you've downloaded. Installation wizard will automatically start.

![](../.gitbook/assets/windows_installer%20%281%29.png)

Click Next and proceed. By default, Fluent Bit is installed into `C:\Program Files\td-agent-bit\`, so you should be able to launch fluent-bit as follow after installation.

```text
PS> C:\Program Files\td-agent-bit\bin\fluent-bit.exe -i dummy -o stdout
```
