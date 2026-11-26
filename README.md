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

```sh
sudo pkg install pipewire wireplumber plasma6-krdp
```

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

## Still black?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## License

[MIT](LICENSE)
