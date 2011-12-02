# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/remmina/remmina-9999.ebuild,v 1.1 2011/06/24 14:41:36 hwoarang Exp $

EAPI=2
EGIT_REPO_URI="https://github.com/UberPinguin/Remmina.git"
EGIT_PROJECT="remmina"
EGIT_SOURCEDIR="${WORKDIR}"

inherit cmake-utils git-2 eutils gnome2-utils

DESCRIPTION="A GTK+ RDP, VNC, XDMCP and SSH client"
HOMEPAGE="http://remmina.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="avahi crypt debug gnome nls nx rdesktop ssh telepathy unique vnc vte xdmcp"

RDEPEND="dev-util/cmake
	x11-libs/gtk+:3
	avahi? ( net-dns/avahi )
	crypt? ( dev-libs/libgcrypt )
	gnome? ( gnome-base/gnome-keyring )
	nls? ( virtual/libintl )
	nx? ( net-misc/nx )
	rdesktop? ( =net-misc/freerdp-9999.1 )
	ssh? ( net-libs/libssh[sftp] )
	telepathy? ( >=net-libs/telepathy-glib-0.9.0 )
	unique? ( dev-libs/libunique:1 )
	vnc? ( net-libs/libvncserver[jpeg,zlib] >=net-libs/gnutls-2.4.0 )
	vte? ( x11-libs/vte:0 )
	xdmcp? ( x11-libs/libXdmcp x11-base/xorg-server[kdrive] )"

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	!net-misc/remmina-plugins"

S="${WORKDIR}"

CMAKE_IN_SOURCE_BUILD=1

src_configure() {
	if use ssh && ! use vte; then
		ewarn "Enabling ssh without vte only provides sftp support."
	fi
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use avahi WITH_AVAHI)
		$(cmake-utils_use crypt WITH_GCRYPT)
		$(cmake-utils_use vte WITH_VTE)
		$(cmake-utils_use ssh WITH_LIBSSH)
		$(cmake-utils_use gnome WITH_GNOMEKEYRING)
		$(cmake-utils_use nx WITH_XKBFILE)
		$(cmake-utils_use rdesktop WITH_FREERDP)
		$(cmake-utils_use vnc WITH_ZLIB)
		$(cmake-utils_use xdmcp WITH_XDMCP)
		$(cmake-utils_use telepathy WITH_TELEPATHY)
		-DWITH_APPINDICATOR=OFF"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_compile || die "cmake compile failed"
	cmake-utils_src_install || die "cmake install failed"
	dodoc remmina/{AUTHORS,ChangeLog,README} || die "dodoc failed"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "You need to install net-misc/remmina-plugins which"
	elog "provide all the necessary network protocols required by ${PN}"
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
