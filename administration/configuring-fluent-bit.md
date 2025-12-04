# Configure Fluent Bit

Fluent Bit uses configuration files to store information about your specified [inputs](../pipeline/inputs.md), [outputs](../pipeline/outputs.md), [filters](../pipeline/filters.md), and more. You can write these configuration files in one of these formats:

- [YAML configuration files](./configuring-fluent-bit/yaml.md) are the standard configuration format as of Fluent Bit v3.2. They use the `.yaml` file extension.
- [Classic configuration files](./configuring-fluent-bit/classic-mode.md) will be deprecated at the end of 2026. They use the `.conf` file extension.

## Unit sizes

Some configuration settings in Fluent Bit use standardized unit sizes to define data and storage limits. For example, the `buffer_chunk_size` and `buffer_max_size` parameters for the [Tail](../data-pipeline/inputs/tail.md) input plugin use unit sizes.

The following table describes the unit sizes you can use and what they mean.

| Suffix | Description | Example |
| :--- | :--- | :--- |
| _none_ | **Bytes**: If you specify an integer without a unit size, Fluent Bit interprets that value as a bytes representation. | `32000` means 32,000 bytes. |
| `k`, `kb`, `K`, `KB` | **Kilobytes**: A unit of memory equal to 1,000 bytes. | `32k` means 32,000 bytes. |
| `m`, `mb`, `M`, `MB` | **Megabytes**: A unit of memory equal to 1,000,000 bytes. | `32m` means 32,000,000 bytes. |
| `g`, `gb`, `G`, `GB` | **Gigabytes**: A unit of memory equal to 1,000,000,000 bytes. | `32g` means 32,000,000,000 bytes. |

## Command line interface

Fluent Bit exposes most of its configuration features through the command line interface. Use the `-h` or `--help` flag to see a list of available options.

```shell
# Podman container tooling.
podman run -rm -ti fluent/fluent-bit --help

# Docker container tooling.
docker run --rm -it fluent/fluent-bit --help
```
