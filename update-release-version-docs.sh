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
    echo "Missing NEW_VERSION value"
    exit 1
fi

MAJOR_VERSION=${MAJOR_VERSION:-}
if [[ -z "$MAJOR_VERSION" ]]; then
    MAJOR_VERSION=${NEW_VERSION%.*}
fi

# Add Docker after first line in the table
if grep -Fq "$NEW_VERSION" "$SCRIPT_DIR"/installation/docker.md; then
    echo "Found $NEW_VERSION already in the Docker docs so skipping update"
else
    sed_wrapper -i -e "/| -.*$/a | $NEW_VERSION | x86\_64, arm64v8, arm32v7, s390x | Release [v$NEW_VERSION](https://fluentbit.io/announcements/v$NEW_VERSION/) |" "$SCRIPT_DIR"/installation/docker.md
    sed_wrapper -i -e "/| -.*$/a | $NEW_VERSION-debug | x86\_64, arm64v8, arm32v7, s390x | Debug images |" "$SCRIPT_DIR"/installation/docker.md
fi

WIN_32_EXE_HASH=${WIN_32_EXE_HASH:?}
WIN_32_ZIP_HASH=${WIN_32_ZIP_HASH:?}
WIN_64_EXE_HASH=${WIN_64_EXE_HASH:?}
WIN_64_ZIP_HASH=${WIN_64_ZIP_HASH:?}
WIN_64_ARM_EXE_HASH=${WIN_64_ARM_EXE_HASH:-}
WIN_64_ARM_ZIP_HASH=${WIN_64_ARM_ZIP_HASH:-}

sed_wrapper -i -e "s/The latest stable version is .*$/The latest stable version is $NEW_VERSION./g" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "s/fluent-bit-[0-9\.]*-win/fluent-bit-$NEW_VERSION-win/g" "$SCRIPT_DIR"/installation/windows.md

sed_wrapper -i -e "s/win32.exe) | \[.*\]/win32.exe) | \[$WIN_32_EXE_HASH\]/g" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "s/win32.zip) | \[.*\]/win32.zip) | \[$WIN_32_ZIP_HASH\]/g" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "s/win64.exe) | \[.*\]/win64.exe) | \[$WIN_64_EXE_HASH\]/g" "$SCRIPT_DIR"/installation/windows.md
sed_wrapper -i -e "s/win64.zip) | \[.*\]/win64.zip) | \[$WIN_64_ZIP_HASH\]/g" "$SCRIPT_DIR"/installation/windows.md
if [[ -n "$WIN_64_ARM_EXE_HASH" ]]; then
  sed_wrapper -i -e "s/winarm64.exe) | \[.*\]/winarm64.exe) | \[$WIN_64_ARM_EXE_HASH\]/g" "$SCRIPT_DIR"/installation/windows.md
fi

if [[ -n "$WIN_64_ARM_ZIP_HASH" ]]; then
  sed_wrapper -i -e "s/winarm64.zip) | \[.*\]/winarm64.zip) | \[$WIN_64_ARM_ZIP_HASH\]/g" "$SCRIPT_DIR"/installation/windows.md
fi
