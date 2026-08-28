#!/bin/sh

# Delete the copied library. 
if [ "$OS" = "fedora" ]; then
    echo  "Fedora detected."
    if [ -f /run/ostree-booted ]; then
        echo "Environment: Fedora Atomic Desktop (rpm-ostree)"
        # Use the libfprint package from the distributor
        sudo rpm-ostree override reset libfprint
        echo "!!! Reboot the system to apply change.!!!"
    else
        echo "Environment: Standard Fedora (Package-based / Workstation)"
        # Use the libfprint package from the distributor. 
        sudo dnf distoro-sync libfprint
    fi


else
    echo  "Ubuntu detected."
    # Get into the source directory.
    cd libfprint || exit 1

    # Uninstall and update the library configuration.
    sudo ninja -C builddir uninstall
    sudo ldconfig

    # Go back to the original directory.
    cd - || exit 1
fi

