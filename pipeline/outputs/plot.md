---
description: Generate data file for GNU Plot
---

# Plot

The _Plot_ output plugin generates data files in a format compatible with [GNU Plot](http://www.gnuplot.info/) (`gnuplot`), a command-line graphing tool. This plugin allows you to export your telemetry data for visualization and analysis using `gnuplot`.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `File` | Set filename to store the records. If not set, the filename will be the `tag` associated with the records. If the file cannot be opened, the plugin falls back to writing to STDOUT. | _none_ |
| `Key` | Specify the key name from the record to extract as the value. The value must be a numeric type (integer or float). If not specified, the plugin uses the first field from the record. | _none_ |

## Output format

The Plot output plugin generates data files in a format suitable for `gnuplot`. The output format is space-separated values with two columns: timestamp and value.

The output format is:

```text
timestamp value
```

Where:
- `timestamp` is a floating-point Unix timestamp
- `value` is the numeric value extracted from the specified key (or the first field if `Key` is not specified)

The plugin only supports numeric values (integers or floats). If the specified key is not found or the value is not numeric, an error is logged and the record is skipped.

## Get started

You can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can generate plot data files with the following options:

```shell
fluent-bit -i cpu -o plot -p file=cpu_data.dat -p key=cpu_p
```

This example extracts the `cpu_p` field from CPU metrics and writes timestamp-value pairs to `cpu_data.dat`.

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: plot
      match: '*'
      file: cpu_data.dat
      key: cpu_p
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name  plot
  Match *
  File  cpu_data.dat
  Key   cpu_p
```

{% endtab %}
{% endtabs %}

## Example usage with `gnuplot`

After generating the data file with Fluent Bit, you can use `gnuplot` to visualize the data:

1. Generate the data file:

```shell
fluent-bit -i cpu -o plot -p file=cpu_data.dat -p key=cpu_p -f 1
```

This command collects CPU metrics, extracts the `cpu_p` field (CPU percentage), and writes timestamp-value pairs to `cpu_data.dat`. The output file will contain lines like:

```text
1704067200.123456 25.5
1704067201.123456 30.2
1704067202.123456 28.7
```

2. Create a `gnuplot` script (for example, `plot.gp`):

```text
set terminal png
set output "cpu_usage.png"
set xlabel "Time"
set ylabel "CPU Usage (%)"
set xdata time
set timefmt "%s"
set format x "%H:%M:%S"
plot "cpu_data.dat" using 1:2 with lines title "CPU Usage"
```

3. Run `gnuplot`:

```shell
gnuplot plot.gp
```

This will generate a PNG image file showing the CPU usage over time.

## Notes

- The `Key` parameter is optional. If not specified, the plugin uses the first field from the record.
- Only numeric values (integers or floats) are supported. Non-numeric values will cause the record to be skipped with an error logged.
- If the specified `Key` is not found in a record, an error is logged and that record is skipped.
- If the output file can't be opened (for example, due to permissions), the plugin automatically falls back to writing to STDOUT.
- The output file is opened in append mode, so new data is added to existing files.
