# Hands on: Stream Processing 101

This article goes through very specific and simple steps to learn how Stream Processor works. For simplicity it uses a custom Docker image that contains the relevant components for testing.

## Requirements

The following tutorial requires the following software components:

- [Fluent Bit](https://fluentbit.io) >= v1.2.0
- [Docker Engine](https://www.docker.com/products/docker-engine) (not mandatory if you already have Fluent Bit binary installed in your system)

In addition download the following data sample file (130KB):

- https://fluentbit.io/samples/sp-samples-1k.log

## Stream Processing using the command line

For all next steps we will run Fluent Bit from the command line, and for simplicity we will use the official Docker image.

### 1. Fluent Bit version:

```bash
$ docker run -ti fluent/fluent-bit:1.2 /fluent-bit/bin/fluent-bit --version
Fluent Bit v1.2.0
```

### 2. Parse sample files

The samples file contains JSON records. On this command, we are appending the Parsers configuration file and instructing _tail_ input plugin to parse the content as _json_:

```bash
$ docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log      \
     fluent/fluent-bit:1.2                                          \
     /fluent-bit/bin/fluent-bit -R /fluent-bit/etc/parsers.conf     \
                                -i tail -p path=/sp-samples-1k.log  \
                                        -p parser=json              \
                                -o stdout -f 1
```

The command above will simply print the parsed content to the standard output interface. The content will print the _Tag_ associated to each record and an array with two fields: record timestamp and record map:

```
Fluent Bit v1.2.0
Copyright (C) Treasure Data

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

As of now there is no Stream Processing, on step #3 we will start doing some basic queries.

### 3. Selecting specific record keys

This command introduces a Stream Processor (SP) query through the __-T__ option and changes the output plugin to _null_, this is done with the purpose of obtaining the SP results in the standard output interface and avoid confusions in the terminal.

```bash
$ docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log           \
     fluent/fluent-bit:1.2                                               \
     /fluent-bit/bin/fluent-bit                                          \
         -R /fluent-bit/etc/parsers.conf                                 \
         -i tail                                                         \
             -p path=/sp-samples-1k.log                                  \
             -p parser=json                                              \
         -T "SELECT word, num FROM STREAM:tail.0 WHERE country='Chile';" \
         -o null -f 1
```

The query above aims to retrieve all records that a key named _country_ value matches the value _Chile_, and for each match compose and output a record using only the key fields _word_ and _num_:

```
[0] [1557322913.263534, {"word"=>"Candide", "num"=>94}]
[0] [1557322913.263581, {"word"=>"delightfulness", "num"=>99}]
[0] [1557322913.263607, {"word"=>"effulges", "num"=>63}]
[0] [1557322913.263690, {"word"=>"febres", "num"=>21}]
[0] [1557322913.263706, {"word"=>"decasyllables", "num"=>76}]
```

### 4. Calculate Average Value

The following query is similar to the one in the previous step, but this time we will use the aggregation function called AVG() to get the average value of the records ingested:

```bash
$ docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log           \
     fluent/fluent-bit:1.2                                               \
     /fluent-bit/bin/fluent-bit                                          \
         -R /fluent-bit/etc/parsers.conf                                 \
         -i tail                                                         \
             -p path=/sp-samples-1k.log                                  \
             -p parser=json                                              \
         -T "SELECT AVG(num) FROM STREAM:tail.0 WHERE country='Chile';"  \
         -o null -f 1
```

output:

```
[0] [1557323573.940149, {"AVG(num)"=>61.230770}]
[0] [1557323573.941890, {"AVG(num)"=>47.842106}]
[0] [1557323573.943544, {"AVG(num)"=>40.647060}]
[0] [1557323573.945086, {"AVG(num)"=>56.812500}]
[0] [1557323573.945130, {"AVG(num)"=>99.000000}]
```

why did we get multiple records? Answer: When Fluent Bit processes the data, records come in chunks and the Stream Processor runs the process over chunks of data, so the input plugin ingested 5 chunks of records and SP processed the query for each chunk independently. To process multiple chunks at once we have to group results during windows of time.

### 5. Grouping Results and Window

Grouping results aims to simplify data processing and when used in a defined window of time we can achieve great things. The next query group the results by _country_ and calculate the average of _num_ value, the processing window is 1 second which basically means: process all incoming chunks coming within 1 second window:

```bash
$ docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log      \
     fluent/fluent-bit:1.2                                          \
     /fluent-bit/bin/fluent-bit                                     \
         -R /fluent-bit/etc/parsers.conf                            \
         -i tail                                                    \
             -p path=/sp-samples-1k.log                             \
             -p parser=json                                         \
         -T "SELECT country, AVG(num) FROM STREAM:tail.0            \
             WINDOW TUMBLING (1 SECOND)                             \
             WHERE country='Chile'                                  \
             GROUP BY country;"                                     \
         -o null -f 1
```

output:

```
[0] [1557324239.003211, {"country"=>"Chile", "AVG(num)"=>53.164558}]
```

### 6. Ingest Stream Processor results as new Stream of Data

Now we see a more real-world use case. Sending data results to the standard output interface is good for learning purposes, but now we will instruct the Stream Processor to ingest results as part of Fluent Bit data pipeline and attach a Tag to them.

This can be done using the __CREATE STREAM__ statement that will also tag results with __sp-results__ value. Note that output plugin parameter is now _stdout_ matching all records tagged with _sp-results_:

```bash
$ docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log      \
     fluent/fluent-bit:1.2                                          \
     /fluent-bit/bin/fluent-bit                                     \
         -R /fluent-bit/etc/parsers.conf                            \
         -i tail                                                    \
             -p path=/sp-samples-1k.log                             \
             -p parser=json                                         \
         -T "CREATE STREAM results WITH (tag='sp-results')          \
             AS                                                     \
               SELECT country, AVG(num) FROM STREAM:tail.0          \
               WINDOW TUMBLING (1 SECOND)                           \
               WHERE country='Chile'                                \
               GROUP BY country;"                                   \
         -o stdout -m 'sp-results' -f 1
```

output:

```
[0] sp-results: [1557325032.000160100, {"country"=>"Chile", "AVG(num)"=>53.164558}]
```

## F.A.Q

### Where STREAM name comes from?

Fluent Bit have the notion of streams, and every input plugin instance gets a default name. You can override that behavior by setting an alias. Check the __alias__ parameter and new __stream__ name in the following example:

```bash
$ docker run -ti -v `pwd`/sp-samples-1k.log:/sp-samples-1k.log      \
     fluent/fluent-bit:1.2                                          \
     /fluent-bit/bin/fluent-bit                                     \
         -R /fluent-bit/etc/parsers.conf                            \
         -i tail                                                    \
             -p path=/sp-samples-1k.log                             \
             -p parser=json                                         \
             -p alias=samples                                       \
         -T "CREATE STREAM results WITH (tag='sp-results')          \
             AS                                                     \
               SELECT country, AVG(num) FROM STREAM:samples         \
               WINDOW TUMBLING (1 SECOND)                           \
               WHERE country='Chile'                                \
               GROUP BY country;"                                   \
         -o stdout -m 'sp-results' -f 1
```
