# Maintainer: Reel <reel@example.com>
pkgname=libfprint-nb2033u
_pkgname=libfprint
pkgver=1.94.8
pkgrel=1
pkgdesc="Library for fingerprint reader devices with NB2033U patch"
arch=('x86_64')
url="https://fprint.freedesktop.org/"
license=('LGPL-2.1-or-later')
depends=(
  'glib2'
  'libgudev'
  'libgusb'
  'pixman'
  'nss'
  'polkit'
  'systemd-libs'
)
makedepends=(
  'git'
  'meson'
  'ninja'
  'gobject-introspection'
  'gtk-doc'
  'systemd'
)
provides=('libfprint' 'libfprint-2.so')
conflicts=('libfprint')

source=(
  "git+https://gitlab.freedesktop.org/libfprint/libfprint.git#tag=v${pkgver}"
  "nb2033u.patch"
)
sha256sums=(
  'SKIP'
  'SKIP'
)

prepare() {
  cd "$_pkgname"
  patch -Np1 -i "$srcdir/nb2033u.patch"
}

build() {
  arch-meson "$_pkgname" build \
    -Ddoc=false \
    -Dgtk-examples=false
  meson compile -C build
}

package() {
  meson install -C build --destdir "$pkgdir"
}
