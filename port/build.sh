#!/bin/sh
# Build plasma6-krdp from this repo's port directory as a normal user.
# Requires a ports tree in /usr/ports (only Mk/ and the framework are used).
# Output: ./pkgs/All/plasma6-krdp-*.pkg
here="$(cd "$(dirname "$0")" && pwd)"
port="$here/plasma6-krdp"

[ -f /usr/ports/Mk/bsd.port.mk ] || {
	echo "No ports tree in /usr/ports. Get one with:" >&2
	echo "  sudo git clone --depth 1 https://git.FreeBSD.org/ports.git /usr/ports" >&2
	exit 1
}

mk() {
	make -C "$port" PORTSDIR=/usr/ports \
	  WRKDIRPREFIX="$here/work" \
	  DISTDIR="$here/distfiles" \
	  PACKAGES="$here/pkgs" \
	  DESCR="$port/pkg-descr" \
	  BATCH=yes "$@"
}

# Dependencies must be installed from packages first; building them from
# ports as a normal user would need root to install.
missing=$(mk missing)
if [ -n "$missing" ]; then
	echo "Missing dependencies. Install them first with:" >&2
	printf '  sudo pkg install' >&2
	for o in $missing; do
		printf ' %s' "$(pkg rquery '%n' "$o" 2>/dev/null || echo "$o")" >&2
	done
	echo >&2
	exit 1
fi

mkdir -p "$here/pkgs/All"
mk "${@:-package}"
