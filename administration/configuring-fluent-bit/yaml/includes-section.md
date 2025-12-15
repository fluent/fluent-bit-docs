# Includes

The `includes` section lets you specify additional YAML configuration files to be merged into the current configuration. These files are identified as a list of filenames and can include relative or absolute paths. If no absolute path is provided, the file is assumed to be located in a directory relative to the file that references it.

Use this section to organize complex configurations into smaller, manageable files and include them as needed.

## Usage

The following example demonstrates how to include additional YAML files using relative path references. This is the file system path structure:

```text
├── fluent-bit.yaml
├── inclusion-1.yaml
└── subdir
    └── inclusion-2.yaml
```

The content of `fluent-bit.yaml`:

```yaml
includes:
  - inclusion-1.yaml
  - subdir/inclusion-2.yaml
```

Ensure that the included files are formatted correctly and contain valid YAML configurations for seamless integration.

If a path isn't specified as absolute, it will be treated as relative to the file that includes it.

Environment variables aren't supported in includes section. The file path must be specified as a literal string.