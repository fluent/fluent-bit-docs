---
description: Powerful and flexible routing
---

# Rewrite Tag

Tags are what makes [routing]( /concepts/data-pipeline/router.md) possible. Tags are set in the configuration of the Input definitions where the records are generated, but there are certain scenarios where might be useful to modify the Tag in the pipeline so we can perform more advanced and flexible routing. 

The ```rewrite_tag``` filter, allows to re-emit a record under a new Tag. Once a record has been re-emitted, the  original record can be preserved or discarded.

## How it Works

The way it works is defining rules that matches specific record key content against a regular expression, if a match exists, a new record with the defined Tag will be emitted. Multiple rules can be specified and they are processed in order until one of them matches.

The new Tag to define can be composed by:

- Alphabet characters & Numbers
- Original Tag string or part of it
- Regular Expressions groups capture
- Any key or sub-key of the processed record 
- Environment variables

## Configuration Parameters

The ```rewrite_tag``` filter supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Rule | Defines the matching criteria and the format of the Tag for the matching record. The Rule format have four components: ```KEY REGEX NEW_TAG KEEP```. For more specific details of the Rule format and it composition read the next section. |
| Emitter_Name | When the filter emits a record under the new Tag, there is an internal emitter plugin that takes care of the job. Since this emitter expose metrics as any other component of the pipeline, you can use this property to configure an optional name for it. |

## Rules

A rule aims to define matching criteria and specify how to create a new Tag for a record. You can define one or multiple rules in the same configuration section. The rules have the following format:

```
$KEY  REGEX  NEW_TAG  KEEP
```

### Key

The key represents the name of the *record key* that holds the *value* that we want to use to match our regular expression. A key name is specified and prefixed with a ```$```. Consider the following structured record (formatted for readability):

```json
{
  "name": "abc-123",
  "ss": {
    "s1": {
      "s2": "flb"
    }
  }
}
```

If we wanted to match against the value of the key ```name``` we must use ```$name```. The key selector is flexible enough to allow to match nested levels of sub-maps from the structure. If we wanted to check the value of the nested key ```s2``` we can do it specifying ```$ss['s1']['s2']```, for short:

- ```$name``` = "abc-123"
- ```$ss['s1']['s2']``` = "flb"

Note that a key must point a value that contains a string, it's **not valid** for numbers, booleans, maps or arrays.

### Regex

Using a simple regular expression we can specify a matching pattern to use against the value of the key specified above, also we can take advantage of group capturing to create custom placeholder values.

If we wanted to match any record that it ```$name``` contains a value of the format ```string-number``` like the example provided above, we might use:

```regex
^([a-z]+)-([0-9]+)$
```

Note that in our example we are using parentheses, this teams that we are specifying groups of data. If the pattern matches the value a placeholder will be created that can be consumed by the NEW_TAG section.

If ```$name``` equals ```abc-123``` , then the following **placeholders** will be created:

- ```$0``` = "abc-123"
- ```$1``` = "abc"
- ```$2``` = "123"

If the Regular expression do not matches an incoming record, the rule will be skipped and the next rule (if any) will be processed.

### New Tag

If a regular expression has matched the value of the defined key in the rule, we are ready to compose a new Tag for that specific record. The tag is a concatenated string that can contain any of the following characters: ```a-z```,```A-Z```, ```0-9``` and ```.-, ```.

A Tag can take any string value from the matching record, the original tag it self, environment variable or general placeholder. 

Consider the following incoming data on the rule:

- Tag = aa.bb.cc
- Record =  ```{"name": "abc-123", "ss": {"s1": {"s2": "flb"}}}```
- Environment variable $HOSTNAME = fluent

With such information we could create a very custom Tag for our record like the following:

```
newtag.$TAG.$TAG[1].$1.$ss['s1']['s2'].out.${HOSTNAME}
```

the expected Tag to generated will be:

```
newtag.aa.bb.cc.bb.abc.flb.out.fluent
```

We make use of placeholders, record content and environment variables.

### Keep

If a rule matches the criteria the filter will emit a copy of the record with the new defined Tag. The property keep takes a boolean value to define if the original record with the old Tag must be preserved and continue in the pipeline or just be discarded. 

You can use ```true``` or ```false``` to decide the expected behavior. There is no default value and this is a mandatory field in the rule.

## Configuration Example

The following configuration example will emit a dummy (hand-crafted) record, the filter will rewrite the tag, discard the old record and print the new record to the standard output interface:

```python
[SERVICE]
    Flush     1
    Log_Level info

[INPUT]
    NAME   dummy
    Dummy  {"tool": "fluent", "sub": {"s1": {"s2": "bit"}}}
    Tag    test_tag

[FILTER]
    Name          rewrite_tag
    Match         test_tag
    Rule          $tool ^(fluent)$  from.$TAG.new.$tool.$sub['s1']['s2'].out false
    Emitter_Name  

[OUTPUT]
    Name  stdout
    Match from.*
```

The original tag ```test_tag``` will be rewritten as ```from.test_tag.new.fluent.bit.out```:

```bash
$ bin/fluent-bit -c example.conf 
Fluent Bit v1.4.0
Copyright (C) Treasure Data

...
[0] from.test_tag.new.fluent.bit.out: [1580436933.000050569, {"tool"=>"fluent", "sub"=>{"s1"=>{"s2"=>"bit"}}}]

```

## Monitoring

As described in the [Monitoring](/administration/monitoring) section, every component of the pipeline of Fluent Bit exposes metrics. The basic metrics exposed by this filter are ```drop_records``` and ```add_records```, they summarize the total of dropped records from the incoming data chunk or the new records added. 

Since ```rewrite_tag``` emit new records that goes through the beginning of the pipeline, it exposes an additional metric called ```emit_records``` that summarize the total number of emitted records.

### Understanding the Metrics

Using the configuration provided above, if we query the metrics exposed in the HTTP interface we will see the following:

Command:

```bash
$ curl  http://127.0.0.1:2020/api/v1/metrics/ | jq
```

Metrics output:

```json
{
  "input": {
    "dummy.0": {
      "records": 2,
      "bytes": 80
    },
    "emitter_for_rewrite_tag.0": {
      "records": 1,
      "bytes": 40
    }
  },
  "filter": {
    "rewrite_tag.0": {
      "drop_records": 2,
      "add_records": 0,
      "emit_records": 2
    }
  },
  "output": {
    "stdout.0": {
      "proc_records": 1,
      "proc_bytes": 40,
      "errors": 0,
      "retries": 0,
      "retries_failed": 0
    }
  }
}
```

The *dummy* input generated two records,  the filter dropped two from the chunks and emitted two new ones under a different Tag. 

The records generated are handled by the internal Emitter, so the new records are summarized in the Emitter metrics, take a look at the entry called ```emitter_for_rewrite_tag.0```.

### What is the Emitter ?

The Emitter is an internal Fluent Bit plugin that allows other components of the pipeline to emit custom records. On this case ```rewrite_tag``` creates an Emitter instance to use it exclusively to emit records, on that way we can have a granular control of *who* is emitting what.

The Emitter name in the metrics can be changed setting up the ```Emitter_Name``` configuration property described above.

