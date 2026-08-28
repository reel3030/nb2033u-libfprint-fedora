#!/bin/bash

# Check wether Ubuntu or fedora 
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot determine the operating system."
    exit 1
fi

# If OS is not fedora, exit
if [ "$OS" != "fedora" ]; then
    echo "OS must be Fedora workstation or Fedora Atomic Desktop"
    exit 1;
fi


echo "Fedora detected."
CONTAINER=nb2033u-libfprint-container
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
#tar -xf libfprint-*.tar.gz

# Clone the development repo of Sebastian van de Meer
git clone https://gitlab.freedesktop.org/Kernel-Error/libfprint.git || \
    { echo "Error: Failed to clone S.V.D.Meer repo." >&2; exit 1; }
cd libfprint || exit 1

# Checkout the newest commit at the point of 2026-7-31.
git checkout 344480a6d62a58f036680a81f5cf4f1e890afabb

cd "$BASEDIR"/rpmbuild/SPECS/ || \
    { echo "Error: Failed to move to '$BASEDIR/rpmbuild/SPECS/'" >&2; exit 1; }

# Modify release number. This will override the original version.
sed -i -e "s/^Release.*$/Release:        1.99.nb2033u%{?dist}/" libfprint.spec || \
    { echo "Error: Failed to modify the spec file." >&2; exit 1; }

# Build
toolbox run -c ${CONTAINER} -- rpmbuild --define "_topdir $BASEDIR/rpmbuild" -bb libfprint.spec || \
    { echo "Error: toolbox run 'rpmbuild -bb libfprint.spec' failed." >&2; exit 1; }



# Back to the original directory.
cd "$BASEDIR" || exit 1

echo "Done."
echo "RPM is generated in rpmbuild/RPMS/x86_64/ ."