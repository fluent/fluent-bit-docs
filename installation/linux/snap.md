# Snap Store

If you use any Linux distribution [supported by](https://snapcraft.io/docs/installing-snapd) Snapcraft, you can get Fluent Bit as a Snap in your system.



[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-white.svg)](https://snapcraft.io/fluent-bit)



## Getting Started

Install Fluent Bit Snap in your system

```bash
$ sudo snap install fluent-bit
```

Our Snap install one service called ```fluent-bit.service``` which should be already running in background. To get more details about it status you can use the following command:

```bash
$ sudo snap services fluent-bit
Service             Startup  Current  Notes
fluent-bit.service  enabled  active   -
```

### Service Configuration

To get the exact path of the configuration file, start a Snap shell and dig into the environment variables:



The default configuration file for the running service is located at