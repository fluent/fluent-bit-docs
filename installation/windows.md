# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is v1.3.11:

### 64 Bits

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.11-win64.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.11-win64.exe) | 9846538ba849cb2a0e77a75f247e6a59703536b916fb371fc0ac91ee6c372dce |
| [td-agent-bit-1.3.11-win64.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.11-win64.zip) | c58128aeff74c98504e871a6b2051f7248d01a77e2a72264e4f3525c21f6b9c8 |

### 32 Bits

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.11-win32.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.11-win32.exe) | 8811e01e25678d20d07e70dddc7846048fdeb08c85292d636ee32d81bcd58ec5 |
| [td-agent-bit-1.3.11-win32.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.11-win32.zip) | 57c2a95e99fab83e2f9d7b834ce110a44c88656f8c38d4a6388c39599314f1bb |

To check the integrity, use `Get-FileHash` command on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.3.11-win64.zip
```

## Installing from ZIP archive

Download a ZIP archive from the list above. Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.3.11-win64.zip
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
Fluent Bit v1.3.11
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

![](../.gitbook/assets/windows_installer%20%281%29%20%281%29.png)

Click Next and proceed. By default, Fluent Bit is installed into `C:\Program Files\td-agent-bit\`, so you should be able to launch fluent-bit as follow after installation.

```text
PS> C:\Program Files\td-agent-bit\bin\fluent-bit.exe -i dummy -o stdout
```

