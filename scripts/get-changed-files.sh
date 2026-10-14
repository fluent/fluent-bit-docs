#!/usr/bin/env bash
set -euo pipefail

# This script identifies Markdown files that have been changed.
# It can be used locally to find changes relative to a base branch,
# or in CI/CD workflows to validate only the files that changed in a PR.
#
# Usage:
#   ./scripts/get-changed-files.sh [base_ref] [head_ref]
#
# Parameters:
#   base_ref (optional): The base commit/branch to compare against (default: origin/master)
#   head_ref (optional): The head commit/branch to compare to (default: HEAD)
#
# Examples:
#   # Compare current branch against origin/master
#   ./scripts/get-changed-files.sh
#
#   # Compare specific commits
#   ./scripts/get-changed-files.sh abc123def456...xyz789
#
#   # Compare origin/master to origin/feature-branch
#   ./scripts/get-changed-files.sh origin/master origin/feature-branch
#
# Output:
#   Lists changed Markdown files (one per line)
#   Returns 0 if successful (even if no files changed)

# Default values
BASE_REF="${1:-origin/master}"
HEAD_REF="${2:-HEAD}"

# If a single argument contains three dots, it's a commit range (e.g., abc123...xyz789)
# If two arguments are provided, they're treated as base and head
if [[ $# -eq 1 && "$BASE_REF" == *"..."* ]]; then
    # Using commit range format
    COMMIT_RANGE="$BASE_REF"
else
    # Using base and head refs
    COMMIT_RANGE="${BASE_REF}...${HEAD_REF}"
fi

echo "Finding changed Markdown files between $COMMIT_RANGE..." >&2

# Validate that the refs exist before attempting git diff
# This ensures we surface errors early if refs are invalid
for ref in "${BASE_REF}" "${HEAD_REF}"; do
    if ! git rev-parse --verify "$ref" &>/dev/null; then
        echo "ERROR: Git reference '$ref' does not exist or is invalid" >&2
        exit 1
    fi
done

# Find files that have been Added, Modified, Copied, or Renamed (AMCR)
# Filter for .md files
# We must not suppress stderr here, as real errors should be visible
if ! changed_files=$(git diff --name-only --diff-filter=AMCR "$COMMIT_RANGE" -- '*.md'); then
    echo "ERROR: Failed to diff between $COMMIT_RANGE" >&2
    exit 1
fi

if [ -z "$changed_files" ]; then
    echo "No Markdown files changed." >&2
    exit 0
fi

# Output the changed files (one per line)
echo "$changed_files"
