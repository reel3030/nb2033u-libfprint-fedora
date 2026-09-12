# Maintainer: Reel <reel@example.com>
pkgname=libfprint-nb2033u
_pkgname=libfprint
pkgver=1.94.100
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

# 1.94.100 タグの libfprint を取得
source=(
  "git+https://gitlab.freedesktop.org/Kernel-Error/libfprint.git#branch=nb2033-support"
)
sha256sums=('SKIP')

validpgpkeys=(
  40F65066AD7C16DB
)

prepare() {
  cd "$_pkgname"
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
