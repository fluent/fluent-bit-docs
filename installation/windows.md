# Windows

Fluent Bit is distributed as **td-agent-bit** package for Windows. Fluent Bit has two flavours of Windows installers: a ZIP archive \(for quick testing\) and an EXE installer \(for system installation\).

## Installation Packages

The latest stable version is v1.3.10:

### 64 Bits

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.10-win64.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.10-win64.exe) | 2214aca256736c858980ebd589b1f113c15dd9eb72ce43626aa1ee57e35138cb |
| [td-agent-bit-1.3.10-win64.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.10-win64.zip) | ba7a96674e077da97828260a4abcc96254b415498949048d74d960ee0d6719b3 |

### 32 Bits

| Installers | SHA256 Checksums |
| :--- | :--- |
| [td-agent-bit-1.3.10-win32.exe](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.10-win32.exe) | f13fa21df46c228c05c5f32fe04fe57c028ba96199817fd3039725adbd315b57 |
| [td-agent-bit-1.3.10-win32.zip](http://fluentbit.io/releases/1.3/td-agent-bit-1.3.10-win32.zip) | 9bdee7f607d45d7821e2acabdefebaa7faa197f3ab3695c6c7938cd2caff543b |

To check the integrity, use `Get-FileHash` command on PowerShell.

```text
PS> Get-FileHash td-agent-bit-1.3.10-win64.zip
```

## Installing from ZIP archive

Download a ZIP archive from the list above. Then you need to expand the ZIP archive. You can do this by clicking "Extract All" on Explorer, or if you're using PowerShell, you can use `Expand-Archive` commandlet.

```text
PS> Expand-Archive td-agent-bit-1.3.10-win64.zip
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
Fluent Bit v1.3.10
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
