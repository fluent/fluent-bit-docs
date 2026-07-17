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
# Usage: ./extract-config.sh <file> <tab title> <fence language>
# e.g.
#   ./extract-config.sh README.md "fluent-bit.yaml" yaml
#

FILE=${1:?"Usage: $0 FILE TAB_TITLE LANGUAGE"}
TITLE=${2:?"Usage: $0 FILE TAB_TITLE LANGUAGE"}
LANGUAGE=${3:?"Usage: $0 FILE TAB_TITLE LANGUAGE"}

# We only use AWK to keep it simple and portable. 
# We could use a more powerful parser, but that would require additional dependencies.
# For macOS ensure AWK is GNU awk (gawk) and not the default BSD awk. You can install gawk via Homebrew: `brew install gawk`.

awk -v wanted_title="$TITLE" -v wanted_language="$LANGUAGE" '
BEGIN {
    tab_marker = "{% tab title=\"" wanted_title "\" %}"
    fence_marker = "```" wanted_language
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
            reached_endtab = 1
            exit
        }

        if (marker == fence_marker) {
            found_fence = 1
            in_fence = 1
        }

        next
    }

    if (marker == "```") {
        closed_fence = 1
        exit
    }

    print line
}

END {
    if (found_tab) {
        if (!found_fence) {
            printf "ERROR: %s code fence not found in tab: %s\n", wanted_language, wanted_title > "/dev/stderr"
            exit 1
        } else if (!closed_fence) {
            printf "ERROR: code fence was not closed in tab: %s\n", wanted_title > "/dev/stderr"
            exit 1
        }
    }
}
' "$FILE"