# KRdp on FreeBSD: fixing the black screen

[KRdp](https://invent.kde.org/plasma/krdp) is KDE Plasma's built-in RDP server.
On FreeBSD, a common problem is that RDP clients **connect and log in fine, but
only show a black screen**.

This repo documents the cause and the fix, and includes ready-to-use autostart
files.

## Tested on

| Component            | Version          |
|----------------------|------------------|
| FreeBSD              | 15.1-RELEASE     |
| Plasma session       | Wayland (KWin)   |
| plasma6-krdp         | 6.8.3            |
| pipewire             | 1.6.9            |
| plasma6-kpipewire    | 6.8.3            |
| freerdp3             | 3.33.1           |

## Symptom

- The RDP client (Remmina, mstsc, xfreerdp, ...) connects and authenticates.
- The remote desktop shows a black screen.
- `~/.local/share/sddm/wayland-session.log` contains lines like:

  ```
  kwin_screencast: Failed to connect PipeWire context
  error creating screencast "Failed to connect PipeWire context"
  kpipewire_logging: error: "Failed to connect to PipeWire" 0
  ```

## Cause

KRdp doesn't capture the screen itself. It asks KWin for a **screencast stream
over PipeWire**, encodes that stream as H.264 and sends it to the client.

On Linux, systemd user units start `pipewire` and `wireplumber` when you log in.
**FreeBSD has no systemd**, so neither one starts unless you set that up. With
no PipeWire daemon running, KWin can't create the stream and KRdp has nothing to
send. The RDP session still comes up, but it's empty.

`wireplumber` (the PipeWire session manager) is required too. It links KWin's
screencast node to KRdp's consumer stream.

## Fix

### 1. Install the packages

`plasma6-krdp` is not in the FreeBSD package repository, so install its
dependencies from packages and KRdp itself from this repo's release (or
[build it yourself](#building-plasma6-krdp-from-the-patched-port)):

```sh
sudo pkg install pipewire wireplumber freerdp3 libei qtkeychain-qt6 \
  plasma6-kpipewire plasma6-xdg-desktop-portal-kde kirigami-addons-qt6 \
  kf6-kcmutils kf6-kstatusnotifieritem qt6-wayland
fetch https://github.com/outwestai/krdp-freebsd/releases/download/plasma6-krdp-6.8.3/plasma6-krdp-6.8.3.pkg
sudo pkg add plasma6-krdp-6.8.3.pkg
```

The release package is built for **FreeBSD 15 amd64** against the package
versions listed under [Tested on](#tested-on).

### 2. Start PipeWire and WirePlumber with the Plasma session

Copy the autostart entries from this repo:

```sh
mkdir -p ~/.config/autostart
cp autostart/pipewire.desktop autostart/wireplumber.desktop ~/.config/autostart/
```

Or run the installer script:

```sh
./install.sh
```

The `X-KDE-autostart-phase=1` key makes Plasma start both programs early, before
KRdp's own autostart entry (`org.kde.krdpserver.desktop`) runs.

### 3. Log out and back in

To test without logging out:

```sh
pipewire & sleep 1; wireplumber &
pkill krdpserver; krdpserver &
```

### 4. Verify

```sh
pgrep -l 'pipewire|wireplumber|krdpserver'
```

You should see all three processes. Reconnect with your RDP client and the
desktop should appear.

## Building plasma6-krdp from the patched port

The `net/plasma6-krdp` port in the ports tree declares its runtime dependency
on the portal by the wrong package name:

```
RUN_DEPENDS=	xdg-desktop-portal-kde>0:deskutils/plasma6-xdg-desktop-portal-kde
```

The package is actually called `plasma6-xdg-desktop-portal-kde`, so the
dependency check never matches the installed package. `port/plasma6-krdp/`
contains a copy of the port with that line fixed (see
[`port/run-depends-fix.diff`](port/run-depends-fix.diff)), plus a generated
`pkg-plist`.

To build and install it as a normal user you need a ports tree in `/usr/ports`
(only the framework in `Mk/` is used) and the dependencies installed from
packages (the `pkg install` line in step 1, minus the release download). The
script downloads the source into `port/distfiles/` and tells you if any
dependency is missing:

```sh
sudo git clone --depth 1 https://git.FreeBSD.org/ports.git /usr/ports   # if you have no ports tree
./port/build.sh                 # builds port/pkgs/All/plasma6-krdp-6.8.3.pkg
sudo pkg add port/pkgs/All/plasma6-krdp-6.8.3.pkg
```

Alternatively, apply the diff to your own ports tree:

```sh
cd /usr/ports && patch -p0 < /path/to/krdp-freebsd/port/run-depends-fix.diff
```

## Still black?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## License

[MIT](LICENSE)
