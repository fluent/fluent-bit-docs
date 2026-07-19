# Documentation Scripts

This directory contains utility scripts for validating Fluent Bit configuration examples in the documentation.

## Configuration Validation

### `test-config.sh`

Validates all Fluent Bit configuration examples in Markdown files by running them through `fluent-bit --dry-run`.

**Usage:**
```bash
./scripts/test-config.sh <markdown-file>
```

**How it works:**

The script uses a **two-stage approach** to ensure reliable error reporting:

1. **Count stage**: For each language (YAML, text), it counts how many examples exist using the `extract-config.sh count` mode
2. **Validation stage**: It extracts and validates each example by index in a predictable way

This approach ensures that extraction errors are always legitimate—never due to reaching the end of examples. Any extraction error indicates a genuine problem with the file structure.

**Features:**
- Supports multiple examples per Markdown file (processes all examples)
- Validates both YAML (`fluent-bit.yaml`) and legacy `.conf` (`fluent-bit.conf`) formats
- Reports all validation failures for a file (doesn't stop at first failure)
- Respects a suppression list for known failing configurations
- Requires Docker/Podman to run the Fluent Bit container
- Only reports errors that are legitimate (malformed examples or configuration issues)

**Example - validate a single file:**
```bash
./scripts/test-config.sh pipeline/inputs/tail.md
```

**Example - validate all documentation files:**
```bash
find . -type f -iname "*.md" | while read -r file; do
    if ! ./scripts/test-config.sh "$file"; then
        echo "FAILED: $file"
    fi
done
```

### `extract-config.sh`

Extracts Fluent Bit configuration code blocks from Markdown files. This is used internally by `test-config.sh` but can also be called directly.

**Usage:**
```bash
./scripts/extract-config.sh <markdown-file> <tab-title> <fence-language> [index|count]
```

**Parameters:**
- `markdown-file`: Path to the Markdown file
- `tab-title`: The tab title (e.g., `"fluent-bit.yaml"` or `"fluent-bit.conf"`)
- `fence-language`: The code fence language (e.g., `yaml` or `text`)
- `index|count` (Optional): Extract a specific example by index, or use `count` to get the total number of examples. Defaults to 1 (first example)

**Examples:**
```bash
# Count total YAML examples in a file
./scripts/extract-config.sh pipeline/inputs/tail.md "fluent-bit.yaml" yaml count

# Extract the first YAML example
./scripts/extract-config.sh pipeline/inputs/tail.md "fluent-bit.yaml" yaml

# Extract the second YAML example
./scripts/extract-config.sh pipeline/inputs/tail.md "fluent-bit.yaml" yaml 2

# Extract the third .conf example
./scripts/extract-config.sh pipeline/inputs/tail.md "fluent-bit.conf" text 3
```

**Count mode:**

The `count` parameter returns the total number of matching code fences for the specified language in the given tab. This is used by `test-config.sh` to:
1. Determine how many examples to validate
2. Avoid trying to extract examples that don't exist
3. Ensure all extraction errors are legitimate

Example output:
```bash
$ ./scripts/extract-config.sh pipeline/inputs/tail.md "fluent-bit.yaml" yaml count
5
```

## Markdown Format

Configuration examples should be formatted using Gitbook-style tabs:

```markdown
{% tabs %}
{% tab title="fluent-bit.yaml" %}
```yaml
service:
  flush: 1
```
{% endtab %}
{% tab title="fluent-bit.conf" %}
```text
[SERVICE]
    Flush  1
```
{% endtab %}
{% endtabs %}
```

Multiple examples in the same file are supported:

```markdown
## First Example

{% tabs %}
{% tab title="fluent-bit.yaml" %}
```yaml
# First example YAML
```
{% endtab %}
{% endtabs %}

## Second Example

{% tabs %}
{% tab title="fluent-bit.yaml" %}
```yaml
# Second example YAML
```
{% endtab %}
{% endtabs %}
```

## Suppression List

Some configuration examples are intentionally skipped in validation. These are configured in the `SUPPRESSED_FILES` array in `test-config.sh`. Files are suppressed if they:

- Require additional plugins not included in the standard container image
- Contain examples that are not yet supported
- Are Windows-specific configurations

Refer to the comments in `test-config.sh` for the complete list and reasons for each suppression.
