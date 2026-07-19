#!/usr/bin/env sh
set -eu

# This script extracts the contents of a code fence from a specific tab in a markdown file.
# The intention is to extract code snippets from the documentation to then validate them in CI.
# We are looking for a tab with a specific title and then a code fence with a specific language inside that tab.
# For example, given the following markdown snippet:

# The following example captures Fluent Bit internal logs and writes them to standard output:
# {% tabs %}
# {% tab title="fluent-bit.yaml" %}
# ```yaml
# service:
#   flush: 1
#   log_level: info
# pipeline:
#   inputs:
#     - name: fluentbit_logs
#       tag: internal.logs
#   outputs:
#     - name: stdout
#       match: 'internal.logs'
# ```
# {% endtab %}
# {% tab title="fluent-bit.conf" %}
# ```text
# [SERVICE]
#     Flush     1
#     Log_Level info
# [INPUT]
#     Name  fluentbit_logs
#     Tag   internal.logs
# [OUTPUT]
#     Name  stdout
#     Match internal.logs
# ```
# {% endtab %}
# {% endtabs %}
# To forward ...
# END

# We want to pull out the contents of the code fence with language "yaml"/"text" from the tab with title "fluent-bit.yaml"/"fluent-bit.conf".
# Usage: ./extract-config.sh <file> <tab title> <fence language> [index|count]
# e.g.
#   ./extract-config.sh README.md "fluent-bit.yaml" yaml         # Extract first example
#   ./extract-config.sh README.md "fluent-bit.yaml" yaml 2       # Extract second example
#   ./extract-config.sh README.md "fluent-bit.yaml" yaml count   # Count total examples
#

FILE=${1:?"Usage: $0 FILE TAB_TITLE LANGUAGE [INDEX|count]"}
TITLE=${2:?"Usage: $0 FILE TAB_TITLE LANGUAGE [INDEX|count]"}
LANGUAGE=${3:?"Usage: $0 FILE TAB_TITLE LANGUAGE [INDEX|count]"}
INDEX_OR_MODE=${4:-1}  # Extract the Nth matching code fence, or use "count" to get total count

# We only use AWK to keep it simple and portable. 
# We could use a more powerful parser, but that would require additional dependencies.
# For macOS ensure AWK is GNU awk (gawk) and not the default BSD awk. You can install gawk via Homebrew: `brew install gawk`.

awk -v wanted_title="$TITLE" -v wanted_language="$LANGUAGE" -v target_index_or_mode="$INDEX_OR_MODE" '
BEGIN {
    tab_marker = "{% tab title=\"" wanted_title "\" %}"
    fence_marker = "```" wanted_language
    fence_count = 0
    count_mode = (target_index_or_mode == "count")
    if (!count_mode) {
        target_index = int(target_index_or_mode)
    }
    line_count = 0
    min_indent = -1
}

{
    # Remove a trailing carriage return from CRLF input.
    line = $0
    sub(/\r$/, "", line)

    # Ignore whitespace surrounding directives and fences.
    marker = line
    sub(/^[[:space:]]+/, "", marker)
    sub(/[[:space:]]+$/, "", marker)

    if (!in_tab) {
        if (marker == tab_marker) {
            found_tab = 1
            in_tab = 1
        }
        next
    }

    if (!in_fence) {
        if (marker == "{% endtab %}") {
            if (count_mode) {
                # In count mode, reset in_tab to look for more tabs
                in_tab = 0
            } else if (fence_count < target_index) {
                # Reset and look for the next tab if we havent found enough fences yet
                in_tab = 0
                found_tab = 1  # Keep looking for more tabs
            }
            next
        }

        if (marker == fence_marker) {
            fence_count++
            if (count_mode) {
                # In count mode, just keep counting
                next
            }
            if (fence_count == target_index) {
                found_fence = 1
                in_fence = 1
            }
        }

        next
    }

    if (marker == "```") {
        closed_fence = 1
        exit
    }

    # Store line for later processing (to handle indentation removal)
    if (!count_mode && in_fence && fence_count == target_index) {
        lines[line_count] = line
        
        # Calculate minimum indentation from non-empty lines
        if (line != "") {
            # Count leading spaces
            indent = 0
            for (i = 1; i <= length(line); i++) {
                if (substr(line, i, 1) == " ") {
                    indent++
                } else {
                    break
                }
            }
            if (min_indent == -1 || indent < min_indent) {
                min_indent = indent
            }
        }
        line_count++
    }
}

END {
    if (count_mode) {
        # In count mode, output the count
        print fence_count
    } else {
        # In extract mode, first validate that we found what we were looking for
        if (found_tab && found_fence) {
            if (!closed_fence) {
                printf "ERROR: code fence was not closed in tab: %s\n", wanted_title > "/dev/stderr"
                exit 1
            }
            # Print lines with common leading indentation removed
            for (i = 0; i < line_count; i++) {
                line = lines[i]
                if (min_indent > 0 && line != "") {
                    # Remove the common indentation
                    line = substr(line, min_indent + 1)
                }
                print line
            }
        } else if (found_tab && !found_fence) {
            printf "ERROR: %s code fence #%d not found in tab: %s\n", wanted_language, target_index, wanted_title > "/dev/stderr"
            exit 1
        }
    }
}
' "$FILE"