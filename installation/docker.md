# Fluent Bit Docker Images

Every version of Fluent Bit is available on Docker Hub ready for production usage, the following tags are available on [fluent/fluent-bit](https://hub.docker.com/r/fluent/fluent-bit/) image:

| Tag    | Description                                        |
|--------|----------------------------------------------------|
| 0.12   | Latest build for 0.12 stable series                |
| 0.11   | Latest build for 0.11 series, no longer maintained |

## Getting Started

Download the last stable image from 0.12 series:

```
$ docker pull fluent/fluent-bit:0.12
```

Once the image is in place, now run the following (useless) test which makes Fluent Bit meassure CPU usage by the container:

```
$ docker run -ti fluent/fluent-bit:0.12 /fluent-bit/bin/fluent-bit -i cpu -o stdout -f 1
```

That command will let Fluent Bit meassure CPU usage every second and flush the results to the standard output, e.g:


```
Fluent-Bit v0.12.1
Copyright (C) Treasure Data

[2017/09/01 18:29:02] [ info] [engine] started
[0] cpu.0: [1504290543.000487750, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
```
