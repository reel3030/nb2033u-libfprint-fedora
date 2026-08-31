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


# Customize part. 
# Change it to false if you want to use the original source code from Fedora.
if  true ; then
    # If you want to use the source code from the development repo of Sebastian van de Meer, comment out the above line and uncomment the following line.
    echo "Using the source code from the development repo of Sebastian van de Meer."

    # Place the patch file in the SOURCES directory.
    cp "$BASEDIR"/nb2033u.patch "$BASEDIR"/rpmbuild/SOURCES/ || \
        { echo "Error: Failed to copy nb2033u.patch to ~/rpmbuild/SOURCES/." >&2; exit 1; }

    # Modify release number and patch. This will override the original version.
    sed -i -e "s/^Release.*$/Release:        1.99.nb2033u%{?dist}/" "$BASEDIR"/rpmbuild/SPECS/libfprint.spec || \
        { echo "Error: Failed to modify the Release field of spec file." >&2; exit 1; }
    sed -i '/^Source0:/a Patch0:         nb2033u.patch' "$BASEDIR"/rpmbuild/SPECS/libfprint.spec || \
        { echo "Error: Failed to modify the Patch field ofspec file." >&2; exit 1; }
fi

# Build
toolbox run -c ${CONTAINER} -- rpmbuild --define "_topdir $BASEDIR/rpmbuild" -bb "$BASEDIR"/rpmbuild/SPECS/libfprint.spec || \
    { echo "Error: toolbox run 'rpmbuild -bb libfprint.spec' failed." >&2; exit 1; }

# Removing the container is optional. change condition from `false` to `true` if you want to remove the container after the build.
if false; then 
    toolbox rm ${CONTAINER} -f || \
        { echo "Error: toolbox rm failed." >&2; exit 1; }
fi

# Back to the original directory.
cd "$BASEDIR" || exit 1

echo "Done."
echo "RPM is generated in rpmbuild/RPMS/x86_64/ ."
