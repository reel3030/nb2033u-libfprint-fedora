# nb2033u-libfprint-fedora
Tentative libfprint RPM package builder for Fedora Workstation and Fedora Atomic Desktop.

**C A U T I O N**: The script in this project installs software that is not officially managed by the fprintd project. Run the script at your own risk.

## Details
A patch for fprintd to support the fingerprint reader of the NB-2033-U was developed by Mr. Sebastian van de Meer.

[This patch has been sent to the fprintd project](https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/574), but the fprintd project releases updates only once or twice a year.

For people who want to use the fingerprint reader on a machine equipped with the NB-2033-U before official support is added to Fedora, I wrote this script to build an RPM package.

Note that the major part of this script was written and published by Mr. Sebastian van de Meer on [his blog](https://www.kernel-error.de/2026/03/17/next-biometrics-nb-2033-u-reverse-engineering-fingerabdruckleser-linux/).

## Supported OS and hardware
The following distributions and their variants are supported:

- Fedora Workstation and its variants
- Fedora Atomic Desktop

The PC with the NB-2033-U fingerprint reader is supported (Vendor ID: 298d, Product ID: 2033).

To check whether your system has the NB-2033-U, run the following command:

```sh
lsusb | grep "298d:2033"
```
If the NB-2033-U is used, it will appear in the output.

## Tested environment
Distributions:
- Fedora KDE 44
- Fedora Kinoite 44

Hardware:
- Fujitsu FMV Lifebook U9311

## Install
Download the `libfprint-1.94.100-1.99.nb2033u.fc44.x86_64.rpm` file from the Releases page. Then, run the following command:

```sh
if [ -f /run/ostree-booted ]; then
    echo "Environment: Fedora Atomic Desktop (rpm-ostree)"
    # Override libfprint with the local package.
    sudo rpm-ostree override replace ./libfprint-1.94.100-1.99.nb2033u.fc44.x86_64.rpm
else
    echo "Environment: Standard Fedora (Package-based / Workstation)"
    # Replace libfprint with the local package.
    sudo dnf upgrade ./libfprint-1.94.100-1.99.nb2033u.fc44.x86_64.rpm
fi
```

## Uninstall
To uninstall the artifacts of this project and use the official libfprint, run the following command:

```sh
if [ -f /run/ostree-booted ]; then
    echo "Environment: Fedora Atomic Desktop (rpm-ostree)"
    # Use the official libfprint package.
    sudo rpm-ostree override reset libfprint
    echo "!!! Reboot the system to apply the change. !!!"
else
    echo "Environment: Standard Fedora (Package-based / Workstation)"
    # Use the official libfprint package.
    sudo dnf distro-sync libfprint
fi
```
## Notice on the version number and the release number of the RPM package
The version number andd the release number of the RPM package are set to:
- Version: 1.94.100
- Release: 1.99.nb2033u

This configuration will override the official libfprint package (Version 94.100, Release 1).

And if the newer version of the official libfprint package is released, the RPM package of this project will be automatcially replaced with the official one.

This is intended. We are expecting the the next official release of libfprint to support the NB-2033-U.

## Self build
To build the RPM by yourself, run the following script:

```sh
./build.sh
```

The artifacts are placed under `rpmbuild/RPMS/x86_64/`.

## Enroll the fingerprint and verify
To test fingerprint enrollment and verification, run the following commands:

```sh
sudo systemctl restart fprintd
fprintd-enroll
fprintd-verify
```

After invoking the command, a text message asks you to put your finger on the reader.
Place the specified finger on the reader 5 times.

Then, another test message asks you to place the same finger again, and the system verifies it.

## Uninstall
To uninstall, run the following commands:

```sh
./uninstall.sh
```

## License
The script and text in this project are published under the [MIT LICENSE](LICENSE).

The generated RPMs are delivered under the [fprintd](https://fprint.freedesktop.org/) license.