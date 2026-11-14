# Documentation scripts

This directory contains utility scripts for validating Fluent Bit configuration examples in the documentation.

## Configuration validation

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
- `tab-title`: The tab title (for example, `"fluent-bit.yaml"` or `"fluent-bit.conf"`)
- `fence-language`: The code fence language (for example, `yaml` or `text`)
- `index|count` (Optional): Extract a specific example by index, or use `count` to get the total number of examples. Defaults to 1 (first example)

**Features:**

- Automatically removes common leading indentation from extracted examples
- Handles indented tabs in Markdown (for example, nested within list items or other structures)
- Preserves relative indentation within the configuration

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

### `validate-changed-files.sh`

Validates configuration examples in Markdown files that have been changed relative to a base branch. This script is used by the CI/CD pipeline but can also be run locally before pushing changes.

**Usage:**

```bash
./scripts/validate-changed-files.sh [base_ref] [head_ref]
```

**Parameters:**

- `base_ref` (optional): The base commit/branch to compare against. Defaults to `origin/main`
- `head_ref` (optional): The head commit/branch to compare to. Defaults to `HEAD`

**How it works:**

1. Uses `get-changed-files.sh` to identify Markdown files changed between the base and head refs
2. Runs `test-config.sh` on each changed file
3. Reports all validation failures
4. Exits with non-zero status if any file validation fails

**Examples:**

```bash
# Validate changes in current branch against origin/main
./scripts/validate-changed-files.sh

# Validate changes in a specific branch
./scripts/validate-changed-files.sh origin/main origin/feature-branch

# Validate changes between specific commits
./scripts/validate-changed-files.sh abc123def456 xyz789abc123
```

### `get-changed-files.sh`

Identifies Markdown files that have been changed between two commits or branches. This is used by `validate-changed-files.sh` but can also be called directly for scripting purposes.

**Usage:**

```bash
./scripts/get-changed-files.sh [base_ref] [head_ref]
```

**Parameters:**

- `base_ref` (optional): The base commit/branch to compare against. Defaults to `origin/main`
- `head_ref` (optional): The head commit/branch to compare to. Defaults to `HEAD`

**How it works:**

Uses `git diff` to find files that have been Added, Modified, Copied, or Renamed (AMCR) between the two refs, filtering for `.md` files only.

**Output:**

Lists changed Markdown files, one per line.

**Examples:**

```bash
# Find changes in current branch against origin/main
./scripts/get-changed-files.sh

# Find changes in a specific branch
./scripts/get-changed-files.sh origin/main origin/feature-branch

# Using commit range format (with three dots)
./scripts/get-changed-files.sh origin/main...HEAD

# Iterate over changed files for processing
./scripts/get-changed-files.sh | while read -r file; do
    echo "Processing: $file"
    # Your processing logic here
done
```

## Markdown format

Configuration examples should be formatted using Gitbook-style tabs:

````markdown
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
````

Multiple examples in the same file are supported:

````markdown
## First example

{% tabs %}
{% tab title="fluent-bit.yaml" %}
```yaml
# First example YAML
```
{% endtab %}
{% endtabs %}

## Second example

{% tabs %}
{% tab title="fluent-bit.yaml" %}
```yaml
# Second example YAML
```
{% endtab %}
{% endtabs %}
````

## Suppression list

Some configuration examples are intentionally skipped in validation. These are configured in the `SUPPRESSED_FILES` array in `test-config.sh`. Files are suppressed if they:

- Require additional plugins not included in the standard container image
- Contain examples that aren't yet supported
- Are Windows-specific configurations

Refer to the comments in `test-config.sh` for the complete list and reasons for each suppression.
