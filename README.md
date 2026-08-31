# nb2033u-libfprint-fedora
Tentative libfprint RPM package for Fedora Workstation and Fedora Atomic Desktop.

**C A U T I O N**: This project provides packages that are not officially managed by the fprintd project. Use them at your own risk. The author is not responsible for any damage caused by these packages.

## Details
A patch to add support for the NB-2033-U fingerprint reader to fprintd was developed by Mr. Sebastian van de Meer.

[This patch has been submitted to the fprintd project](https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/574), but upstream updates are released only once or twice a year.

If you want to use the NB-2033-U fingerprint reader before official support is added to Fedora, this project provides the required RPM package.

## Supported OS and hardware
The following distributions and variants are supported:

- Fedora Workstation and its variants
- Fedora Atomic Desktop

The NB-2033-U fingerprint reader is supported on compatible systems (Vendor ID: 298d, Product ID: 2033).

To check whether your system has the NB-2033-U, run the following command:

```sh
lsusb | grep "298d:2033"
```
If the device is present, it will appear in the output.

## Tested environment
Distributions:
- Fedora KDE 44
- Fedora Kinoite 44

Hardware:
- Fujitsu FMV Lifebook U9311

## Install
Download the `libfprint-1.94.100-1.99.nb2033u.fc44.x86_64.rpm` package from the Release archive page, then run the following command:

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
This command works for both Fedora Workstation and Fedora Atomic Desktop.

## Uninstall
To uninstall the artifacts of this project and restore the official libfprint package, run the following command:

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
This command works for both Fedora Workstation and Fedora Atomic Desktop.

## Notice on the version and release numbers of the RPM package
The version and release numbers of the RPM package are set to:
- Version: 1.94.100
- Release: 1.99.nb2033u

This configuration overrides the official libfprint package (Version 94.100, Release 1).

If a newer version of the official libfprint package is released, this project package will be automatically replaced with the official package.

This is intentional. We expect the next official release of libfprint to support the NB-2033-U.

## Build the RPM
To build the RPM yourself, run the following script:

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

After the command starts, a prompt asks you to place your finger on the reader. Place the specified finger on the reader five times.

Then, another prompt asks you to place the same finger again, and the system verifies it.

## Uninstall
To uninstall, run the following commands:

```sh
./uninstall.sh
```

## License
The scripts and text in this project are published under the [MIT LICENSE](LICENSE).

The generated RPMs are distributed under the [fprintd](https://fprint.freedesktop.org/) license.