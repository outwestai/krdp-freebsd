#!/bin/sh
# Install autostart entries so Plasma starts PipeWire and WirePlumber at login.
# KRdp on FreeBSD needs them; without them RDP clients only see a black screen.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
dest="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"

for bin in pipewire wireplumber; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "warning: '$bin' not found. Install it with: sudo pkg install $bin" >&2
    fi
done

mkdir -p "$dest"
for f in pipewire.desktop wireplumber.desktop; do
    if [ -e "$dest/$f" ] && ! cmp -s "$here/autostart/$f" "$dest/$f"; then
        cp "$dest/$f" "$dest/$f.bak"
        echo "backed up existing $dest/$f to $f.bak"
    fi
    cp "$here/autostart/$f" "$dest/$f"
    echo "installed $dest/$f"
done

echo
echo "Done. Log out and back in, or start them now with:"
echo "  pipewire & sleep 1; wireplumber &"
echo "  pkill krdpserver; krdpserver &"
