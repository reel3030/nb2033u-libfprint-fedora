# nb2033u.patch

This documents explain the `nb2033u.patch` file.

Note that this patch is sticky to the libfprint version 1.94.100. If you want to use this patch on other versions, please check the source code and modify the patch file accordingly.

# Purpose of nb2033u.patch

This patch file is applied to the the source code of the libfprint.rpm. With this patch applied, the source code have support the NB-2033-U fingerprint reader.

This patch method is official workflow of the RPM building. To make it happen, the `build.sh` script will do: 
 
 1. copy nb2033u.patch to the `rpmbuild/SOURCES` directory.
 2. Add the line `Patch0: nb2033u.patch` to the `libfprint.spec` file.

# How nb2033u.patch was generated

```sh
# At first, define a function to generate the patch file.
build_nb2033_patch() {
    # Go to the work directory.
    cd rpmbuild/SOURCES || return 1

    # unzip the official source tree. 
    tar -xzf libfprint-*.tar.gz || \
        { echo "Error: Failed to extract libfprint-*.tar.gz." >&2; return 1; }

    # Clone the development repo of Sebastian van de Meer
    git clone https://gitlab.freedesktop.org/Kernel-Error/libfprint.git || \
        { echo "Error: Failed to clone S.V.D.Meer repo." >&2; return 1; }
    cd libfprint || return 1

    # Checkout the newest commit at the point of 2026-7-31.
    # This the support for the libfprint version 1.94.100.
    git checkout 344480a6d62a58f036680a81f5cf4f1e890afabb || \
        { echo "Error: Failed to checkout nb2033-support branch." >&2; return 1; }

    # Find `'nb2033': {},` from tests/meson.build, then, remove that line. 
    # This is needed to avoid the build error. 
    sed -i "/'nb2033': {},/d" tests/meson.build || \
        { echo "Error: Failed to remove the line of nb2033 from tests/meson.build." >&2; return 1; }


    cd .. || return 1

    # Make patch
    diff -uNr -x "build" -x "*.o" -x ".git" -uNr libfprint-v1.94.100 libfprint > nb2033u.patch
    
}

# Here we go.
build_nb2033_patch

```
