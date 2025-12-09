# Maintainer: quinsaiz <edgood228@gmail.com>
pkgname=ppd-cpu-boost
pkgver=1.0.1
pkgrel=1
pkgdesc="Systemd service to synchronize CPU Turbo Boost state with power-profiles-daemon."
arch=('any')
url="https://github.com/quinsaiz/ppd-cpu-boost"
license=('GPL3')
depends=('python' 'python-gobject' 'power-profiles-daemon')

source=("${pkgname}-${pkgver}.tar.gz::https://github.com/quinsaiz/${pkgname}/archive/v${pkgver}.tar.gz"
        
        "${pkgname}.install::https://raw.githubusercontent.com/quinsaiz/${pkgname}/v${pkgver}/${pkgname}.install") 

install=${pkgname}.install

sha256sums=('d3b402d08b25b92a7ce750b5739ef52beef962ffd76d22cffd383bbc9356646a'
            '2e79e0d03937ca2b8db3b1c1b37e52ad3e5c65522919b9204486425d789946d7')

prepare() {
    cd "${srcdir}/${pkgname}-${pkgver}"
}

package() {
    install -d -m 755 "${pkgdir}/usr/bin"
    install -d -m 755 "${pkgdir}/usr/lib/systemd/system"

    install -m 755 "${srcdir}/${pkgname}-${pkgver}/ppd-cpu-boost" "${pkgdir}/usr/bin/"
    install -m 644 "${srcdir}/${pkgname}-${pkgver}/ppd-cpu-boost.service" "${pkgdir}/usr/lib/systemd/system/"
    install -D -m 644 "${srcdir}/${pkgname}-${pkgver}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
