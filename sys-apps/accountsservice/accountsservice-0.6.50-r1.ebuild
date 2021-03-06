# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

inherit gnome2 systemd

DESCRIPTION="D-Bus interfaces for querying and manipulating user account information"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/AccountsService/"
SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 arm arm64 ppc ppc64 x86"

IUSE="doc consolekit elogind +introspection selinux systemd"
REQUIRED_USE="^^ ( consolekit elogind systemd )"

CDEPEND="
	>=dev-libs/glib-2.44:2
	sys-auth/polkit
	consolekit? ( sys-auth/consolekit )
	elogind? ( >=sys-auth/elogind-229.4 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.12:= )
	systemd? ( >=sys-apps/systemd-186:0= )
"
DEPEND="${CDEPEND}
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.1.2
		app-text/xmlto )
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-accountsd )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.6.35-gentoo-system-users.patch

	# lib: don't set loaded state until seat is fetched (from 'master')
	"${FILESDIR}"/${P}-loaded-state.patch
	"${FILESDIR}"/musl-fgetspent_r.patch
)

src_prepare() {
	default
	sed -i configure -e "s;utx\.log;wtmp;g"
	export ac_cv_file__var_log_utx_log=yes
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--disable-more-warnings \
		--localstatedir="${EPREFIX}"/var \
		--enable-admin-group="wheel" \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		$(use_enable doc docbook-docs) \
		$(use_enable elogind) \
		$(use_enable introspection) \
		$(use_enable systemd)
}
