# Includes Section

The `includes` section allows you to specify additional YAML configuration files to be merged into the current configuration. These files are identified as a list of filenames and can include relative or absolute paths. If no absolute path is provided, the file is assumed to be located in a directory relative to the file that references it.

This feature is useful for organizing complex configurations into smaller, manageable files and including them as needed.

### Usage

Below is an example demonstrating how to include additional YAML files using relative path references. This is the file system path structure

```
├── fluent-bit.yaml
├── inclusion-1.yaml
└── subdir
    └── inclusion-2.yaml
```

The content of `fluent-bit.yaml`

```yaml
includes:
  - inclusion-1.yaml
  - subdir/inclusion-2.yaml
```

## Key Points

- Relative Paths: If a path is not specified as absolute, it will be treated as relative to the file that includes it.

- Organized Configurations: Using the includes section helps keep your configuration modular and easier to maintain.

> note: Ensure that the included files are formatted correctly and contain valid YAML configurations for seamless integration.
