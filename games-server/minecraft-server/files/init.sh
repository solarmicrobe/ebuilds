#!/sbin/runscript
# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

extra_started_commands="console"

MULTIVERSE="${SVCNAME#*.}"
[[ "${SVCNAME}" == "${MULTIVERSE}" ]] && MULTIVERSE="main"

LOCK="/var/lib/@SERVER_SUBTYPE@/${MULTIVERSE}/server.log.lck"
PID="/var/run/@SERVER_SUBTYPE@/${MULTIVERSE}.pid"
SOCKET="/tmp/tmux-@SERVER_SUBTYPE@-${MULTIVERSE}"

depend() {
	need net
}

start() {
	local SERVER="${SVCNAME%%.*}"
	local EXE="/usr/games/bin/${SERVER}"

	ebegin "Starting @SERVER_SUBTYPE@ multiverse \"${MULTIVERSE}\" using ${SERVER}"

	if [[ ! -x "${EXE}" ]]; then
		eend 1 "${SERVER} was not found. Did you install it?"
		return 1
	fi

	if fuser -s "${LOCK}" &> /dev/null; then
		eend 1 "This multiverse appears to be in use, maybe by another server?"
		return 1
	fi

	local CMD="umask 027 && '${EXE}' '${MULTIVERSE}'"
	su -c "/usr/bin/tmux -S '${SOCKET}' new-session -n '@SERVER_SUBTYPE@-${MULTIVERSE}' -d \"${CMD}\"" "@GAMES_USER_DED@"

	if ewaitfile 15 "${LOCK}" && local FUSER=$(fuser "${LOCK}" 2> /dev/null); then
		echo "${FUSER}" > "${PID}"
		eend 0
	else
		eend 1
	fi
}

stop() {
	ebegin "Stopping Minecraft multiverse \"${MULTIVERSE}\""

	# tmux will automatically terminate when the server does.
	start-stop-daemon -K -p "${PID}"
	rm -f "${SOCKET}"

	eend $?
}

console() {
	exec /usr/bin/tmux -S "${SOCKET}" attach-session
}
