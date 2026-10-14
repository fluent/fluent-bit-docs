#!/usr/bin/env bash
set -euo pipefail

# This script validates configuration examples in changed Markdown files.
# It can be used locally to validate changes before pushing,
# or in CI/CD workflows to validate only the files that changed in a PR.
#
# Usage:
#   ./scripts/validate-changed-files.sh [base_ref] [head_ref]
#
# Parameters:
#   base_ref (optional): The base commit/branch to compare against (default: origin/master)
#   head_ref (optional): The head commit/branch to compare to (default: HEAD)
#
# Examples:
#   # Validate changes in current branch against origin/master
#   ./scripts/validate-changed-files.sh
#
#   # Validate changes in a specific branch
#   ./scripts/validate-changed-files.sh origin/master origin/feature-branch
#

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

# Get the list of changed files
BASE_REF="${1:-origin/master}"
HEAD_REF="${2:-HEAD}"

echo "Getting changed Markdown files..."
# Do NOT suppress errors with || true - we need to know if get-changed-files.sh fails
changed_files=$("$SCRIPT_DIR/get-changed-files.sh" "$BASE_REF" "$HEAD_REF")

if [ -z "$changed_files" ]; then
    echo "No Markdown files changed. Skipping validation."
    exit 0
fi

echo "Files to validate:"
echo "${changed_files/^/  /}"
echo ""

error_count=0

# Validate each changed file
while IFS= read -r file; do
    if [ -z "$file" ]; then
        continue
    fi
    
    echo "Validating: $file"
    if ! "$SCRIPT_DIR/test-config.sh" "$file"; then
        error_count=$((error_count + 1))
    fi
done <<< "$changed_files"

echo ""
if [ $error_count -ne 0 ]; then
    echo "ERROR: Validation failed for $error_count file(s)."
    exit 1
fi

echo "All validations passed!"
