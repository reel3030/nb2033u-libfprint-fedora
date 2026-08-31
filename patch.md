# nb2033u.patch

This document explains the `nb2033u.patch` file used in this project.

The patch is specific to libfprint version 1.94.100. If you want to reuse it for another version, check the source tree and adjust the patch accordingly.

## Purpose

This patch is applied to the libfprint source tree before building the RPM. It adds support for the NB-2033-U fingerprint reader.

The build flow follows the standard RPM packaging approach:

1. Copy `nb2033u.patch` into the `rpmbuild/SOURCES` directory.
2. Add `Patch0: nb2033u.patch` to `libfprint.spec`.

## How the patch was generated

The script below generates `nb2033u.patch` from the repository root.

Before running it, execute `./build.sh` to prepare the `rpmbuild/SOURCES` directory.

The procedure is as follows:

- Clone the development repository of Sebastian van de Meer.
- Check out the newest commit as of 2026-07-31, which adds support for libfprint 1.94.100.
- Remove `'nb2033': {},` from `tests/meson.build` to avoid a build error.
- Generate the patch with `diff` and save it as `nb2033u.patch` in `rpmbuild/SOURCES`.

```sh
# Define a function to generate the patch.
build_nb2033_patch() {
    cd rpmbuild/SOURCES || return 1

    # Extract the official source tree.
    tar -xzf libfprint-*.tar.gz || \
        { echo "Error: Failed to extract libfprint-*.tar.gz." >&2; return 1; }

    # Clone the development repository of Sebastian van de Meer.
    git clone https://gitlab.freedesktop.org/Kernel-Error/libfprint.git || \
        { echo "Error: Failed to clone the S.V.D.Meer repository." >&2; return 1; }
    cd libfprint || return 1

    # Check out the newest commit as of 2026-07-31.
    # This adds support for libfprint version 1.94.100.
    git checkout 344480a6d62a58f036680a81f5cf4f1e890afabb || \
        { echo "Error: Failed to checkout the nb2033-support commit." >&2; return 1; }

    # Remove the NB-2033-U entry from tests/meson.build.
    # This avoids a build error.
    sed -i "/'nb2033': {},/d" tests/meson.build || \
        { echo "Error: Failed to remove the nb2033 entry from tests/meson.build." >&2; return 1; }

    cd .. || return 1

    # Create the patch.
    diff -uNr -x "build" -x "*.o" -x ".git" -uNr libfprint-v1.94.100 libfprint > nb2033u.patch
}

# Run it.
build_nb2033_patch
```
