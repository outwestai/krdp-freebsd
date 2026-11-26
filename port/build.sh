#!/bin/sh
# Build plasma6-krdp from this repo's port directory as a normal user.
# Requires a ports tree in /usr/ports (for Mk/ and distfiles).
# Output: ./work (build dir) and ./pkgs/All/plasma6-krdp-*.pkg
here="$(cd "$(dirname "$0")" && pwd)"
cd "$here/plasma6-krdp" || exit 1
exec make PORTSDIR=/usr/ports \
  WRKDIRPREFIX="$here/work" \
  DISTDIR=/usr/ports/distfiles \
  PACKAGES="$here/pkgs" \
  BATCH=yes "${@:-package}"
