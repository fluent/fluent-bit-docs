# Tutorial

Follow this tutorial to learn more about stream processing.

## Requirements

This tutorial requires the following components:

* Fluent Bit
* [Docker Engine](https://www.docker.com/products/docker-engine)
* A stream processing [sample file](https://raw.githubusercontent.com/fluent/fluent-bit-docs/37b477786d6e28eb223e08611c26ec93671a34ac/stream-processing/samples/sp-samples-1k.log)

## Steps

These steps use the official Fluent Bit Docker image.

### 1. Fluent Bit version

Run the following command to confirm that Fluent Bit is installed and up-to-date:

```bash
docker run -ti fluent/fluent-bit:1.4 /fluent-bit/bin/fluent-bit --version
Fluent Bit v1.8.2
```

### 2. Parse sample files

The sample file contains JSON records. Run the following command to append the `parsers.conf` file and instruct the Tail input plugin to parse content as JSON:

```bash
docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log        \
     fluent/fluent-bit:1.8.2                                          \
     /fluent-bit/bin/fluent-bit -R /fluent-bit/etc/parsers.conf     \
                                -i tail -p path=/sp-samples-1k.log  \
                                        -p parser=json              \
                                        -p read_from_head=true      \
                                -o stdout -f 1
```

This command prints the parsed content to the standard output interface. The parsed content includes a tag associated with each record and an array with two fields: a timestamp and a record map:

```text
Fluent Bit v1.8.2
* Copyright (C) 2019-2021 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2019/05/08 13:34:16] [ info] [storage] initializing...
[2019/05/08 13:34:16] [ info] [storage] in-memory
[2019/05/08 13:34:16] [ info] [storage] normal synchronization mode, checksum disabled
[2019/05/08 13:34:16] [ info] [engine] started (pid=1)
[2019/05/08 13:34:16] [ info] [sp] stream processor started
[0] tail.0: [1557322456.315513208, {"date"=>"22/abr/2019:12:43:51 -0600", "ip"=>"73.113.230.135", "word"=>"balsamine", "country"=>"Japan", "flag"=>false, "num"=>96}]
[1] tail.0: [1557322456.315525280, {"date"=>"22/abr/2019:12:43:52 -0600", "ip"=>"242.212.128.227", "word"=>"inappendiculate", "country"=>"Chile", "flag"=>false, "num"=>15}]
[2] tail.0: [1557322456.315532364, {"date"=>"22/abr/2019:12:43:52 -0600", "ip"=>"85.61.182.212", "word"=>"elicits", "country"=>"Argentina", "flag"=>true, "num"=>73}]
[3] tail.0: [1557322456.315538969, {"date"=>"22/abr/2019:12:43:52 -0600", "ip"=>"124.192.66.23", "word"=>"Dwan", "country"=>"Germany", "flag"=>false, "num"=>67}]
[4] tail.0: [1557322456.315545150, {"date"=>"22/abr/2019:12:43:52 -0600", "ip"=>"18.135.244.142", "word"=>"chesil", "country"=>"Argentina", "flag"=>true, "num"=>19}]
[5] tail.0: [1557322456.315550927, {"date"=>"22/abr/2019:12:43:52 -0600", "ip"=>"132.113.203.169", "word"=>"fendered", "country"=>"United States", "flag"=>true, "num"=>53}]
```

### 3. Select specific record keys

Run the following command to create a stream processor query using the `-T` flag and change the output to the Null plugin. This obtains the stream processing results in the standard output interface and avoids confusion in the terminal.

```bash
docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log             \
     fluent/fluent-bit:1.2                                               \
     /fluent-bit/bin/fluent-bit                                          \
         -R /fluent-bit/etc/parsers.conf                                 \
         -i tail                                                         \
             -p path=/sp-samples-1k.log                                  \
             -p parser=json                                              \
             -p read_from_head=true                                      \
         -T "SELECT word, num FROM STREAM:tail.0 WHERE country='Chile';" \
         -o null -f 1
```

The previous query aims to retrieve all records for which the `country` key contains the value `Chile`. For each match, it composes and outputs a record that only contains the keys `word` and `num`:

```text
[0] [1557322913.263534, {"word"=>"Candide", "num"=>94}]
[0] [1557322913.263581, {"word"=>"delightfulness", "num"=>99}]
[0] [1557322913.263607, {"word"=>"effulges", "num"=>63}]
[0] [1557322913.263690, {"word"=>"febres", "num"=>21}]
[0] [1557322913.263706, {"word"=>"decasyllables", "num"=>76}]
```

### 4. Calculate average value

Run the following command to use the `AVG` aggregation function to get the average value of ingested records:

```bash
docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log             \
     fluent/fluent-bit:1.8.2                                             \
     /fluent-bit/bin/fluent-bit                                          \
         -R /fluent-bit/etc/parsers.conf                                 \
         -i tail                                                         \
             -p path=/sp-samples-1k.log                                  \
             -p parser=json                                              \
             -p read_from_head=true                                      \
         -T "SELECT AVG(num) FROM STREAM:tail.0 WHERE country='Chile';"  \
         -o null -f 1
```

The previous query yields the following output:

```text
[0] [1557323573.940149, {"AVG(num)"=>61.230770}]
[0] [1557323573.941890, {"AVG(num)"=>47.842106}]
[0] [1557323573.943544, {"AVG(num)"=>40.647060}]
[0] [1557323573.945086, {"AVG(num)"=>56.812500}]
[0] [1557323573.945130, {"AVG(num)"=>99.000000}]
```

{% hint style="info" %}
The resulting output contains multiple records because Fluent Bit processes data in chunks, and the stream processor processes each chunk independently. To process multiple chunks at the same time, you can group results using time windows.
{% endhint %}

### 5. Group results and windows

Grouping results within a time window simplifies data processing. Run the following command to group results by `country` and calculate the average of `num` with a one-second processing window:

```bash
docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log        \
     fluent/fluent-bit:1.8.2                                        \
     /fluent-bit/bin/fluent-bit                                     \
         -R /fluent-bit/etc/parsers.conf                            \
         -i tail                                                    \
             -p path=/sp-samples-1k.log                             \
             -p parser=json                                         \
             -p read_from_head=true                                 \
         -T "SELECT country, AVG(num) FROM STREAM:tail.0            \
             WINDOW TUMBLING (1 SECOND)                             \
             WHERE country='Chile'                                  \
             GROUP BY country;"                                     \
         -o null -f 1
```

The previous query yields the following output:

```text
[0] [1557324239.003211, {"country"=>"Chile", "AVG(num)"=>53.164558}]
```

### 6. Ingest stream processor results as a new stream of data

Next, instruct the stream processor to ingest results as part of the Fluent Bit data pipeline and assign a tag to each record.

Run the following command, which uses a `CREATE STREAM` statement to tag results with the `sp-results` tag, then outputs records with that tag to standard output:

```bash
docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log        \
     fluent/fluent-bit:1.8.2                                        \
     /fluent-bit/bin/fluent-bit                                     \
         -R /fluent-bit/etc/parsers.conf                            \
         -i tail                                                    \
             -p path=/sp-samples-1k.log                             \
             -p parser=json                                         \
             -p read_from_head=true                                 \
         -T "CREATE STREAM results WITH (tag='sp-results')          \
             AS                                                     \
               SELECT country, AVG(num) FROM STREAM:tail.0          \
               WINDOW TUMBLING (1 SECOND)                           \
               WHERE country='Chile'                                \
               GROUP BY country;"                                   \
         -o stdout -m 'sp-results' -f 1
```

The previous query yields the following results:

```text
[0] sp-results: [1557325032.000160100, {"country"=>"Chile", "AVG(num)"=>53.164558}]
```
