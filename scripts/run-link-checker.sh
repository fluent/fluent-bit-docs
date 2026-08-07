#!/bin/bash
set -euo pipefail

# This script is used to run the Lychee link checker in the same way that CI does in the GitHub Actions workflow.

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
REPO_DIR=${REPO_DIR:-$SCRIPT_DIR/..}

CONTAINER_IMAGE=${CONTAINER_IMAGE:-"ghcr.io/lycheeverse/lychee:latest"}
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}

# Always pull the latest Lychee image to ensure we are validating against the most recent version.
if ! $CONTAINER_RUNTIME pull "$CONTAINER_IMAGE" &>/dev/null; then
    echo "ERROR: Failed to pull container image $CONTAINER_IMAGE" >&2
    exit 1
fi

# Matches the values in the GitHub Actions workflow for consistency.
LYCHEE_ARGS=${LYCHEE_ARGS:-"--accept '100..=103,200..=299,401,403,429,999' --verbose --no-progress ."}

# Run the Lychee link checker in a container with the same arguments as the GitHub Actions workflow.
# Note we do want arguments to be expanded here, so we don't quote $LYCHEE_ARGS.
# shellcheck disable=SC2086
"$CONTAINER_RUNTIME" run --init -it -v "$REPO_DIR":/input:ro -e GITHUB_TOKEN="${GITHUB_TOKEN:-}" "$CONTAINER_IMAGE" $LYCHEE_ARGS
