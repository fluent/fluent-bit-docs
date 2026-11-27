# Includes

The `includes` section of YAML configuration files lets you specify additional YAML files to be combined with the current configuration. This lets you organize complex configurations into smaller, manageable files and include them as needed.

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
Environment variables aren't supported in includes section. The path for each file must be specified as a literal string or as an alias of a string. For more information about aliases, see [Defaults](./defaults-section.md).
{% endhint %}

You can reference these files in `fluent-bit.yaml` as follows:

```yaml
includes:
  - inclusion-1.yaml
  - subdir/inclusion-2.yaml
```

Ensure that the included files are formatted correctly and contain valid YAML configurations for seamless integration.

## How includes are combined

Fluent Bit combines the main file and every included file into one configuration before it reads any section:

- Each included file's top-level sections are inserted where its `includes` entry appears, in list order. Fluent Bit reads each file in the list before it reads the next entry, and included files can have their own `includes` section.
- Sections such as `pipeline` can appear in more than one file. Their contents are combined in the order described in the previous item. The `service` section is an exception: defining `service` more than once, in one file or across files, is an error.
- The `includes` key must be written literally as a top-level key. It can't come from a merge key (`<<`). The `includes` key isn't case-sensitive.

Because included files are combined in this order, YAML anchors defined in an included file can be used by aliases that appear after the `includes` entry for that file. For details, see [Defaults](./defaults-section.md).

## Wildcards

An include path that contains `*` is a wildcard pattern. A path without `*` is opened as a literal filename, even if it contains other wildcard characters such as `?` or `[`.

- A relative wildcard pattern is resolved only against the directory of the including file. It doesn't fall back to the working directory.
- On Linux and macOS, a relative pattern that matches no files logs a `no match` warning and is skipped. An absolute pattern must match at least one file, or Fluent Bit stops with an error. A directory in the pattern that exists but can't be read, such as one without read permission, is an error for both kinds of pattern. To keep a drop-in directory optional, use a relative pattern, or keep a placeholder file in the directory.
- On Windows, a pattern that matches no files, or whose directory can't be read, is skipped without a warning, whether it's relative or absolute.
- On Linux and macOS, a directory whose name matches the pattern is read as a file, which is an error. Windows skips directories.
- A pattern can match the including file itself. For example, `*.yaml` in `fluent-bit.yaml` matches `fluent-bit.yaml`, which is an error. Keep files that are included by a wildcard in their own directory.
- Fluent Bit doesn't sort the files matched by a pattern. Don't rely on the order of files matched by one pattern, for example for anchors that one matched file defines and another uses. List those files as separate entries instead.

{% hint style="warning" %}
A file included by a wildcard can define any configuration, such as inputs that run commands, outputs that send data to other hosts, or plugins to load. It can also redefine anchors used elsewhere, and variables in the `env` section. New `env` values also apply where those variables are used earlier in the configuration. Anyone who can add a file to a matched directory can change what Fluent Bit runs and where it sends data. Make sure that only the account that runs Fluent Bit, or an administrator, can write to directories matched by a wildcard. Listing a file explicitly doesn't protect its anchors: a file matched by a later wildcard can redefine an anchor, and aliases after that use the new value. Restricting write access to the matched directories is the only protection.
{% endhint %}

## Limits and errors

Fluent Bit stops with an error when any of the following happens:

- An included file can't be opened. The error is the system error, such as `No such file or directory`.
- An included file contains invalid YAML. The error names the file, line, and column.
- The same path is included more than once, for example by a listed file and a wildcard pattern in the same directory that also matches it. The error is `file '<path>' is already included`.
- A file includes itself, directly or through other files, by a path in the same directory as the original. This returns the same error.
- A chain of nested includes is longer than 256 files, counting the main file. The error is `maximum YAML include depth (256) exceeded`.
- The configuration uses more than 4,096 files, including the main file and empty files. The error is `YAML included file limit (4096) exceeded`.
- The combined files exceed the limits listed in [Defaults](./defaults-section.md#limits).

For an include error, a following line names the including file, the line number, and the `includes` entry that failed, such as `including file 'missing.yaml' at fluent-bit.yaml:2`. If the entry or the whole `includes` list is an alias, the file and line number are where the path is written instead. For an aliased entry, such as `- *inputs_file`, that's the anchor. For an aliased list, it's the item inside the anchored list. That location can be in a different file.

On Linux and macOS, an include loop is always stopped with an error, whatever paths it uses. One exception applies to the previous list. Fluent Bit reads a link to an including file in a different directory as a separate file, because its relative includes resolve against that directory. That file is included again without an error and creates its plugins twice. Other repeated includes are detected by comparing paths, not files. The same file reached through a different path, such as `./inputs.yaml` and `inputs.yaml`, an absolute path, or a symbolic link, is also included again without an error. Write the path to each file in only one way.
