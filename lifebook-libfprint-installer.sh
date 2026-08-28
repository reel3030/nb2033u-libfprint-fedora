#!/bin/bash

# Check wether Ubuntu or fedora 
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot determine the operating system."
    exit 1
fi



# Install fprintd and libfprint
if [ "$OS" = "ubuntu" ]; then
    echo "Ubuntu detected."
    # Build dependencies.
    sudo apt update
    sudo apt install -y build-essential meson \
    ninja-build pkg-config git \
    libglib2.0-dev libgusb-dev libnss3-dev libgudev-1.0-dev \
    libpixman-1-dev libgirepository1.0-dev fprintd \
    cmake libssl-dev systemd-dev git

    # Obtain the source code of libfprint.so with NB-2033-U patch.
    git clone -b nb2033-support https://gitlab.freedesktop.org/Kernel-Error/libfprint.git
    cd libfprint || exit 1

    # Configure the build the libfprint.so
    meson setup builddir --prefix=/usr/local -Ddoc=false -Dgtk-examples=false

    # Build fprintd
    ninja -C builddir

    # Install the build artifact.
    sudo ninja -C builddir install

    # Update the library link
    sudo ldconfig

elif [ "$OS" = "fedora" ]; then
    echo "Fedora detected."
    CONTAINER=lifebook-work-container
    BASEDIR=$(pwd)
    LIBFPRINT=libfprint-1.94.100


    # Build is done inside container.
    toolbox create -c ${CONTAINER} -y
    toolbox run -c ${CONTAINER} -- sudo dnf install -y \
        fedora-packager rpmdevtools dnf-plugins-core || \
        { echo "Error: toolbox run 'sudo dnf install -y' failed." >&2; exit 1; }
    # Create build directory
    toolbox run -c ${CONTAINER} -- rpmdev-setuptree ||\
        { echo "Error: toolbox run 'rpmdev-setuptree' failed." >&2; exit 1; }
    # Download libfprint source RPM
    toolbox run -c ${CONTAINER} -- dnf download --source $LIBFPRINT || \
        { echo "Error: toolbox run 'dnf download --source libfprint' failed." >&2; exit 1; }
    # Autoinstall dependency
    toolbox run -c ${CONTAINER} -- sudo dnf builddep -y libfprint*.src.rpm || \
        { echo "Error: toolbox run 'sudo dnf builddep -y libfprint*.src.rpm' failed." >&2; exit 1; }
    # Expand SPRM ( SPECS and SOURCES under $(pwd)/rpmbuild/)
    toolbox run -c ${CONTAINER} -- rpm -i --define "_topdir $BASEDIR/rpmbuild" libfprint*.src.rpm || \
        { echo "Error: toolbox run 'rpm -i libfprint*.src.rpm' failed." >&2; exit 1; }
    # Move to work dir
    cd "$BASEDIR"/rpmbuild/SOURCES/ || \
        { echo "Error: Failed to move to '$BASEDIR/rpmbuild/SOURCES/'" >&2; exit 1; }
    # Expand source code
    tar -xf libfprint-*.tar.gz
    cd libfprint-*/ || exit 1

    # Modify source code here

    # RPM spec files
    # 1. リリース番号に独自ビルド識別子（.custom 等）を追加
    # Release:        1.custom%{?dist}

    # 2. Patch定義を追加（他のPatch項目の後などに追加）
    # Patch999:       my-custom-fix.patch

    # Build
    cd "$BASEDIR"/rpmbuild/SPECS/ || \
        { echo "Error: Failed to move to '$BASEDIR/rpmbuild/SPECS/'" >&2; exit 1; }
    toolbox run -c ${CONTAINER} -- rpmbuild --define "_topdir $BASEDIR/rpmbuild" -bb libfprint.spec || \
        { echo "Error: toolbox run 'rpmbuild -bb libfprint.spec' failed." >&2; exit 1; }

else
    echo "Unsupported operating system: $OS"
    exit 1
fi


# Back to the original directory.
cd - || exit 1

