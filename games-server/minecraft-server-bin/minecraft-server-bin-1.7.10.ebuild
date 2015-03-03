# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit games java-pkg-2 versionator

MY_MINOR_PV=$(get_version_component_range 1-2 ${PV})
MY_MAJOR_PV=$(get_version_component_range 1 ${PV})
MY_PN=${PN/-bin/}

DESCRIPTION="Official dedicated server for Minecraft"
HOMEPAGE="http://www.minecraft.net"
SRC_URI="https://s3.amazonaws.com/Minecraft.Download/versions/${PV}/minecraft_server.${PV}.jar -> ${MY_PN}.jar"
LICENSE="Minecraft-EULA"
SLOT="${MY_MINOR_PV}.9"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"
RESTRICT="mirror"
GAMES_CHECK_LICENSE="yes"

DEPEND=""
RDEPEND=">=virtual/jre-1.6
	games-server/minecraft-common"

S="${WORKDIR}"

MY_PN_DIR="${GAMES_PREFIX_OPT}/${MY_PN}" 		# ex. /opt/minecraft-server
MY_MAJOR_DIR="${MY_PN_DIR}/${MY_MAJOR_PV}"  # ex. /opt/minecraft-server/1
MY_MINOR_DIR="${MY_PN_DIR}/${MY_MINOR_PV}"	# ex. /opt/minecraft-server/1/1.7
MY_SLOT_DIR="${MY_MINOR_DIR}/${STOT}" 			# ex. /opt/minecraft-server/1/1.7/1.7.9
MY_DEST="${MY_SLOT_DIR}/${PV}" 							# ex. /opt/minecraft-server/1/1.7/1.7.9/1.7.10


pkg_setup() {
	java-pkg-2_pkg_setup
	games_pkg_setup
}

java_prepare() {
	local SERVER_SUBTYPE=${PN}

	cp "${FILESDIR}"/{directory,init}.sh . || die

	for i in {directory,init}.sh; do
		for j in {GAMES_USER_DED,SERVER_SUBTYPE}; do
			eval "sed -i \"s/@${j}@/\$"${j}"}/g\" $i" || die
		done
	done

	# sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" directory.sh || die
	# sed -i "s/@SERVER_SUBTYPE@/${PN}/g" directory.sh || die
	# sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" init.sh || die
	# sed -i "s/@SERVER_SUBTYPE@/${PN}/g" init.sh || die
	echo "eula=true" > eula.txt
}

src_install() {
	local ARGS

	java-pkg_jarinto "${MY_DEST}"/bin
	java-pkg_dojar ${MY_PN}.jar

  # ex. sym in /opt/minecraft-server/1.7/1.7.9/bin from /opt/minecraft-server/1.7/1.7.9/1.7.10/bin
  # This will allow non-breaking upgrades to happen automatically in a slot
	dosym "${MY_SLOT_DIR}/bin/${MY_PN}.jar" "${MY_DEST}/bin/${MY_PN}.jar"

	# ex. sym in /opt/minecraft-server/1.7/bin from /opt/minecraft-server/1.7/1.7.9/bin
	# This is only for initial setup of a minor version
	if [[ -a "${MY_MINOR_DIR}/bin/${MY_PN}.jar" ]]; then
		dosym "${MY_MINOR_DIR}/bin/${MY_PN}.jar" "${MY_SLOT_DIR}/bin/${MY_PN}.jar"
	fi

	# ex. sym in /opt/minecraft-server/bin from /opt/minecraft-server/1.7/bin
	# This is only for initial setup of a major version
	if [[ -a "${MY_MAJOR_DIR}/bin/${MY_PN}.jar" ]]; then
		dosym "${MY_MAJOR_DIR}/bin/${MY_PN}.jar" "${MY_MINOR_DIR}/bin/${MY_PN}.jar"
	fi

	# ex. sym in /opt/minecraft-server/bin from /opt/minecraft-server/1.7/bin
	# This is only for initial setup
	if [[ -a "${MY_PN_DIR}/bin/${MY_PN}.jar" ]]; then
		dosym "${MY_PN_DIR}/bin/${MY_PN}.jar" "${MY_MAJOR_DIR}/bin/${MY_PN}.jar"
	fi

	use ipv6 || ARGS="-Djava.net.preferIPv4Stack=true"

	newinitd init.sh ${MY_PN}-${SLOT} || die

	java-pkg_dolauncher "${MY_PN}" -into "${GAMES_PREFIX}" -pre directory.sh \
		--java_args "-Xmx1024M -Xms512M ${ARGS}" --pkg_args "nogui" \
		--main net.minecraft.server.MinecraftServer
}

pkg_postinst() {
	einfo "You may run ${MY_PN} as a regular user or start a system-wide"
	einfo "instance using /etc/init.d/${MY_PN}. The multiverse files are"
	einfo "stored in ~/.minecraft/servers or /var/lib/minecraft respectively."
	echo
	einfo "The console for system-wide instances can be accessed by any user in"
	einfo "the ${GAMES_GROUP} group using the minecraft-server-console command. This"
	einfo "starts a client instance of tmux. The most important key-binding to"
	einfo "remember is Ctrl-b d, which will detach the console and return you to"
	einfo "your previous screen without stopping the server."
	echo
	einfo "This package allows you to start multiple Minecraft server instances."
	einfo "You can do this by adding a multiverse name after ${MY_PN} or by"
	einfo "creating a symlink such as /etc/init.d/${MY_PN}.foo. You would"
	einfo "then access the console with \"minecraft-server-console foo\". The"
	einfo "default multiverse name is \"main\"."
	echo

	games_pkg_postinst
}
