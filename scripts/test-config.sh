#!/usr/bin/env bash
set -euo pipefail

# This script is used to test configuration snippets extracted from the documentation.
# It will run each extracted configuration through Fluent Bit's dry-run mode to validate it.
# Supports multiple examples per Markdown file and reports all validation failures.
# Errors are on stderr and the script will exit with a non-zero status if any validation fails.

# To run for all Markdown files in the repository, you can use the following command:
# find . -type f -iname "*.md" | while read -r file; do
#     if ! ./scripts/test-config.sh "$file"; then
#         echo "FAILED: $file" | tee -a "$LOG_FILE"
#     fi
# done

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

FILE=${1:?"Usage: $0 FILE"}
if [ ! -f "${FILE}" ]; then
    echo "ERROR: File $FILE does not exist or is not readable" >&2
    exit 1
fi

# Check if the file is listed in the suppression list. If it is, we skip validation for this file.
# We just use an array of suppressed files for now - add any new files to suppress to this list.
SUPPRESSED_FILES=(
    # These currently fail due to a known issue so skip them for now. See https://github.com/fluent/fluent-bit/issues/12113 and remove suppressions once this is in place.
    "pipeline/outputs/azure_blob.md"
    "pipeline/outputs/nats.md"
    "pipeline/outputs/kafka-rest-proxy.md"
    # Skip the examples for contribution.
    "CONTRIBUTING.md"
    # Requires the WASM filter to be built and loaded.
    "pipeline/filters/wasm.md"
    "development/wasm-filter-plugins.md"
    # Requires loading the actual LUA scripts as well.
    "pipeline/filters/lua.md"
    # Exec is not supported in the container image.
    "pipeline/inputs/exec.md"
    # Requires custom golang plugins to be built and loaded.
    "development/golang-output-plugins.md"
    # Not currently supported in the container image.
    "pipeline/filters/tensorflow.md"
    "pipeline/inputs/ebpf.md"
    # Windows plugins are not available in the Linux image.
    "installation/downloads/windows.md"
    "pipeline/inputs/windows-event-log-winevtlog.md"
    "pipeline/inputs/windows-system-statistics.md"
    "pipeline/inputs/windows-exporter-metrics.md"
    "pipeline/inputs/windows-event-log.md"
    # Windows-specific configuration examples are not supported in the Linux image.
    "installation/downloads/kubernetes.md"
)
for suppressed_file in "${SUPPRESSED_FILES[@]}"; do
    if [[ "$FILE" == "$suppressed_file" ]]; then
        echo "INFO: Skipping validation for suppressed file $FILE"
        exit 0
    fi
    # Use a wildcard match to check if the file path matches any of the suppressed files. This allows for more flexible matching.
    if [[ "$FILE" == *"$suppressed_file"* ]]; then
        echo "INFO: Skipping validation for suppressed file $FILE"
        exit 0
    fi
    # Check if the file is in a subdirectory of any suppressed file. This allows for suppressing entire directories of files if needed.
    if [[ "$FILE" == */"$suppressed_file" || "$FILE" == */"$suppressed_file"/* ]]; then
        echo "INFO: Skipping validation for suppressed file $FILE"
        exit 0
    fi
done

CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}
# Always pull the latest Fluent Bit image to ensure we are validating against the most recent version.
if ! $CONTAINER_RUNTIME pull fluent/fluent-bit:latest &>/dev/null; then
    echo "ERROR: Failed to pull Fluent Bit container image" >&2
    exit 1
fi

FAILED_VALIDATIONS=()
PASSED_VALIDATIONS=0

# Loop over YAML and legacy .conf configurations
for LANGUAGE in "yaml" "text"; do
    if [ "$LANGUAGE" = "yaml" ]; then
        TAB_TITLE="fluent-bit.yaml"
        OUTPUT_FILE="/tmp/fluent-bit.yaml"
    else
        TAB_TITLE="fluent-bit.conf"
        OUTPUT_FILE="/tmp/fluent-bit.conf"
    fi

    # Stage 1: Count how many examples exist for this language in the file
    # We do this so we know we should have X examples to validate, and we can report if any are missing or fail validation or extraction.
    EXAMPLE_COUNT=$("$SCRIPT_DIR/extract-config.sh" "$FILE" "$TAB_TITLE" "$LANGUAGE" count 2>/dev/null || echo 0)
    
    if [ "$EXAMPLE_COUNT" -eq 0 ]; then
        continue
    fi

    # Stage 2: Extract and validate each example by index
    for ((EXAMPLE_INDEX = 1; EXAMPLE_INDEX <= EXAMPLE_COUNT; EXAMPLE_INDEX++)); do
        # Extract the configuration snippet from the Markdown file
        if ! "$SCRIPT_DIR/extract-config.sh" "$FILE" "$TAB_TITLE" "$LANGUAGE" "$EXAMPLE_INDEX" > "$OUTPUT_FILE"; then
            # Extraction should not fail at this point since we counted the examples
            echo "ERROR: Failed to extract $LANGUAGE example $EXAMPLE_INDEX from $FILE (count was $EXAMPLE_COUNT)" >&2
            FAILED_VALIDATIONS+=("$LANGUAGE example $EXAMPLE_INDEX")
            continue
        fi

        # If the output file is empty, skip validation
        if [ ! -s "$OUTPUT_FILE" ]; then
            continue
        fi
       
        # Use the Fluent Bit container to validate the configuration snippet
        if ! $CONTAINER_RUNTIME run --rm -t -v "$OUTPUT_FILE":"$OUTPUT_FILE":ro fluent/fluent-bit:latest fluent-bit --dry-run --config="$OUTPUT_FILE" &>/dev/null; then
            FAILED_VALIDATIONS+=("$LANGUAGE example $EXAMPLE_INDEX")
            # Provide the configuration and failure output for debugging purposes on stderr
            echo "ERROR: Validation failed for $LANGUAGE example $EXAMPLE_INDEX in $FILE" >&2
            cat "$OUTPUT_FILE" >&2
            $CONTAINER_RUNTIME run --rm -t -v "$OUTPUT_FILE":"$OUTPUT_FILE":ro fluent/fluent-bit:latest fluent-bit --dry-run --config="$OUTPUT_FILE" >&2 || true
        else
            PASSED_VALIDATIONS=$((PASSED_VALIDATIONS + 1))
        fi
    done
done

# Report results
if [ ${#FAILED_VALIDATIONS[@]} -gt 0 ]; then
    echo "ERROR: $FILE had ${#FAILED_VALIDATIONS[@]} validation failure(s):" >&2
    for failed in "${FAILED_VALIDATIONS[@]}"; do
        echo "  - $failed" >&2
    done
    exit 1
fi

if [ $PASSED_VALIDATIONS -eq 0 ]; then
    echo "INFO: No configuration examples found in $FILE"
else
    echo "INFO: All $PASSED_VALIDATIONS check(s) passed for $FILE"
fi
