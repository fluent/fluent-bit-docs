#!/bin/bash
set -eux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function sed_wrapper() {
  if sed --version >/dev/null 2>&1; then
    $(which sed) "$@"
  else
    if command -v gsed >/dev/null 2>&1 ; then
      # homebrew gnu-sed is required on MacOS
      gsed "$@"
    else
      echo "ERROR: No valid GNU compatible 'sed' found, if on macOS please run 'brew install gnu-sed'" >&2
      exit 1
    fi
  fi
}

NEW_VERSION=${NEW_VERSION:?}
if [[ -z "$NEW_VERSION" ]]; then
    echo "Missing VERSION value"
    exit 1
fi

MAJOR_VERSION=${MAJOR_VERSION:-}
if [[ -z "$MAJOR_VERSION" ]]; then
    MAJOR_VERSION=${VERSION%.*}
fi

# Add Docker after first line in the table
sed_wrapper -i -e "/| -.*$/a | $NEW_VERSION-debug | x86\_64, arm64v8, arm32v7 | Release [v$NEW_VERSION](https://fluentbit.io/announcements/v$NEW_VERSION/) |" "$SCRIPT_DIR"/installation/docker.md
sed_wrapper -i -e "/| -.*$/a | $NEW_VERSION | x86\_64, arm64v8, arm32v7 | Debug images |" "$SCRIPT_DIR"/installation/docker.md

WIN_32_EXE_HASH=${WIN_32_EXE_HASH:?}
WIN_32_ZIP_HASH=${WIN_32_ZIP_HASH:?}
WIN_64_EXE_HASH=${WIN_64_EXE_HASH:?}
WIN_64_ZIP_HASH=${WIN_64_ZIP_HASH:?}

sed_wrapper -i -e "/The latest stable version is [0-9]+\.[0-9]+\.[0-9]+/The latest stable version is $NEW_VERSION/" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "/fluent-bit-[0-9]+\.[0-9]+\.[0-9]+-win/fluent-bit-$NEW_VERSION-win/" "$SCRIPT_DIR"/installation/windows.md

sed_wrapper -i -e "/win32.exe) | \[[.*]\(https\]/win32.exe) | \[$WIN_32_EXE_HASH\]\(https" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "/win32.zip) | \[[.*]\(https\]/win32.zip) | \[$WIN_32_ZIP_HASH\]\(https" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "/win64.exe) | \[[.*]\(https\]/win64.exe) | \[$WIN_64_EXE_HASH\]\(https" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "/win64.zip) | \[[.*]\(https\]/win64.zip) | \[$WIN_64_ZIP_HASH\]\(https" "$SCRIPT_DIR"/installation/windows.md
