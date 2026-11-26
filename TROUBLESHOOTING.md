# Troubleshooting KRdp on FreeBSD

## Confirm you're in a Wayland session

KRdp's Plasma backend needs a Plasma **Wayland** session.

```sh
echo $XDG_SESSION_TYPE      # should print: wayland
```

If it prints `x11`, choose "Plasma (Wayland)" at the SDDM login screen.

## Confirm the portal and PipeWire services are running

```sh
pgrep -lf 'pipewire|wireplumber|xdg-desktop-portal'
```

You should see:

- `pipewire`
- `wireplumber`
- `xdg-desktop-portal`
- `xdg-desktop-portal-kde`

If PipeWire is running but the client still connects to a black screen, check
that PipeWire can see KWin's screencast node while a client is connected:

```sh
pw-cli ls Node | grep -i -A3 kwin
```

## Read the logs

```sh
grep -Ei 'krdp|pipewire|screencast|portal|encod|h264|vaapi' \
    ~/.local/share/sddm/wayland-session.log | tail -40
```

To get more detail, run the server in the foreground with debug logging:

```sh
pkill krdpserver
QT_LOGGING_RULES='krdp*=true;kpipewire*=true' krdpserver
```

## H.264 encoder problems

KRdp encodes video as H.264 through kpipewire/FFmpeg. It tries hardware encoding
(VAAPI) first and falls back to software encoding (libx264 / openh264).

If the logs mention encoder or VAAPI failures:

```sh
sudo pkg install ffmpeg libx264 openh264 libva-utils
vainfo        # check whether VAAPI works on your GPU
```

If VAAPI is broken, force software encoding:

```sh
pkill krdpserver
KPIPEWIRE_FORCE_ENCODER=libx264 krdpserver
```

## Client side

- The client must support **H.264 / AVC420 (GFX pipeline)**. Older clients that
  don't support it show a black screen.
  - FreeRDP: `xfreerdp3 /v:HOST /u:USER /gfx:AVC420`
  - Remmina: set *Colour depth* to "GFX AVC420 (32 bpp)".
  - Windows `mstsc`: works out of the box.
- Make sure the username and password match what you set under
  *System Settings → Remote Desktop*.

## Firewall

KRdp listens on TCP **3389** by default. If you use `pf`, allow it, for example:

```
pass in on $ext_if proto tcp to port 3389
```
