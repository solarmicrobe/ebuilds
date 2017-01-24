#!/sbin/runscript
# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

extra_started_commands="console"

# Parse versions
OIFS=$IFS
IFS='-'
arr=($SVCNAME)
IFS='.'
arr=(${arr[2]})
MULTIVERSE="${arr[3]}" # ex test
MAJOR=${arr[0]:-1}
MINOR=${arr[1]}
PATCH=${arr[2]}
IFS=$OIFS

[[ -z "${MULTIVERSE}" ]] && MULTIVERSE="main"
SERVER="${SVCNAME/-bin*/}" # ex. minecraft-server

# Gather exe path
EXE="@GAMES_PREFIX@"
if [[ -z "${MAJOR}" ]]; then
	EXE="${EXE}/${MAJOR}"
fi

if [[ -z "${MINOR}" ]]; then
	EXE="${EXE}/${MINOR}"
fi

if [[ -z "${PATCH}" ]]; then
	# FIXME
fi

LOCK="/var/lib/@SERVER_SUBTYPE@/${MULTIVERSE}/server.log.lck"
PID="/var/run/@SERVER_SUBTYPE@/${MULTIVERSE}.pid"
SOCKET="/tmp/tmux-@SERVER_SUBTYPE@-${MULTIVERSE}"

depend() {
	need net
}

start() {
	ebegin "Starting ${SVCNAME%-*.*.*} multiverse \"${MULTIVERSE}\" using ${SERVER}"

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

function join { local IFS="$1"; shift; echo "$*"; }


