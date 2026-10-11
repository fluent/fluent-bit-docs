# Includes

The `includes` section of YAML configuration files lets you specify additional YAML files to be merged into the current configuration. This lets you organize complex configurations into smaller, manageable files and include them as needed.

These files are identified as a list of filenames and can include relative or absolute paths. If a path isn't specified as absolute, it will be treated as relative to the file that includes it. In v5.1.3 or later, if the file isn't found relative to the including file, Fluent Bit tries the path relative to the working directory. On Windows, both `\` and `/` work as path separators, and drive-letter and Universal Naming Convention (UNC) paths are treated as absolute.

## Usage

The following example demonstrates how to include additional YAML files using relative path references. This is the file system path structure:

```text
├── fluent-bit.yaml
├── inclusion-1.yaml
└── subdir
    └── inclusion-2.yaml
```

{% hint style="info" %}
Environment variables aren't supported in includes section. The path for each file must be specified as a literal string.
{% endhint %}

You can reference these files in `fluent-bit.yaml` as follows:

```yaml
includes:
  - inclusion-1.yaml
  - subdir/inclusion-2.yaml
```

Ensure that the included files are formatted correctly and contain valid YAML configurations for seamless integration.
