# period-space

macOS-style **double-space → period** on Linux. It works in terminals.

Linux desktops do not ship the macOS / iOS “add period with double-space” setting. This project turns that into an always-on mapping with [keyd](https://github.com/rvaiya/keyd), which remaps keys at the device level. That is why it still works in a terminal, a TTY, and Wayland compositors like niri.

Type `hello` then tap Space twice quickly. You get `hello. `.

## Install

This is its own repo. On this machine it lives at `~/github/period-space`.

From a checkout:

```bash
cd ~/github/period-space
./install.sh
```

That copies `period-space` to `~/.local/bin`, writes your config if it is missing, installs [keyd](https://github.com/rvaiya/keyd) on Fedora or Arch if needed, and turns the mapping on.

From GitHub on another machine:

```bash
git clone https://github.com/hapwi/period-space.git ~/github/period-space
cd ~/github/period-space
./install.sh
```

## Use

```bash
period-space on       # install the mapping and start keyd
period-space off      # remove the mapping
period-space status   # show whether it is active
period-space reload   # apply edits to your config
```

A second Space within 400ms becomes `. `. A slower second Space stays a Space. Ctrl / Alt / Super + Space are left alone.

If the keyboard ever locks up, hold **Backspace + Escape + Enter** to kill keyd.

## Config

Your copy lives at `~/.config/period-space/keyd.conf`. Edit that, then run `period-space reload`.

Change `oneshot_timeout` if 400ms feels too fast or too slow.

If a mouse, headset, or gamepad starts eating key events, it is advertising a keyboard interface. Find its id:

```bash
keyd monitor
```

Then exclude it under `[ids]`:

```
[ids]
*
-1532:007d
```

## How it works

`period-space` is a small controller. **keyd** is the always-on program.

1. The first Space is a Space, and keyd arms a short-lived layer.
2. If the next key is Space before the timeout, keyd sends Backspace, `.`, Space.
3. The oneshot layer is consumed, so a third Space is just another Space.

Because this happens before the compositor or terminal sees the keys, the same behavior shows up everywhere.

## License

MIT
